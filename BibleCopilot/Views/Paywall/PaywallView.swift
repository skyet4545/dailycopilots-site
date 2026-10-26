import SwiftUI
import StoreKit

/// Why the paywall was presented. Nil means infer it from today's usage.
enum PaywallTrigger: String, Equatable {
    case freeLimit = "free_limit"
    case softFirstAnswer = "soft_first_answer"
    case softLastFree = "soft_last_free"
    case manualUpgrade = "manual_upgrade"
}

struct PaywallView: View {
    var trigger: PaywallTrigger? = nil

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
        if let trigger { return trigger.rawValue }
        return UsageService.shared.usedToday >= UsageService.freeQuestionsPerDay
            ? PaywallTrigger.freeLimit.rawValue
            : PaywallTrigger.manualUpgrade.rawValue
    }

    /// Headline for the hard limit stays the continue-study treatment. Trial lines,
    /// the soft first-answer ask, and the feature list are separate copy versions.
    private var paywallCopyVersion: String {
        switch trigger {
        case .softFirstAnswer: return "soft_first_answer_v1"
        case .softLastFree: return "soft_last_free_v1"
        case .freeLimit: return "free_limit_continue_v2"
        case .manualUpgrade: return "manual_trial_clarity_v1"
        case nil:
            return paywallTrigger == PaywallTrigger.freeLimit.rawValue
                ? "free_limit_continue_v2"
                : "manual_trial_clarity_v1"
        }
    }

    private var paywallHeadline: String {
        if trigger == .softFirstAnswer {
            let reference = UsageService.shared.lastStudyReference.trimmingCharacters(in: .whitespacesAndNewlines)
            if reference.isEmpty { return "Keep studying Scripture" }
            return "Keep studying \(reference)"
        }
        if trigger == .softLastFree {
            return "1 free question left today"
        }
        return paywallTrigger == PaywallTrigger.freeLimit.rawValue
            ? "Continue Your Bible Study"
            : "Understand Scripture\nDeeply"
    }

    private var paywallSubheadline: String {
        if trigger == .softFirstAnswer {
            let reference = UsageService.shared.lastStudyReference.trimmingCharacters(in: .whitespacesAndNewlines)
            let prompt = UsageService.shared.lastStudyPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
            if !reference.isEmpty, !prompt.isEmpty {
                if StudyMode.allCases.contains(where: { $0.label == prompt }) {
                    return "You just studied \(reference) in \(prompt). Pro continues with unlimited Scripture-cited answers."
                }
                let short = prompt.count > 80 ? String(prompt.prefix(77)) + "…" : prompt
                return "You asked about \(reference): “\(short)” Pro continues with unlimited Scripture-cited answers."
            }
            return "You just got a Scripture-cited answer. Pro continues with unlimited answers."
        }
        if trigger == .softLastFree {
            return "Your next answer is still free. Pro continues after that with unlimited Scripture-cited answers."
        }
        return "Unlimited Scripture-cited answers, past \(UsageService.freeQuestionsPerDay) free questions a day"
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

    private func visibleTrialDays(for product: Product?) -> Int? {
        guard visibleTrialLength(for: product) != nil,
              let offer = product?.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else { return nil }
        return Self.freeTrialDayCount(periodValue: offer.period.value, unit: offer.period.unit)
    }

    // CTA: lead with the free trial only when this Apple ID can actually start it.
    // The length comes from the product's introductory offer, not a hardcoded 7.
    private var ctaTitle: String {
        if let t = trialLengthText { return "Start \(t) Free Trial" }
        return "Subscribe"
    }

    /// Price, period, trial, and auto-renew — directly under the button (guideline 3.1.2).
    private var reassuranceText: String {
        guard let product = selectedProduct else {
            return "Cancel anytime in App Store Settings."
        }
        let periodWord = product.id == subscriptionService.monthlyProductID ? "month" : "year"
        return Self.reassurance(
            lengthLabel: visibleTrialLength(for: product),
            displayPrice: product.displayPrice,
            periodWord: periodWord
        )
    }

    /// Annual card: eligible trial terms, then per-week and per-month equivalents.
    /// The large price on the card stays the amount actually billed.
    private var annualSubtitle: String {
        guard let annual = subscriptionService.annualProduct else { return "Billed annually" }
        let perWeek = (annual.price / 52).formatted(annual.priceFormatStyle)
        let perMonth = (annual.price / 12).formatted(annual.priceFormatStyle)
        let saved = subscriptionService.monthlyProduct.flatMap {
            PaywallPricing.percentSaved(annual: annual.price, monthly: $0.price)
        }
        let trialLine = visibleTrialLength(for: annual).map {
            Self.trialThenPrice(lengthLabel: $0, displayPrice: annual.displayPrice, periodWord: "year")
        }
        return Self.annualPriceDetail(
            trialLine: trialLine,
            perWeek: perWeek,
            perMonth: perMonth,
            percentSaved: saved
        )
    }

    private func annualBadge(for product: Product) -> String {
        guard let label = visibleTrialLength(for: product) else { return "BEST VALUE" }
        if label.hasSuffix("Day"), let days = visibleTrialDays(for: product) {
            return "\(days) DAYS FREE"
        }
        return "FREE TRIAL"
    }

    private func planSubtitle(for product: Product, periodWord: String) -> String {
        Self.trialThenPrice(
            lengthLabel: visibleTrialLength(for: product),
            displayPrice: product.displayPrice,
            periodWord: periodWord
        )
    }

    private func selectAnnualIfNeeded() {
        guard selectedPlan.isEmpty, let annualID = subscriptionService.annualProduct?.id else { return }
        selectedPlan = annualID
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

                        Text(paywallSubheadline)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        // At the hard limit, say exactly what ran out. The sheet stays dismissible;
                        // the next question stays blocked until they subscribe or the day resets.
                        if paywallTrigger == PaywallTrigger.freeLimit.rawValue {
                            Text("You've used today's \(UsageService.freeQuestionsPerDay) free questions. Pro continues with unlimited Scripture-cited answers.")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(AppTheme.gold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.top, 4)
                        }
                    }

                    // Features that are actually behind Pro. The six study modes and the
                    // Gospel of John plan are already included on the free plan.
                    VStack(alignment: .leading, spacing: 16) {
                        PaywallFeatureRow(icon: "infinity", text: "Unlimited Scripture-cited answers")
                        PaywallFeatureRow(icon: "book.fill", text: "A study journal you can reopen")
                        PaywallFeatureRow(icon: "text.book.closed", text: "Reading plans beyond the free Gospel of John")
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
                                    badge: annualBadge(for: annual),
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
                                    subtitle: planSubtitle(for: monthly, periodWord: "month")
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

                        if trigger == .softFirstAnswer || trigger == .softLastFree {
                            Button("Not now") {
                                recordDismissal(reason: "not_now")
                                dismiss()
                            }
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textMuted)
                        }
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
                            Text("Bible Copilot Pro (Annual): \(planSubtitle(for: annual, periodWord: "year")).")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textMuted.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        if let monthly = subscriptionService.monthlyProduct {
                            Text("Bible Copilot Pro (Monthly): \(planSubtitle(for: monthly, periodWord: "month")).")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textMuted.opacity(0.7))
                                .multilineTextAlignment(.center)
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
                selectAnnualIfNeeded()
                var properties = [
                    "source": "in_app",
                    "trigger": paywallTrigger,
                    "used": "\(UsageService.shared.usedToday)",
                    "copy_version": paywallCopyVersion,
                    "trial_eligibility": eligibilityState(for: selectedProduct),
                ]
                let reference = UsageService.shared.lastStudyReference
                if !reference.isEmpty { properties["reference"] = reference }
                AnalyticsService.shared.track(AnalyticsEvent.paywallView, properties)
                recordPlanLoadFailureIfNeeded()
            }
            .onChange(of: subscriptionService.products.count) { _, _ in
                selectAnnualIfNeeded()
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
        selectAnnualIfNeeded()
    }

    static func freeTrialDayCount(periodValue: Int, unit: Product.SubscriptionPeriod.Unit) -> Int? {
        switch unit {
        case .day: return periodValue
        case .week: return periodValue * 7
        case .month: return periodValue * 30
        case .year: return periodValue * 365
        @unknown default: return nil
        }
    }

    /// "7-Day" becomes "7 days". Week-based offers are already expanded to days
    /// by `configuredTrialLength`.
    static func spokenTrialLength(_ lengthLabel: String) -> String {
        let parts = lengthLabel.split(separator: "-")
        guard parts.count == 2, let count = Int(parts[0]) else { return lengthLabel }
        let unit = String(parts[1]).lowercased()
        let word: String
        switch unit {
        case "day": word = count == 1 ? "day" : "days"
        case "month": word = count == 1 ? "month" : "months"
        case "year": word = count == 1 ? "year" : "years"
        default: word = unit
        }
        return "\(count) \(word)"
    }

    /// "7 days free, then $49.99/year" when an eligible intro offer is visible.
    /// With no visible offer, the line is only the price StoreKit will charge.
    static func trialThenPrice(lengthLabel: String?, displayPrice: String, periodWord: String) -> String {
        guard let lengthLabel, !lengthLabel.isEmpty else {
            return "\(displayPrice)/\(periodWord)"
        }
        return "\(spokenTrialLength(lengthLabel)) free, then \(displayPrice)/\(periodWord)"
    }

    static func reassurance(lengthLabel: String?, displayPrice: String, periodWord: String) -> String {
        let offer = trialThenPrice(lengthLabel: lengthLabel, displayPrice: displayPrice, periodWord: periodWord)
        if lengthLabel != nil {
            return "\(offer). Auto-renews each \(periodWord) unless you cancel at least 24 hours before the period ends."
        }
        return "\(offer). Cancel anytime in App Store Settings."
    }

    static func annualPriceDetail(trialLine: String?, perWeek: String, perMonth: String, percentSaved: Int?) -> String {
        var lines: [String] = []
        if let trialLine, !trialLine.isEmpty {
            lines.append(trialLine)
        }
        if let percentSaved {
            lines.append("about \(perWeek)/week · \(perMonth)/month · save \(percentSaved)% vs monthly")
        } else {
            lines.append("about \(perWeek)/week · \(perMonth)/month, billed annually")
        }
        return lines.joined(separator: "\n")
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
            HStack(alignment: .top, spacing: 12) {
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
                        .fixedSize(horizontal: false, vertical: true)
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

/// Savings of annual vs paying monthly for a year. Uses the StoreKit prices, not a fixed claim.
enum PaywallPricing {
    static func percentSaved(annual: Decimal, monthly: Decimal) -> Int? {
        guard monthly > 0 else { return nil }
        let fullYear = monthly * 12
        guard fullYear > annual else { return nil }
        let savedRatio = (fullYear - annual) / fullYear
        let whole = Int(NSDecimalNumber(decimal: savedRatio * 100).doubleValue.rounded())
        return whole > 0 ? whole : nil
    }
}

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
