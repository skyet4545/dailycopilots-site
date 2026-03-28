import SwiftUI
import StoreKit

struct OnboardingView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var currentSlide = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedPlanId: String = "" // empty = annual (default)
    let onComplete: () -> Void

    private let slides = OnboardingSlide.slides
    private var totalPages: Int { slides.count + 1 } // +1 for paywall slide
    private var isPaywallSlide: Bool { currentSlide == slides.count }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip / Continue Free button
                HStack {
                    Spacer()
                    if !isPaywallSlide && currentSlide < slides.count - 1 {
                        Button("Skip") {
                            onComplete()
                        }
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                        .padding()
                    }
                }
                .frame(height: 44)

                if isPaywallSlide {
                    // MARK: - Paywall Slide (Slide 6)
                    paywallSlideView
                } else {
                    // MARK: - Normal Onboarding Slides (1-5)
                    normalSlideView
                }
            }
        }
        .task {
            // Pre-load products during onboarding so paywall is ready
            if subscriptionService.products.isEmpty {
                await subscriptionService.loadProducts()
            }
        }
    }

    // MARK: - Normal Slide

    private var normalSlideView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                let slide = slides[currentSlide]

                if currentSlide == 0 {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .shadow(color: AppTheme.gold.opacity(0.3), radius: 10, y: 4)
                } else {
                    Circle()
                        .fill(slide.iconColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: slide.icon)
                                .font(.system(size: 40))
                                .foregroundColor(slide.iconColor)
                        )
                }

                Text(slide.title)
                    .font(.title.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(slide.subtitle)
                    .font(.body)
                    .foregroundColor(AppTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .animation(.easeInOut(duration: 0.3), value: currentSlide)

            Spacer()

            // Dot indicators
            dotIndicators

            // Continue button
            Button {
                currentSlide += 1
                HapticService.lightImpact()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Paywall Slide

    private var paywallSlideView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppTheme.gold.opacity(0.3), radius: 8, y: 4)

                    Text("Try Bible Copilot\nFree for 7 Days")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Then unlock unlimited Scripture study")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                }
                .padding(.top, 8)

                // Trial timeline
                VStack(spacing: 0) {
                    trialTimelineRow(
                        day: "Today",
                        label: "Full access — explore all study modes",
                        icon: "checkmark.circle.fill",
                        color: AppTheme.success
                    )
                    trialTimelineRow(
                        day: "Day 5",
                        label: "Reminder before trial ends",
                        icon: "bell.fill",
                        color: AppTheme.gold
                    )
                    trialTimelineRow(
                        day: "Day 7",
                        label: "Trial ends — only charged if you stay",
                        icon: "calendar",
                        color: AppTheme.accent,
                        isLast: true
                    )
                }
                .padding(.horizontal, 32)

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    onboardingFeatureRow(icon: "infinity", text: "Unlimited questions & answers")
                    onboardingFeatureRow(icon: "book.fill", text: "All 5 study modes")
                    onboardingFeatureRow(icon: "bookmark.fill", text: "Save to your study journal")
                    onboardingFeatureRow(icon: "text.book.closed", text: "Guided reading plans")
                }
                .padding(.horizontal, 32)

                // Plan cards
                if let annual = subscriptionService.annualProduct {
                    VStack(spacing: 10) {
                        // Annual — default selected
                        Button {
                            selectedPlanId = annual.id
                        } label: {
                            onboardingPlanCard(
                                title: "Annual",
                                price: annual.displayPrice + "/year",
                                subtitle: "7-day free trial included",
                                badge: "BEST VALUE",
                                isSelected: selectedPlanId == annual.id || selectedPlanId.isEmpty
                            )
                        }
                        .buttonStyle(.plain)

                        // Monthly
                        if let monthly = subscriptionService.monthlyProduct {
                            Button {
                                selectedPlanId = monthly.id
                            } label: {
                                onboardingPlanCard(
                                    title: "Monthly",
                                    price: monthly.displayPrice + "/month",
                                    subtitle: "Billed monthly",
                                    badge: nil,
                                    isSelected: selectedPlanId == monthly.id
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // CTA
                Button {
                    purchaseSelectedPlan()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(selectedPlanId == subscriptionService.monthlyProductID
                                 ? "Subscribe Monthly"
                                 : "Start Free Trial")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .disabled(isLoading || subscriptionService.products.isEmpty)

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(AppTheme.error)
                }

                // Skip — Continue Free
                Button {
                    onComplete()
                } label: {
                    Text("Continue with 15 free questions/day")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                        .underline()
                }
                .padding(.top, 4)

                // Dot indicators
                dotIndicators
                    .padding(.top, 8)

                // Legal
                VStack(spacing: 4) {
                    Text("No charge today. Cancel anytime before your trial ends.")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textMuted.opacity(0.7))

                    HStack(spacing: 12) {
                        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(.caption2)
                            .foregroundColor(AppTheme.accent.opacity(0.7))
                        Link("Privacy Policy", destination: URL(string: "https://biblecopilot-app.netlify.app/privacy")!)
                            .font(.caption2)
                            .foregroundColor(AppTheme.accent.opacity(0.7))
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Trial Timeline Row

    private func trialTimelineRow(day: String, label: String, icon: String, color: Color, isLast: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 28, height: 28)

                if !isLast {
                    Rectangle()
                        .fill(AppTheme.cardBorder)
                        .frame(width: 2, height: 28)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(day)
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.textPrimary)
                Text(label)
                    .font(.caption)
                    .foregroundColor(AppTheme.textMuted)
            }

            Spacer()
        }
    }

    // MARK: - Feature Row

    private func onboardingFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.gold)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary)
        }
    }

    // MARK: - Plan Card

    private func onboardingPlanCard(title: String, price: String, subtitle: String, badge: String?, isSelected: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                    if let badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(AppTheme.gold)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppTheme.textMuted)
            }
            Spacer()
            Text(price)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
        }
        .padding(14)
        .background(isSelected ? AppTheme.accentDark : AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AppTheme.accent : AppTheme.cardBorder, lineWidth: isSelected ? 2 : 1)
        )
    }

    // MARK: - Dot Indicators

    private var dotIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentSlide ? AppTheme.accent : AppTheme.textMuted.opacity(0.3))
                    .frame(width: index == currentSlide ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentSlide)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Purchase

    private func purchaseSelectedPlan() {
        let product: Product?
        if selectedPlanId == subscriptionService.monthlyProductID {
            product = subscriptionService.monthlyProduct
        } else {
            product = subscriptionService.annualProduct
        }
        guard let product else { return }

        Task {
            isLoading = true
            errorMessage = nil
            do {
                try await subscriptionService.purchase(product)
                if subscriptionService.isPro {
                    HapticService.success()
                    onComplete()
                }
            } catch {
                errorMessage = "Something went wrong. Try again."
            }
            isLoading = false
        }
    }
}
