import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    let monthlyProductID = "bible_copilot_pro_monthly"
    let annualProductID = "bible_copilot_pro_annual"
    let freeQuestionLimit = 5

    @Published var products: [Product] = []
    @Published var isPro: Bool = false
    @Published var showPaywall: Bool = false

    private var updateListenerTask: Task<Void, Error>?

    @AppStorage("questionCount") var questionCount: Int = 0

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [monthlyProductID, annualProductID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    /// Returns true if the question limit has been reached (show paywall).
    /// Returns false if the question was counted successfully (proceed with AI response).
    func checkAndIncrementQuestion() -> Bool {
        if isPro {
            questionCount += 1
            return false
        }
        if questionCount >= freeQuestionLimit {
            showPaywall = true
            return true
        }
        questionCount += 1
        return false
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await updateSubscriptionStatus()
    }

    func updateSubscriptionStatus() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == monthlyProductID || transaction.productID == annualProductID {
                    if transaction.revocationDate == nil {
                        active = true
                    }
                }
            }
        }
        isPro = active
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
