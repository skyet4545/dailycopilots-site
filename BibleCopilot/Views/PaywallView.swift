import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedProductID: String = ""

    var annualProduct: Product? {
        subscriptionManager.products.first { $0.id == subscriptionManager.annualProductID }
    }

    var monthlyProduct: Product? {
        subscriptionManager.products.first { $0.id == subscriptionManager.monthlyProductID }
    }

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

                        Text("Try Bible Copilot Free")
                            .font(.largeTitle.bold())

                        Text("7 days free, then unlock unlimited\nAI-powered Bible study")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // Features list
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "infinity", text: "Unlimited questions & answers")
                        FeatureRow(icon: "brain.head.profile", text: "Deep theological insights")
                        FeatureRow(icon: "bookmark.fill", text: "Save your conversations")
                        FeatureRow(icon: "globe", text: "Any verse, any translation")
                        FeatureRow(icon: "lock.open.fill", text: "Cancel anytime — no pressure")
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 8)

                    Divider()
                        .padding(.horizontal, 24)

                    // Plan selector
                    if subscriptionManager.products.isEmpty {
                        ProgressView("Loading plans...")
                            .padding()
                    } else {
                        VStack(spacing: 12) {

                            // Annual — default/highlighted
                            if let annual = annualProduct {
                                PlanCard(
                                    product: annual,
                                    isSelected: selectedProductID == annual.id || selectedProductID.isEmpty,
                                    badge: "7-DAY FREE TRIAL",
                                    subtitle: "then \(annual.displayPrice)/year · Save 50%",
                                    isRecommended: true
                                ) {
                                    selectedProductID = annual.id
                                }
                            }

                            // Monthly
                            if let monthly = monthlyProduct {
                                PlanCard(
                                    product: monthly,
                                    isSelected: selectedProductID == monthly.id,
                                    badge: nil,
                                    subtitle: "Billed monthly",
                                    isRecommended: false
                                ) {
                                    selectedProductID = monthly.id
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Main CTA
                        Button {
                            Task {
                                isLoading = true
                                errorMessage = nil
                                let productToBuy = selectedProductID == subscriptionManager.monthlyProductID
                                    ? monthlyProduct
                                    : annualProduct
                                guard let product = productToBuy else { return }
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
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(selectedProductID == subscriptionManager.monthlyProductID
                                         ? "Subscribe Monthly"
                                         : "Start Free Trial")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 24)
                        .disabled(isLoading)
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
                    Text("Free trial available for new subscribers only. After trial ends, subscription auto-renews unless canceled 24 hours before renewal. Cancel anytime in App Store Settings.")
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

// MARK: - Plan Card

struct PlanCard: View {
    let product: Product
    let isSelected: Bool
    let badge: String?
    let subtitle: String
    let isRecommended: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(product.displayName)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .primary)
                        if let badge = badge {
                            Text(badge)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(4)
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title3.bold())
                        .foregroundColor(isSelected ? .white : .primary)
                    if isRecommended && !isSelected {
                        Text("BEST VALUE")
                            .font(.caption2.bold())
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feature Row

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
