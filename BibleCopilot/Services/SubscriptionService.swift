import Foundation
import StoreKit

@Observable
final class SubscriptionService {
    static let shared = SubscriptionService()

    let monthlyProductID = "biblecopilot_pro_monthly"
    let annualProductID = "biblecopilot_pro_annual"

    var products: [Product] = []
    var isPro = false
    var isLoading = false

    @ObservationIgnored
    private var updateTask: Task<Void, Never>?

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    init() {
        updateTask = Task { [weak self] in
            await self?.listenForTransactions()
        }
        loadTask = Task { [weak self] in
            await self?.loadProducts()
            await self?.checkSubscriptionStatus()
        }
    }

    deinit {
        updateTask?.cancel()
        loadTask?.cancel()
    }

    // MARK: - Products

    var loadError: String?

    @MainActor
    func loadProducts() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        let productIDs: Set<String> = [monthlyProductID, annualProductID]
        #if DEBUG
        print("🔄 SubscriptionService: Loading products for IDs: \(productIDs)")
        #endif

        // Retry up to 3 times with backoff, respecting cancellation
        for attempt in 1...3 {
            try? Task.checkCancellation()
            do {
                let fetched = try await Product.products(for: productIDs)
                #if DEBUG
                print("📦 Attempt \(attempt): Got \(fetched.count) products")
                #endif
                if !fetched.isEmpty {
                    products = fetched
                    loadError = nil
                    return
                }
            } catch is CancellationError {
                return
            } catch {
                #if DEBUG
                print("❌ Product fetch attempt \(attempt): \(error)")
                #endif
            }
            if attempt < 3 {
                try? await Task.sleep(for: .seconds(Double(attempt) * 1.5))
            }
        }
        loadError = "Unable to load plans. Please check your connection."
    }

    // MARK: - Purchase

    @MainActor
    func purchase(_ product: Product) async throws {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            isPro = true
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }

    // MARK: - Restore

    @MainActor
    func restore() async {
        isLoading = true
        defer { isLoading = false }
        try? await AppStore.sync()
        await checkSubscriptionStatus()
    }

    // MARK: - Status

    @MainActor
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == monthlyProductID || transaction.productID == annualProductID {
                    isPro = true
                    return
                }
            }
        }
        isPro = false
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                await transaction.finish()
                await checkSubscriptionStatus()
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let value):
            return value
        }
    }

    var annualProduct: Product? {
        products.first { $0.id == annualProductID }
    }

    var monthlyProduct: Product? {
        products.first { $0.id == monthlyProductID }
    }
}

enum SubscriptionError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "Transaction verification failed."
    }
}
