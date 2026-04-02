import SwiftUI
import StoreKit

struct OnboardingView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var currentStep = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedPlanId: String = ""

    // Personalization state
    @State private var selectedGoals: Set<String> = []
    @State private var selectedLevel: ExperienceLevel?

    // Aha moment state
    @State private var ahaInsight: String?
    @State private var isLoadingInsight = false
    @State private var selectedAhaVerse: String = "John 1:1"

    let onComplete: () -> Void

    private let slides = OnboardingSlide.slides

    // Flow: 3 slides + goals + experience + aha moment + paywall = 7 steps
    private let goalStep = 3
    private let experienceStep = 4
    private let ahaStep = 5
    private let paywallStep = 6
    private var totalSteps: Int { 7 }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    if currentStep > 0 && currentStep != paywallStep {
                        Button {
                            withAnimation { currentStep -= 1 }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.body.bold())
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .padding()
                    }
                    Spacer()
                    if currentStep < paywallStep {
                        Button("Skip") {
                            onComplete()
                        }
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                        .padding()
                    }
                }
                .frame(height: 44)

                // Progress bar
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                // Content
                Group {
                    if currentStep < slides.count {
                        normalSlideView
                    } else if currentStep == goalStep {
                        goalSelectionView
                    } else if currentStep == experienceStep {
                        experienceLevelView
                    } else if currentStep == ahaStep {
                        ahaMomentView
                    } else if currentStep == paywallStep {
                        paywallSlideView
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
        .task {
            if subscriptionService.products.isEmpty {
                await subscriptionService.loadProducts()
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.textMuted.opacity(0.15))
                    .frame(height: 4)

                Capsule()
                    .fill(AppTheme.goldGradient)
                    .frame(width: geo.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Normal Slide

    private var normalSlideView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                let slide = slides[currentStep]

                if currentStep == 0 {
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

            Spacer()

            continueButton {
                currentStep += 1
            }
        }
    }

    // MARK: - Study Goal Selection

    private var goalSelectionView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "target")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.gold)

                Text("What do you want\nto explore?")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.bottom, 24)

            VStack(spacing: 10) {
                ForEach(StudyGoal.goals) { goal in
                    Button {
                        if selectedGoals.contains(goal.id) {
                            selectedGoals.remove(goal.id)
                        } else {
                            selectedGoals.insert(goal.id)
                        }
                        HapticService.lightImpact()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: goal.icon)
                                .font(.system(size: 18))
                                .foregroundColor(selectedGoals.contains(goal.id) ? .white : AppTheme.gold)
                                .frame(width: 28)

                            Text(goal.label)
                                .font(.subheadline)
                                .foregroundColor(selectedGoals.contains(goal.id) ? .white : AppTheme.textPrimary)

                            Spacer()

                            if selectedGoals.contains(goal.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(selectedGoals.contains(goal.id) ? AppTheme.accentDark : AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedGoals.contains(goal.id) ? AppTheme.accent : AppTheme.cardBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            continueButton(disabled: selectedGoals.isEmpty) {
                // Save goals
                UserDefaults.standard.set(Array(selectedGoals), forKey: "onboarding_goals")
                currentStep += 1
            }
        }
    }

    // MARK: - Experience Level

    private var experienceLevelView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "person.fill.questionmark")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "A78BFA"))

                Text("How would you describe\nyour Bible study?")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("This helps personalize your experience")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.bottom, 32)

            VStack(spacing: 12) {
                ForEach(ExperienceLevel.allCases) { level in
                    Button {
                        selectedLevel = level
                        HapticService.lightImpact()
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: level.icon)
                                .font(.system(size: 22))
                                .foregroundColor(selectedLevel == level ? .white : AppTheme.gold)
                                .frame(width: 32)

                            Text(level.label)
                                .font(.headline)
                                .foregroundColor(selectedLevel == level ? .white : AppTheme.textPrimary)

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(selectedLevel == level ? AppTheme.accentDark : AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedLevel == level ? AppTheme.accent : AppTheme.cardBorder, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            continueButton(disabled: selectedLevel == nil) {
                // Save experience level
                if let level = selectedLevel {
                    UserDefaults.standard.set(level.rawValue, forKey: "onboarding_experience")
                }
                currentStep += 1
            }
        }
    }

    // MARK: - Aha Moment (Free AI Insight)

    private let ahaVerses = [
        "John 1:1", "Genesis 1:1", "Psalm 23:1",
        "Romans 8:28", "Philippians 4:13", "Jeremiah 29:11"
    ]

    private var ahaMomentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer().frame(height: 16)

                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundColor(AppTheme.gold)

                    Text("See it in action")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Pick a verse and get a free AI insight")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                }

                // Verse chips
                OnboardingFlowLayout(spacing: 8) {
                    ForEach(ahaVerses, id: \.self) { verse in
                        Button {
                            selectedAhaVerse = verse
                            ahaInsight = nil
                            HapticService.lightImpact()
                        } label: {
                            Text(verse)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedAhaVerse == verse ? AppTheme.accentDark : AppTheme.cardBackground)
                                .foregroundColor(selectedAhaVerse == verse ? .white : AppTheme.textPrimary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(selectedAhaVerse == verse ? AppTheme.accent : AppTheme.cardBorder, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)

                // Generate insight button
                if ahaInsight == nil {
                    Button {
                        generateAhaInsight()
                    } label: {
                        HStack(spacing: 8) {
                            if isLoadingInsight {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "sparkle")
                                Text("Show me an insight")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                    .disabled(isLoadingInsight)
                }

                // Insight result
                if let insight = ahaInsight {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(AppTheme.gold)
                            Text(selectedAhaVerse)
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Text(insight)
                            .font(.body)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineSpacing(4)

                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(AppTheme.gold)
                                .font(.caption)
                            Text("This is just one of the insights Bible Copilot can surface.")
                                .font(.caption)
                                .foregroundColor(AppTheme.textMuted)
                                .italic()
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer().frame(height: 20)

                // Continue to paywall
                if ahaInsight != nil {
                    continueButtonInline(label: "Unlock Unlimited Study") {
                        currentStep += 1
                    }
                }

                Spacer().frame(height: 40)
            }
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

                // Skip
                Button {
                    onComplete()
                } label: {
                    Text("Continue with 15 free questions/day")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                        .underline()
                }
                .padding(.top, 4)

                // Legal
                VStack(spacing: 4) {
                    Text("No charge today. Cancel anytime before your trial ends.")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textMuted.opacity(0.7))

                    HStack(spacing: 12) {
                        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(.caption2)
                            .foregroundColor(AppTheme.accent.opacity(0.7))
                        Link("Privacy Policy", destination: URL(string: "https://mybiblecopilot.com/privacy")!)
                            .font(.caption2)
                            .foregroundColor(AppTheme.accent.opacity(0.7))
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Shared Components

    private func continueButton(disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticService.lightImpact()
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(disabled ? AnyShapeStyle(AppTheme.textMuted.opacity(0.3)) : AnyShapeStyle(AppTheme.goldGradient))
                )
        }
        .disabled(disabled)
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    private func continueButtonInline(label: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticService.lightImpact()
        } label: {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.goldGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 24)
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

    // MARK: - Aha Moment AI Call

    private func generateAhaInsight() {
        isLoadingInsight = true
        Task {
            let prompt = """
            You are a Bible study assistant. Give ONE surprising, lesser-known insight about \(selectedAhaVerse). \
            Focus on original language meaning, historical context, or a cross-reference most people miss. \
            Keep it under 80 words. Be specific and scholarly yet accessible. Do not use bullet points.
            """

            // Use the app's existing AI service for one free call
            if let insight = await fetchOnboardingInsight(prompt: prompt) {
                withAnimation {
                    ahaInsight = insight
                }
                HapticService.success()
            } else {
                // Fallback — use a pre-written insight
                withAnimation {
                    ahaInsight = getPrewrittenInsight(for: selectedAhaVerse)
                }
            }
            isLoadingInsight = false
        }
    }

    private func fetchOnboardingInsight(prompt: String) async -> String? {
        // Use the app's existing backend
        guard let url = URL(string: "https://scripture-copilot-rust.vercel.app/api/chat") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return nil }

            // Parse streaming SSE response — collect all chunks
            let responseStr = String(data: data, encoding: .utf8) ?? ""
            var fullContent = ""
            for line in responseStr.components(separatedBy: "\n") {
                if line.hasPrefix("data: "), line != "data: [DONE]" {
                    let jsonStr = String(line.dropFirst(6))
                    if let chunkData = jsonStr.data(using: .utf8),
                       let chunk = try? JSONSerialization.jsonObject(with: chunkData) as? [String: Any],
                       let choices = chunk["choices"] as? [[String: Any]],
                       let delta = choices.first?["delta"] as? [String: Any],
                       let content = delta["content"] as? String {
                        fullContent += content
                    }
                }
            }
            return fullContent.isEmpty ? nil : fullContent.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {}
        return nil
    }

    private func getPrewrittenInsight(for verse: String) -> String {
        switch verse {
        case "John 1:1":
            return "The Greek word \"Logos\" (Word) carried deep meaning in both Jewish and Greek thought. In Jewish tradition, God's Word was His creative power. In Greek philosophy, Logos was the rational principle ordering the universe. John brilliantly bridges both worlds, declaring Jesus as the divine creative intelligence behind all reality."
        case "Genesis 1:1":
            return "The Hebrew \"bara\" (created) is used exclusively for God's creative acts — humans never \"bara\" anything. The word \"Elohim\" is grammatically plural with a singular verb, hinting at plurality within unity that later theology would identify as the Trinity."
        case "Psalm 23:1":
            return "David chose \"shepherd\" deliberately. In the ancient Near East, kings called themselves shepherds of their people. By calling God his shepherd, David was declaring the LORD as the true King — a radical statement from an actual king of Israel."
        case "Romans 8:28":
            return "The Greek \"synergei\" (works together) is where we get \"synergy.\" Paul's point isn't that each event is good, but that God weaves all events into a coherent tapestry. The verb is present tense — God is actively working right now, not just at the end."
        case "Philippians 4:13":
            return "\"I can do all things\" is often quoted for personal achievement, but the Greek \"ischyo\" means \"I have strength to endure.\" In context, Paul is talking about contentment in poverty and abundance — not athletic victories or career success."
        default:
            return "The Hebrew word \"shalom\" in Jeremiah 29:11 (translated \"welfare\" or \"peace\") means far more than absence of conflict. It encompasses completeness, wholeness, and flourishing in every dimension — spiritual, relational, physical, and material."
        }
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

// MARK: - Flow Layout (for verse chips)

struct OnboardingFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
