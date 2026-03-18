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
                VStack(spacing: AppTheme.spacingXL) {
                    // Header
                    VStack(spacing: AppTheme.spacingMD) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 64))
                            .foregroundColor(AppTheme.accent)
                            .padding(.top, 40)

                        Text("Try Bible Copilot Free")
                            .font(AppTheme.headingFont)
                            .foregroundColor(AppTheme.textPrimary)

                        Text("7 days free, then unlock unlimited\nAI-powered Bible study")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textMuted)
                            .multilineTextAlignment(.center)
                    }

                    // Features list
                    VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                        FeatureRow(icon: "infinity", text: "Unlimited questions & answers")
                        FeatureRow(icon: "brain.head.profile", text: "Deep theological insights")
                        FeatureRow(icon: "bookmark.fill", text: "Save your conversations")
                        FeatureRow(icon: "globe", text: "Any verse, any translation")
                        FeatureRow(icon: "lock.open.fill", text: "Cancel anytime — no pressure")
                    }
                    .padding(.horizontal, AppTheme.spacing2XL)

                    Divider()
                        .background(AppTheme.textMuted.opacity(0.3))
                        .padding(.horizontal, AppTheme.spacingXL)

                    // Plan selector
                    if subscriptionManager.products.isEmpty {
                        ProgressView("Loading plans...")
                            .tint(AppTheme.accent)
                            .padding()
                    } else {
                        VStack(spacing: AppTheme.spacingMD) {
                            if let annual = annualProduct {
                                PlanCard(
                                    product: annual,
                                    isSelected: selectedProductID == annual.id || selectedProductID.isEmpty,
                                    badge: "7-DAY FREE TRIAL",
                                    subtitle: "then \(annual.displayPrice)/year · Save 50%",
                                    isRecommended: true
                                ) {
                                    selectedProductID = annual.id
                                    HapticManager.selection()
                                }
                            }

                            if let monthly = monthlyProduct {
                                PlanCard(
                                    product: monthly,
                                    isSelected: selectedProductID == monthly.id,
                                    badge: nil,
                                    subtitle: "Billed monthly",
                                    isRecommended: false
                                ) {
                                    selectedProductID = monthly.id
                                    HapticManager.selection()
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingXL)

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
                                        HapticManager.success()
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
                            .padding(.vertical, AppTheme.spacingLG)
                            .background(AppTheme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(AppTheme.cornerRadiusMD)
                        }
                        .padding(.horizontal, AppTheme.spacingXL)
                        .disabled(isLoading)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(AppTheme.error)
                            .font(AppTheme.captionFont)
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
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textMuted)

                    // Legal
                    Text("Free trial available for new subscribers only. After trial ends, subscription auto-renews unless canceled 24 hours before renewal. Cancel anytime in App Store Settings.")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.spacingXL)
                        .padding(.bottom, 40)
                }
            }
            .background(AppTheme.background)
            .navigationBarItems(
                trailing: Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textMuted)
                        .font(.title3)
                }
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
                            .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                        if let badge = badge {
                            Text(badge)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.gold)
                                .foregroundColor(.black)
                                .cornerRadius(4)
                        }
                    }
                    Text(subtitle)
                        .font(AppTheme.captionFont)
                        .foregroundColor(isSelected ? .white.opacity(0.85) : AppTheme.textMuted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title3.bold())
                        .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                    if isRecommended && !isSelected {
                        Text("BEST VALUE")
                            .font(.caption2.bold())
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .padding()
            .background(isSelected ? AppTheme.accent : AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadiusMD)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                    .stroke(isSelected ? Color.clear : AppTheme.textMuted.opacity(0.2), lineWidth: 1)
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
                .foregroundColor(AppTheme.accent)
                .frame(width: 24)
            Text(text)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}
