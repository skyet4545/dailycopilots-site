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
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: AppTheme.gold.opacity(0.3), radius: 10, y: 4)
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
                        VStack(spacing: 16) {
                            if subscriptionService.isLoading {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                        .tint(AppTheme.accent)
                                    Text("Loading plans...")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textMuted)
                                }
                            } else {
                                Image(systemName: "wifi.exclamationmark")
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.textMuted)

                                Text(subscriptionService.loadError ?? "Unable to load subscription plans.")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textMuted)
                                    .multilineTextAlignment(.center)

                                Button {
                                    Task { await subscriptionService.loadProducts() }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Try Again")
                                    }
                                    .font(.body.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(AppTheme.accent)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(32)
                        .onAppear {
                            // Always try loading when paywall appears
                            Task { await subscriptionService.loadProducts() }
                        }
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

                    // Legal links (required by App Store 3.1.2)
                    HStack(spacing: 16) {
                        Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(.caption2)
                            .foregroundColor(AppTheme.accent)

                        Link("Privacy Policy", destination: URL(string: "https://scripturecopilot.netlify.app/privacy")!)
                            .font(.caption2)
                            .foregroundColor(AppTheme.accent)
                    }

                    // Subscription details (required by App Store 3.1.2)
                    VStack(spacing: 4) {
                        if let annual = subscriptionService.annualProduct {
                            Text("Bible Copilot Pro (Annual): \(annual.displayPrice)/year")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textMuted.opacity(0.7))
                        }
                        if let monthly = subscriptionService.monthlyProduct {
                            Text("Bible Copilot Pro (Monthly): \(monthly.displayPrice)/month")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textMuted.opacity(0.7))
                        }
                        Text("Subscriptions auto-renew unless canceled at least 24 hours before the end of the current period. Cancel anytime in App Store Settings. Payment is charged to your Apple ID account.")
                            .font(.caption2)
                            .foregroundColor(AppTheme.textMuted.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
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
