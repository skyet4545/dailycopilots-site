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

    @ObservationIgnored
    private var isLoadingProducts = false

    @ObservationIgnored
    private var lastTrackedEntitlementFingerprint: String?

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
        // Prevent overlapping loads
        guard !isLoadingProducts else { return }
        // Skip if already loaded
        guard products.isEmpty else { return }

        isLoadingProducts = true
        isLoading = true
        loadError = nil
        defer {
            isLoading = false
            isLoadingProducts = false
        }

        let productIDs: Set<String> = [monthlyProductID, annualProductID]
        #if DEBUG
        print("🔄 SubscriptionService: Loading products for IDs: \(productIDs)")
        #endif

        // Retry up to 5 times with exponential backoff
        // Apple sandbox can be slow during review
        let maxAttempts = 5
        for attempt in 1...maxAttempts {
            if Task.isCancelled { return }
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
            if attempt < maxAttempts {
                let delay = Double(min(attempt * 2, 8))
                try? await Task.sleep(for: .seconds(delay))
            }
        }
        loadError = "Unable to load plans. Please check your connection."
    }

    // MARK: - Purchase

    @MainActor
    func purchase(_ product: Product) async throws -> PurchaseOutcome {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            isPro = true
            return .purchased
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .unknown
        }
    }

    // MARK: - Restore

    @MainActor
    func restore() async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        try await AppStore.sync()
        await checkSubscriptionStatus()
        return isPro
    }

    // MARK: - Status

    @MainActor
    func checkSubscriptionStatus() async {
        var activeProductID: String?
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == monthlyProductID || transaction.productID == annualProductID {
                    activeProductID = transaction.productID
                    break
                }
            }
        }
        isPro = activeProductID != nil
        trackEntitlementObservation(productID: activeProductID)
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

    @MainActor
    private func trackEntitlementObservation(productID: String?) {
        guard AnalyticsService.shared.isEnabled else { return }
        let observation = EntitlementObservation(
            productID: productID,
            monthlyProductID: monthlyProductID,
            annualProductID: annualProductID
        )
        guard observation.fingerprint != lastTrackedEntitlementFingerprint else { return }
        AnalyticsService.shared.track(AnalyticsEvent.entitlementStateObserved, observation.properties)
        lastTrackedEntitlementFingerprint = observation.fingerprint
    }

    var annualProduct: Product? {
        products.first { $0.id == annualProductID }
    }

    var monthlyProduct: Product? {
        products.first { $0.id == monthlyProductID }
    }
}

struct EntitlementObservation: Equatable {
    let state: String
    let plan: String

    init(productID: String?, monthlyProductID: String, annualProductID: String) {
        switch productID {
        case monthlyProductID:
            state = "active"
            plan = "monthly"
        case annualProductID:
            state = "active"
            plan = "annual"
        default:
            state = "inactive"
            plan = "none"
        }
    }

    var properties: [String: String] {
        [
            "state": state,
            "plan": plan,
            "source": "storekit_current_entitlements",
        ]
    }

    var fingerprint: String { "\(state)|\(plan)" }
}

enum PurchaseOutcome: Equatable {
    case purchased
    case cancelled
    case pending
    case unknown
}

enum SubscriptionError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "Transaction verification failed."
    }
}
