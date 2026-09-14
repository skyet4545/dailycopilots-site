import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var statusMessage: String?
    @State private var introOfferEligibility: [String: Bool] = [:]
    @State private var completedPurchase = false
    @State private var recordedDismissal = false
    @State private var recordedPlanLoadFailure = false

    private var paywallTrigger: String {
        UsageService.shared.usedToday >= UsageService.freeQuestionsPerDay ? "free_limit" : "manual_upgrade"
    }

    // The free-limit treatment changes one decision variable: the headline shifts
    // from an abstract benefit to continuing the study the reader just started.
    // The offer, prices, trial, plan order, feature list, and CTA stay unchanged.
    private var paywallCopyVersion: String {
        paywallTrigger == "free_limit" ? "free_limit_continue_v1" : "manual_control_v1"
    }

    private var paywallHeadline: String {
        paywallTrigger == "free_limit" ? "Continue Your Bible Study" : "Understand Scripture\nDeeply"
    }

    // The plan the user is about to buy (annual is the default when nothing is tapped).
    private var selectedProduct: Product? {
        if selectedPlan == subscriptionService.monthlyProductID {
            return subscriptionService.monthlyProduct
        }
        return subscriptionService.annualProduct
    }

    private var subscriptionProductIDs: String {
        subscriptionService.products.map(\.id).sorted().joined(separator: "|")
    }

    private func configuredTrialLength(for product: Product?) -> String? {
        guard let offer = product?.subscription?.introductoryOffer,
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

    static func visibleTrialLength(configured: String?, isEligible: Bool?) -> String? {
        guard isEligible == true else { return nil }
        return configured
    }

    private func visibleTrialLength(for product: Product?) -> String? {
        guard let product else { return nil }
        return Self.visibleTrialLength(
            configured: configuredTrialLength(for: product),
            isEligible: introOfferEligibility[product.id]
        )
    }

    private func eligibilityState(for product: Product?) -> String {
        guard let product,
              configuredTrialLength(for: product) != nil else { return "no_free_trial" }
        guard let isEligible = introOfferEligibility[product.id] else { return "unknown" }
        return isEligible ? "eligible" : "ineligible"
    }

    // The free-trial length is visible only after StoreKit confirms that this
    // customer is eligible for the configured introductory offer.
    private var trialLengthText: String? {
        visibleTrialLength(for: selectedProduct)
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

                        Text(paywallHeadline)
                            .font(.title.bold())
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Unlock unlimited AI-powered Bible study")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textMuted)

                        // Value recap: when they've been studying (the limit-hit moment), remind
                        // them of the value they just got. This is where hesitant users convert —
                        // 13 of 17 who hit the wall were walking away without it.
                        if UsageService.shared.usedToday > 0 {
                            Text("You've asked \(UsageService.shared.usedToday) question\(UsageService.shared.usedToday == 1 ? "" : "s") today. You're clearly studying, keep it going with unlimited.")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(AppTheme.gold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.top, 4)
                        }
                    }

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        PaywallFeatureRow(icon: "infinity", text: "Unlimited AI study questions")
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
                                    badge: visibleTrialLength(for: annual).map { "\($0.uppercased()) FREE TRIAL" } ?? "BEST VALUE",
                                    subtitle: annualSubtitle
                                ) {
                                    selectedPlan = annual.id
                                    AnalyticsService.shared.track(AnalyticsEvent.planSelected, ["product": annual.id, "billing_period": "annual", "trigger": paywallTrigger, "copy_version": paywallCopyVersion, "trial_eligibility": eligibilityState(for: annual)])
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
                                    AnalyticsService.shared.track(AnalyticsEvent.planSelected, ["product": monthly.id, "billing_period": "monthly", "trigger": paywallTrigger, "copy_version": paywallCopyVersion, "trial_eligibility": eligibilityState(for: monthly)])
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

                    if let status = statusMessage {
                        Text(status)
                            .font(.caption)
                            .foregroundColor(AppTheme.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
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
                            defer { isLoading = false }
                            let restoreProperties = ["source": "paywall", "restore_attempt_id": UUID().uuidString]
                            AnalyticsService.shared.track(AnalyticsEvent.restoreStarted, restoreProperties)
                            do {
                                if try await subscriptionService.restore() {
                                    completedPurchase = true
                                    AnalyticsService.shared.track(AnalyticsEvent.restoreSucceeded, restoreProperties)
                                    dismiss()
                                } else {
                                    AnalyticsService.shared.track(AnalyticsEvent.restoreNoEntitlement, restoreProperties)
                                    statusMessage = "No active Bible Copilot Pro purchase was found for this Apple ID."
                                }
                            } catch {
                                AnalyticsService.shared.track(AnalyticsEvent.restoreFailed, restoreProperties.merging(["error": String(describing: error).prefix(120).description]) { current, _ in current })
                                errorMessage = "Apple could not restore purchases. Check your connection and try again."
                            }
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
                AnalyticsService.shared.track(AnalyticsEvent.paywallView, ["source": "in_app", "trigger": paywallTrigger, "used": "\(UsageService.shared.usedToday)", "copy_version": paywallCopyVersion, "trial_eligibility": eligibilityState(for: selectedProduct)])
                recordPlanLoadFailureIfNeeded()
            }
            .task(id: subscriptionProductIDs) {
                await refreshIntroOfferEligibility()
            }
            .onChange(of: subscriptionService.loadError) { _, newValue in
                guard newValue != nil else { return }
                recordPlanLoadFailureIfNeeded()
            }
            .onDisappear {
                guard !completedPurchase else { return }
                recordDismissal(reason: "sheet_closed")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        recordDismissal(reason: "close_button")
                        dismiss()
                    } label: {
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
            statusMessage = nil
            let eligibleTrial = visibleTrialLength(for: product) != nil
            let properties = ["product": product.id, "source": "in_app", "trigger": paywallTrigger, "copy_version": paywallCopyVersion, "trial_eligibility": eligibilityState(for: product), "offer_type": eligibleTrial ? "free_trial" : "subscription", "purchase_attempt_id": UUID().uuidString]
            AnalyticsService.shared.track(AnalyticsEvent.trialStartTap, properties)
            do {
                let outcome = try await subscriptionService.purchase(product)
                switch outcome {
                case .purchased:
                    completedPurchase = true
                    AnalyticsService.shared.track(AnalyticsEvent.purchaseSuccess, properties)
                    dismiss()
                case .cancelled:
                    AnalyticsService.shared.track(AnalyticsEvent.purchaseCancelled, properties)
                case .pending:
                    AnalyticsService.shared.track(AnalyticsEvent.purchasePending, properties)
                    statusMessage = "Your purchase is pending Apple approval. Pro will unlock automatically when it completes."
                case .unknown:
                    AnalyticsService.shared.track(AnalyticsEvent.purchaseUnknown, properties)
                    errorMessage = "Apple did not complete the purchase. Please try again."
                }
            } catch {
                AnalyticsService.shared.track(AnalyticsEvent.purchaseFailed, properties.merging(["error": String(describing: error).prefix(120).description]) { current, _ in current })
                errorMessage = "Purchase failed. Please try again."
            }
            isLoading = false
        }
    }

    private func recordDismissal(reason: String) {
        guard !recordedDismissal else { return }
        recordedDismissal = true
        AnalyticsService.shared.track(AnalyticsEvent.paywallDismissed, ["source": "in_app", "trigger": paywallTrigger, "copy_version": paywallCopyVersion, "reason": reason])
    }

    private func recordPlanLoadFailureIfNeeded() {
        guard subscriptionService.loadError != nil, !recordedPlanLoadFailure else { return }
        recordedPlanLoadFailure = true
        AnalyticsService.shared.track(AnalyticsEvent.paywallPlansLoadFailed, ["source": "in_app", "trigger": paywallTrigger, "copy_version": paywallCopyVersion])
    }

    @MainActor
    private func refreshIntroOfferEligibility() async {
        var refreshed: [String: Bool] = [:]
        for product in subscriptionService.products {
            guard configuredTrialLength(for: product) != nil,
                  let subscription = product.subscription else { continue }
            refreshed[product.id] = await subscription.isEligibleForIntroOffer
        }
        introOfferEligibility = refreshed
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
