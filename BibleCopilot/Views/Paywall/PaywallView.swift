import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.blue)
                            .padding(.top, 40)

                        Text("Bible Copilot Pro")
                            .font(.largeTitle.bold())

                        Text("Unlimited Bible Study\nUnlimited Questions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // Features list
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "infinity", text: "Unlimited questions")
                        FeatureRow(icon: "brain.head.profile", text: "Deep theological insights")
                        FeatureRow(icon: "bookmark.fill", text: "Save your conversations")
                        FeatureRow(icon: "lock.open.fill", text: "Full access, always")
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 8)

                    Divider()
                        .padding(.horizontal, 24)

                    // Purchase buttons
                    if subscriptionManager.products.isEmpty {
                        ProgressView("Loading plans...")
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(
                                subscriptionManager.products.sorted { a, b in
                                    // Show annual first
                                    a.id == subscriptionManager.annualProductID
                                },
                                id: \.id
                            ) { product in
                                PurchaseButton(
                                    product: product,
                                    isAnnual: product.id == subscriptionManager.annualProductID,
                                    isLoading: isLoading
                                ) {
                                    Task {
                                        isLoading = true
                                        errorMessage = nil
                                        do {
                                            try await subscriptionManager.purchase(product)
                                            if subscriptionManager.isPro {
                                                dismiss()
                                            }
                                        } catch {
                                            errorMessage = "Purchase failed. Please try again."
                                        }
                                        isLoading = false
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }

                    // Restore purchases
                    Button("Restore Purchases") {
                        Task {
                            isLoading = true
                            try? await subscriptionManager.restorePurchases()
                            isLoading = false
                            if subscriptionManager.isPro {
                                dismiss()
                            }
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)

                    // Legal
                    Text("Subscriptions auto-renew unless canceled. Cancel anytime in Settings.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
            .navigationBarItems(
                trailing: Button("Close") { dismiss() }
            )
        }
    }
}

struct PurchaseButton: View {
    let product: Product
    let isAnnual: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(product.displayName)
                            .font(.headline)
                        if isAnnual {
                            Text("BEST VALUE")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(4)
                        }
                    }
                    Text(isAnnual ? "Billed annually" : "Billed monthly")
                        .font(.caption)
                        .opacity(0.85)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.title3.bold())
            }
            .padding()
            .background(isAnnual ? Color.blue : Color.blue.opacity(0.75))
            .foregroundColor(.white)
            .cornerRadius(14)
        }
        .disabled(isLoading)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
                .font(.body)
        }
    }
}
