import Foundation
import StoreKit

@Observable
final class SubscriptionService {
    static let shared = SubscriptionService()

    let monthlyProductID = "bible_copilot_pro_monthly"
    let annualProductID = "bible_copilot_pro_annual"

    var products: [Product] = []
    var isPro = false
    var isLoading = false

    @ObservationIgnored
    private var updateTask: Task<Void, Never>?

    init() {
        updateTask = Task { [weak self] in
            await self?.listenForTransactions()
        }
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }

    deinit {
        updateTask?.cancel()
    }

    // MARK: - Products

    var loadError: String?

    @MainActor
    func loadProducts() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        let productIDs: Set<String> = [monthlyProductID, annualProductID]

        // Retry up to 5 times with exponential backoff (sandbox/network can be slow)
        for attempt in 1...5 {
            do {
                let fetched = try await Product.products(for: productIDs)
                if !fetched.isEmpty {
                    products = fetched
                    loadError = nil
                    print("✅ Loaded \(fetched.count) products on attempt \(attempt)")
                    return
                } else {
                    print("⚠️ Empty product list on attempt \(attempt) — IDs may not match App Store Connect")
                }
            } catch {
                print("❌ Product fetch attempt \(attempt): \(error.localizedDescription)")
            }
            if attempt < 5 {
                let delay = Double(attempt) * 1.5 // 1.5s, 3s, 4.5s, 6s
                try? await Task.sleep(for: .seconds(delay))
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
