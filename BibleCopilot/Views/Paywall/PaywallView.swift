import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 56))
                            .foregroundColor(AppTheme.gold)
                            .padding(.top, 40)

                        Text("Understand Scripture\nDeeply")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Unlock unlimited AI-powered Bible study")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textMuted)
                    }

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        PaywallFeatureRow(icon: "infinity", text: "Unlimited questions & answers")
                        PaywallFeatureRow(icon: "book.fill", text: "Study Journal — save insights")
                        PaywallFeatureRow(icon: "globe", text: "All Bible translations")
                        PaywallFeatureRow(icon: "calendar", text: "Guided Reading Plans")
                    }
                    .padding(.horizontal, 32)

                    Divider()
                        .background(AppTheme.surfaceBorder)
                        .padding(.horizontal, 24)

                    // Plan cards
                    if subscriptionService.products.isEmpty {
                        ProgressView("Loading plans...")
                            .tint(AppTheme.accent)
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            // Annual
                            if let annual = subscriptionService.annualProduct {
                                PaywallPlanCard(
                                    product: annual,
                                    isSelected: selectedPlan == annual.id || selectedPlan.isEmpty,
                                    badge: "BEST VALUE",
                                    subtitle: "\(annual.displayPrice)/year"
                                ) {
                                    selectedPlan = annual.id
                                    HapticService.selection()
                                }
                            }

                            // Monthly
                            if let monthly = subscriptionService.monthlyProduct {
                                PaywallPlanCard(
                                    product: monthly,
                                    isSelected: selectedPlan == monthly.id,
                                    badge: nil,
                                    subtitle: "Billed monthly"
                                ) {
                                    selectedPlan = monthly.id
                                    HapticService.selection()
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // CTA
                        Button {
                            purchaseSelected()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Continue")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.goldGradient)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 24)
                        .disabled(isLoading)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(AppTheme.error)
                    }

                    Text("No commitment, cancel anytime")
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)

                    // Restore
                    Button("Restore Purchases") {
                        Task {
                            isLoading = true
                            await subscriptionService.restore()
                            isLoading = false
                            if subscriptionService.isPro { dismiss() }
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(AppTheme.textMuted)

                    // Legal
                    Text("Subscriptions auto-renew unless canceled 24 hours before renewal. Cancel anytime in App Store Settings.")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textMuted.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
            .background(AppTheme.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
        }
    }

    private func purchaseSelected() {
        let productToBuy: Product?
        if selectedPlan == subscriptionService.monthlyProductID {
            productToBuy = subscriptionService.monthlyProduct
        } else {
            productToBuy = subscriptionService.annualProduct
        }

        guard let product = productToBuy else { return }

        Task {
            isLoading = true
            errorMessage = nil
            do {
                try await subscriptionService.purchase(product)
                if subscriptionService.isPro { dismiss() }
            } catch {
                errorMessage = "Purchase failed. Please try again."
            }
            isLoading = false
        }
    }
}

// MARK: - Plan Card

struct PaywallPlanCard: View {
    let product: Product
    let isSelected: Bool
    let badge: String?
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(product.displayName)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : AppTheme.textPrimary)

                        if let badge {
                            Text(badge)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.gold)
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.85) : AppTheme.textMuted)
                }

                Spacer()

                // Radio indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.accent : AppTheme.textMuted, lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(product.displayPrice)
                    .font(.title3.bold())
                    .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
            }
            .padding()
            .background(isSelected ? AppTheme.accentDark : AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppTheme.accent : AppTheme.cardBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feature Row

struct PaywallFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.accent)
                .frame(width: 24)
            Text(text)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}
