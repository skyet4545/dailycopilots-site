import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    // The plan the user is about to buy (annual is the default when nothing is tapped).
    private var selectedProduct: Product? {
        if selectedPlan == subscriptionService.monthlyProductID {
            return subscriptionService.monthlyProduct
        }
        return subscriptionService.annualProduct
    }

    // The free-trial length on the selected plan, e.g. "7-Day", or nil if no trial.
    private var trialLengthText: String? {
        guard let offer = selectedProduct?.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else { return nil }
        let n = offer.period.value
        switch offer.period.unit {
        case .day:   return "\(n)-Day"
        case .week:  return "\(n * 7)-Day"
        case .month: return "\(n)-Month"
        case .year:  return "\(n)-Year"
        @unknown default: return nil
        }
    }

    // CTA: lead with the free trial when one exists — hesitant users tap "try free"
    // far more than "pay".
    private var ctaTitle: String {
        if let t = trialLengthText { return "Start \(t) Free Trial" }
        return "Subscribe"
    }

    // Risk-reversal line under the CTA. Dynamic to the selected plan.
    private var reassuranceText: String {
        guard let p = selectedProduct else { return "Cancel anytime" }
        let period = (p.id == subscriptionService.monthlyProductID) ? "month" : "year"
        if trialLengthText != nil {
            return "No charge today. After your free trial it's \(p.displayPrice)/\(period). Cancel anytime."
        }
        return "\(p.displayPrice) per \(period). Cancel anytime."
    }

    // Annual card subtitle: per-month equivalent + savings vs monthly — makes the
    // annual plan the obvious choice.
    private var annualSubtitle: String {
        guard let annual = subscriptionService.annualProduct else { return "Billed annually" }
        let perMonth = (annual.price / 12).formatted(annual.priceFormatStyle)
        if let monthly = subscriptionService.monthlyProduct, monthly.price > 0 {
            let pct = Int((((1 - (annual.price / (monthly.price * 12))) * 100) as NSDecimalNumber).doubleValue.rounded())
            return "Just \(perMonth)/mo · save \(pct)%"
        }
        return "Just \(perMonth)/mo · billed annually"
    }

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
                        PaywallFeatureRow(icon: "infinity", text: "Unlimited Scripture-cited answers")
                        PaywallFeatureRow(icon: "square.grid.2x2.fill", text: "All 6 study modes on every verse")
                        PaywallFeatureRow(icon: "sparkles", text: "Explore any topic across Scripture")
                        PaywallFeatureRow(icon: "book.fill", text: "Study journal + all 5 reading plans")
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
                                    badge: trialLengthText != nil ? "7-DAY FREE TRIAL" : "BEST VALUE",
                                    subtitle: annualSubtitle
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
                                    Text(ctaTitle)
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

                        // Risk-reversal, right under the CTA where it converts.
                        Text(reassuranceText)
                            .font(.caption)
                            .foregroundColor(AppTheme.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 2)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(AppTheme.error)
                    }

                    // Sign in prompt (if not signed in)
                    if !AuthService.shared.isSignedIn {
                        VStack(spacing: 8) {
                            Text("Sign in to sync your subscription across devices")
                                .font(.caption)
                                .foregroundColor(AppTheme.textMuted)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 12) {
                                SignInWithAppleCoordinator()
                                    .frame(height: 36)
                            }
                        }
                        .padding(.top, 4)
                    }

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

                        Link("Privacy Policy", destination: URL(string: "https://mybiblecopilot.com/privacy")!)
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
            .onAppear {
                AnalyticsService.shared.track(AnalyticsEvent.paywallView, ["source": "in_app"])
            }
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
            AnalyticsService.shared.track(AnalyticsEvent.trialStartTap, ["product": product.id, "source": "in_app"])
            do {
                try await subscriptionService.purchase(product)
                if subscriptionService.isPro {
                    AnalyticsService.shared.track(AnalyticsEvent.purchaseSuccess, ["product": product.id, "source": "in_app"])
                    dismiss()
                }
            } catch {
                AnalyticsService.shared.track(AnalyticsEvent.purchaseFailed, ["product": product.id, "error": String(describing: error).prefix(120).description])
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
