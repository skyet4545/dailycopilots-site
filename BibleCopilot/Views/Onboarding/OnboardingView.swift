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
    @State private var selectedDenomination: Denomination?
    @State private var selectedAttribution: AttributionSource?
    @State private var selectedTranslation: BibleTranslation?
    @State private var selectedStruggles: Set<String> = []
    @State private var planBuildProgress: Double = 0
    @State private var planBuildDone = false

    // Aha moment state
    @State private var ahaInsight: String?
    @State private var isLoadingInsight = false
    @State private var selectedAhaVerse: String = "John 1:1"

    // Notification step state
    @State private var notificationRequested = false
    @AppStorage("dailyReminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 8
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    let onComplete: () -> Void

    private let slides = OnboardingSlide.slides

    // Flow: welcome → quiz (denomination, translation, goals, struggles, experience)
    // → building plan → aha moment → notifications → social proof → paywall
    private let welcomeStep = 0
    private let denominationStep = 1
    private let attributionStep = 2
    private let translationStep = 3
    private let goalStep = 4
    private let struggleStep = 5
    private let experienceStep = 6
    private let buildPlanStep = 7
    private let ahaStep = 8
    private let notificationStep = 9
    private let socialProofStep = 10
    private let paywallStep = 11
    private var totalSteps: Int { 12 }

    // v2.4: the live flow is welcome → aha → app. Progress reflects that 2-screen journey
    // (the quiz/notification/social-proof/onboarding-paywall steps are no longer in the path).
    private var flowProgress: Double {
        currentStep == welcomeStep ? 0.5 : 1.0
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    if currentStep > 0 && currentStep != paywallStep && currentStep != buildPlanStep {
                        Button {
                            // v2.4 flow is welcome → aha → attribution → app (the 6-question quiz is
                            // skipped), so a plain `currentStep -= 1` would land the user on an abandoned
                            // quiz screen. Map back moves explicitly along the real flow.
                            withAnimation {
                                switch currentStep {
                                case ahaStep: currentStep = welcomeStep
                                case attributionStep: currentStep = ahaStep
                                default: currentStep = welcomeStep
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.body.bold())
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .padding()
                    }
                    Spacer()
                }
                .frame(height: 44)

                // Progress bar
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                // Content
                Group {
                    if currentStep == welcomeStep {
                        normalSlideView
                    } else if currentStep == denominationStep {
                        denominationView
                    } else if currentStep == attributionStep {
                        attributionView
                    } else if currentStep == translationStep {
                        translationView
                    } else if currentStep == goalStep {
                        goalSelectionView
                    } else if currentStep == struggleStep {
                        struggleSelectionView
                    } else if currentStep == experienceStep {
                        experienceLevelView
                    } else if currentStep == buildPlanStep {
                        buildingPlanView
                    } else if currentStep == ahaStep {
                        ahaMomentView
                    } else if currentStep == notificationStep {
                        notificationAskView
                    } else if currentStep == socialProofStep {
                        socialProofView
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
            AnalyticsService.shared.track(AnalyticsEvent.onboardingStep, ["step": "welcome"])
            if subscriptionService.products.isEmpty {
                await subscriptionService.loadProducts()
            }
        }
        .onChange(of: currentStep) { _, newStep in
            AnalyticsService.shared.track(AnalyticsEvent.onboardingStep, ["step": stepName(newStep)])
            if newStep == buildPlanStep { runPlanBuild() }
            if newStep == paywallStep {
                AnalyticsService.shared.track(AnalyticsEvent.paywallView, ["source": "onboarding"])
            }
        }
    }

    /// Finish onboarding and enter the app. v2.4: onboarding now ends at the aha moment
    /// (welcome → value → app), so this is the single completion path for the free flow.
    private func completeOnboarding(pro: Bool) {
        AnalyticsService.shared.track(AnalyticsEvent.onboardingComplete, ["pro": pro ? "true" : "false"])
        onComplete()
    }

    private func stepName(_ step: Int) -> String {
        switch step {
        case welcomeStep: return "welcome"
        case denominationStep: return "denomination"
        case attributionStep: return "attribution"
        case translationStep: return "translation"
        case goalStep: return "goals"
        case struggleStep: return "struggles"
        case experienceStep: return "experience"
        case buildPlanStep: return "build_plan"
        case ahaStep: return "aha_moment"
        case notificationStep: return "notifications"
        case socialProofStep: return "social_proof"
        case paywallStep: return "paywall"
        default: return "step_\(step)"
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
                    .frame(width: geo.size.width * flowProgress, height: 4)
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
                // v2.4: skip the 6-question quiz (write-only, never personalizes answers) and the
                // mid-onboarding paywall. Go straight to the value moment — getting users to their
                // first insight fast is the #1 activation lever (2/3 were dropping before asking anything).
                withAnimation { currentStep = ahaStep }
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
                AnalyticsService.shared.track(AnalyticsEvent.quizAnswer, ["question": "goals", "answer": selectedGoals.sorted().joined(separator: ",")])
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
                    AnalyticsService.shared.track(AnalyticsEvent.quizAnswer, ["question": "experience", "answer": level.rawValue])
                }
                currentStep += 1
            }
        }
    }

    // MARK: - Denomination

    private var denominationView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Image(systemName: "building.columns")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.gold)

                Text("What's your church\nbackground?")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Answers stay denominationally respectful either way")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.top, 12)
            .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(Denomination.options) { option in
                        quizRow(
                            icon: option.icon,
                            label: option.label,
                            isSelected: selectedDenomination == option
                        ) {
                            selectedDenomination = option
                            HapticService.lightImpact()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }

            continueButton(disabled: selectedDenomination == nil) {
                if let d = selectedDenomination {
                    UserDefaults.standard.set(d.id, forKey: "onboarding_denomination")
                    AnalyticsService.shared.track(AnalyticsEvent.quizAnswer, ["question": "denomination", "answer": d.id])
                }
                currentStep += 1
            }
        }
    }

    // MARK: - Attribution ("How did you hear about us?")

    private var attributionView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Image(systemName: "hand.wave.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.gold)

                Text("How did you hear\nabout us?")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("This helps us reach more people like you")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.top, 12)
            .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(AttributionSource.sources) { option in
                        quizRow(
                            icon: option.icon,
                            label: option.label,
                            isSelected: selectedAttribution == option
                        ) {
                            selectedAttribution = option
                            HapticService.lightImpact()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }

            // Last step: saving the answer completes onboarding straight into the app.
            continueButton(disabled: selectedAttribution == nil) {
                if let a = selectedAttribution {
                    UserDefaults.standard.set(a.id, forKey: "onboarding_heard_about")
                    AnalyticsService.shared.track(AnalyticsEvent.quizAnswer, ["question": "heard_about", "answer": a.id])
                }
                completeOnboarding(pro: false)
            }

            // Attribution is optional — never trap the user here.
            Button {
                completeOnboarding(pro: false)
            } label: {
                Text("Skip")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textMuted)
                    .underline()
            }
            .padding(.bottom, 24)
        }
    }

    // MARK: - Translation

    private var translationView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Image(systemName: "character.book.closed")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "A78BFA"))

                Text("Which Bible translation\ndo you prefer?")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 12)
            .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(BibleTranslation.options) { option in
                        Button {
                            selectedTranslation = option
                            HapticService.lightImpact()
                        } label: {
                            HStack(spacing: 14) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.label)
                                        .font(.subheadline.bold())
                                        .foregroundColor(selectedTranslation == option ? .white : AppTheme.textPrimary)
                                    Text(option.blurb)
                                        .font(.caption)
                                        .foregroundColor(selectedTranslation == option ? .white.opacity(0.8) : AppTheme.textMuted)
                                }
                                Spacer()
                                if selectedTranslation == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(selectedTranslation == option ? AppTheme.accentDark : AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedTranslation == option ? AppTheme.accent : AppTheme.cardBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }

            continueButton(disabled: selectedTranslation == nil) {
                if let t = selectedTranslation {
                    UserDefaults.standard.set(t.id == "unsure" ? "KJV" : t.id, forKey: "onboarding_translation")
                    AnalyticsService.shared.track(AnalyticsEvent.quizAnswer, ["question": "translation", "answer": t.id])
                }
                currentStep += 1
            }
        }
    }

    // MARK: - Life Struggles

    private var struggleSelectionView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "F87171"))

                Text("What's weighing on\nyou lately?")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Scripture speaks to all of it — select any")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.top, 12)
            .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(LifeStruggle.options) { option in
                        quizRow(
                            icon: option.icon,
                            label: option.label,
                            isSelected: selectedStruggles.contains(option.id)
                        ) {
                            if selectedStruggles.contains(option.id) {
                                selectedStruggles.remove(option.id)
                            } else {
                                selectedStruggles.insert(option.id)
                            }
                            HapticService.lightImpact()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }

            continueButton(disabled: selectedStruggles.isEmpty) {
                UserDefaults.standard.set(Array(selectedStruggles), forKey: "onboarding_struggles")
                AnalyticsService.shared.track(AnalyticsEvent.quizAnswer, ["question": "struggles", "answer": selectedStruggles.sorted().joined(separator: ",")])
                currentStep += 1
            }
        }
    }

    private func quizRow(icon: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .white : AppTheme.gold)
                    .frame(width: 28)

                Text(label)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : AppTheme.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? AppTheme.accentDark : AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.accent : AppTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Building Your Plan

    private var buildingPlanView: some View {
        VStack(spacing: 0) {
            Spacer()

            if !planBuildDone {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(AppTheme.textMuted.opacity(0.15), lineWidth: 8)
                            .frame(width: 110, height: 110)
                        Circle()
                            .trim(from: 0, to: planBuildProgress)
                            .stroke(AppTheme.goldGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 110, height: 110)
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(planBuildProgress * 100))%")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    Text("Building your study plan…")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 52))
                        .foregroundColor(AppTheme.success)

                    Text("Your plan is ready")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)

                    VStack(alignment: .leading, spacing: 12) {
                        planSummaryRow(icon: "character.book.closed",
                                       text: "\(UserDefaults.standard.string(forKey: "onboarding_translation") ?? "KJV") translation")
                        if let d = selectedDenomination {
                            planSummaryRow(icon: d.icon, text: "\(d.label) perspective, handled with care")
                        }
                        if !selectedStruggles.isEmpty {
                            planSummaryRow(icon: "heart.fill",
                                           text: "Verses for \(selectedStruggles.count) area\(selectedStruggles.count == 1 ? "" : "s") of your life")
                        }
                        planSummaryRow(icon: "book.fill", text: "6 guided study modes")
                    }
                    .padding(18)
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 32)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            Spacer()

            if planBuildDone {
                continueButton {
                    currentStep += 1
                }
            }
        }
    }

    private func planSummaryRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.gold)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
        }
    }

    private func runPlanBuild() {
        planBuildProgress = 0
        planBuildDone = false
        Task {
            for i in 1...20 {
                try? await Task.sleep(for: .milliseconds(90))
                withAnimation(.linear(duration: 0.09)) {
                    planBuildProgress = Double(i) / 20.0
                }
            }
            withAnimation(.spring(duration: 0.4)) {
                planBuildDone = true
            }
            HapticService.success()
        }
    }

    // MARK: - Social Proof

    private var socialProofView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.gold)

                Text("Built for serious study")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)

                VStack(alignment: .leading, spacing: 16) {
                    socialProofRow(icon: "graduationcap.fill",
                                   title: "Seminary-grade method",
                                   detail: "The same inductive framework taught in seminaries: Observe, Interpret, Theology, Apply, Apologetics.")
                    socialProofRow(icon: "quote.opening",
                                   title: "Every answer cites Scripture",
                                   detail: "Verse-anchored responses with cross-references — never vague spiritual advice.")
                    socialProofRow(icon: "person.2.fill",
                                   title: "Denominationally humble",
                                   detail: "On contested doctrine, you get the major views fairly presented — not one tradition's spin.")
                }
                .padding(.horizontal, 28)
            }

            Spacer()

            continueButton {
                currentStep += 1
            }
        }
    }

    private func socialProofRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.gold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.textPrimary)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(AppTheme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
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

                // v2.4: after the aha insight, ask the one attribution question (how they heard about
                // us), then drop straight into the app so they can ask their OWN first question. No
                // mid-onboarding paywall — monetization happens value-first, at the 3-question limit.
                // (The old "Unlock Unlimited Study" label was a dead button: it just advanced to the
                // notifications screen, unlocking nothing.)
                if ahaInsight != nil {
                    continueButtonInline(label: "Start studying — it's free") {
                        withAnimation { currentStep = attributionStep }
                    }
                }

                // Always-available exit so a failed insight can never trap the user on the last step.
                Button {
                    completeOnboarding(pro: false)
                } label: {
                    Text(ahaInsight != nil ? "Maybe later" : "Skip for now")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                        .underline()
                }
                .padding(.top, 4)

                Spacer().frame(height: 40)
            }
        }
    }

    // MARK: - Notification Ask

    private var notificationAskView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.gold.opacity(0.15))
                        .frame(width: 100, height: 100)
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 42))
                        .foregroundColor(AppTheme.gold)
                }

                VStack(spacing: 10) {
                    Text("Build Your Daily Habit")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("People who study Scripture daily remember 3× more. Get a gentle reminder so you never miss a day.")
                        .font(.body)
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Stats row
                HStack(spacing: 0) {
                    statPill(icon: "flame.fill", label: "Builds streaks", color: AppTheme.gold)
                    statPill(icon: "clock.fill", label: "Your chosen time", color: AppTheme.accent)
                    statPill(icon: "bell.slash.fill", label: "Cancel anytime", color: AppTheme.textMuted)
                }
                .padding(.horizontal, 16)
            }

            Spacer()

            VStack(spacing: 12) {
                // Primary CTA
                Button {
                    Task {
                        let granted = await NotificationService.shared.requestPermission()
                        if granted {
                            reminderEnabled = true
                            NotificationService.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                            HapticService.success()
                        }
                        notificationRequested = true
                        withAnimation { currentStep += 1 }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                        Text("Enable Daily Reminder")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)

                // Skip
                Button {
                    withAnimation { currentStep += 1 }
                } label: {
                    Text("Skip for now")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                }
            }
            .padding(.bottom, 40)
        }
    }

    private func statPill(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
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
                    AnalyticsService.shared.track(AnalyticsEvent.onboardingComplete, ["pro": "false"])
                    onComplete()
                } label: {
                    Text("Continue with 3 free questions/day")
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
            AnalyticsService.shared.track(AnalyticsEvent.trialStartTap, ["product": product.id])
            do {
                try await subscriptionService.purchase(product)
                if subscriptionService.isPro {
                    AnalyticsService.shared.track(AnalyticsEvent.purchaseSuccess, ["product": product.id, "source": "onboarding"])
                    AnalyticsService.shared.track(AnalyticsEvent.onboardingComplete, ["pro": "true"])
                    HapticService.success()
                    onComplete()
                }
            } catch {
                AnalyticsService.shared.track(AnalyticsEvent.purchaseFailed, ["product": product.id, "error": String(describing: error).prefix(120).description])
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
