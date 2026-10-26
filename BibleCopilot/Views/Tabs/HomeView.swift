import SwiftUI

struct HomeView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(UsageService.self) private var usageService
    @State private var viewModel = HomeViewModel()
    @State private var streakService = StreakService.shared
    @State private var showShareComposer = false
    @State private var showNudgePaywall = false
    // v2.4 activation: show a one-tap "first question" hero until the user's first study.
    // 2/3 of new users were never asking a single question — this hands them an instant win.
    @AppStorage("hasCompletedFirstQuestion") private var firstStudyDone = false
    var onStudy: (String, StudyMode?) -> Void
    var onShowPaywall: () -> Void

    /// Route every study through here. The first-question hero clears only after
    /// StudyViewModel records a successful answer, not when a request merely starts.
    private func study(_ ref: String, _ mode: StudyMode?) {
        onStudy(ref, mode)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header + Streak
                    VStack(spacing: 8) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: AppTheme.gold.opacity(0.3), radius: 8, y: 4)

                        Text("Bible Copilot")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.textPrimary)

                        Text("AI-powered Bible study")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textMuted)

                        // Streak badge
                        if streakService.currentStreak > 0 {
                            StreakBadge(
                                streak: streakService.currentStreak,
                                emoji: streakService.streakEmoji,
                                studiedToday: streakService.studiedToday
                            )
                            .padding(.top, 4)
                        }
                    }
                    .padding(.top, 12)

                    if !subscriptionService.isPro {
                        FreeQuestionsStatus(
                            remaining: usageService.freeQuestionsRemaining,
                            showsLastQuestionNudge: usageService.freeQuestionsRemaining == 1,
                            onSeePro: { showNudgePaywall = true }
                        )
                        .padding(.horizontal)
                    }

                    // v2.4 first-question hero — the single clearest first action for a new user.
                    if !firstStudyDone {
                        Button {
                            study("John 3:16", .summary)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppTheme.gold)
                                    Text("New here? Start with one tap")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                }
                                HStack {
                                    Text("“What does John 3:16 really mean?”")
                                        .font(.subheadline)
                                        .italic()
                                        .foregroundColor(AppTheme.textMuted)
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundColor(AppTheme.accent)
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .background(AppTheme.surfaceLight)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                                    .stroke(AppTheme.gold.opacity(0.6), lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }

                    // Daily Verse
                    DailyVerseCard(
                        reference: viewModel.dailyVerseRef,
                        text: viewModel.dailyVerseText,
                        isLoading: viewModel.dailyVerseLoading,
                        reflection: viewModel.dailyReflection,
                        suggestedQuestion: viewModel.dailySuggestedQuestion,
                        onStudy: {
                            study(viewModel.dailyVerseRef, nil)
                        },
                        onShare: {
                            AnalyticsService.shared.track(AnalyticsEvent.shareComposerOpened)
                            showShareComposer = true
                        },
                        onAsk: {
                            let q = viewModel.dailySuggestedQuestion.isEmpty ? viewModel.dailyVerseRef : viewModel.dailySuggestedQuestion
                            study(q, nil)
                        }
                    )
                    .padding(.horizontal)

                    // Search bar
                    HStack(spacing: 12) {
                        Image(systemName: "book")
                            .foregroundColor(AppTheme.textMuted)

                        TextField("Enter any verse...", text: $viewModel.searchText)
                            .foregroundColor(AppTheme.textPrimary)
                            .submitLabel(.search)
                            .onSubmit { handleSearch() }

                        if !viewModel.searchText.isEmpty {
                            Button { handleSearch() } label: {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(AppTheme.accent)
                                    .font(.title3)
                            }
                        }
                    }
                    .padding()
                    .background(AppTheme.surfaceLight)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                            .stroke(AppTheme.surfaceBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)

                    // Quick picks
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(HomeViewModel.quickPicks, id: \.self) { pick in
                                QuickPickChip(text: pick) {
                                    study(pick, nil)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Study modes section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("HOW DO YOU WANT TO STUDY?")
                            .font(.caption.bold())
                            .foregroundColor(AppTheme.textMuted)
                            .tracking(1.2)
                            .padding(.horizontal)

                        StudyModeCard(mode: .summary, isFullWidth: true) {
                            study(viewModel.searchText.isEmpty ? "John 3:16" : viewModel.searchText, .summary)
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach([StudyMode.observe, .interpret, .theology, .apply]) { mode in
                                StudyModeCard(mode: mode) {
                                    study(viewModel.searchText.isEmpty ? "John 3:16" : viewModel.searchText, mode)
                                }
                            }
                        }
                        .padding(.horizontal)

                        StudyModeCard(mode: .apologetics, isFullWidth: true) {
                            study(viewModel.searchText.isEmpty ? "John 3:16" : viewModel.searchText, .apologetics)
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(AppTheme.background)
            .scrollDismissesKeyboard(.immediately)
            .onAppear { usageService.refreshForDisplay() }
            .sheet(isPresented: $showNudgePaywall) {
                PaywallView(trigger: .softLastFree)
            }
            .sheet(isPresented: $showShareComposer) {
                VerseShareComposerView(
                    reference: viewModel.dailyVerseRef,
                    verseText: viewModel.dailyVerseText,
                    reflection: viewModel.dailyReflection,
                    suggestedQuestion: viewModel.dailySuggestedQuestion
                )
            }
        }
        .task {
            await viewModel.loadDailyVerse()
        }
    }

    private func handleSearch() {
        if let verse = viewModel.searchVerse() {
            study(verse, nil)
        }
    }
}

// MARK: - Free question counter

struct FreeQuestionsStatus: View {
    let remaining: Int
    var showsLastQuestionNudge: Bool = false
    var onSeePro: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(UsageService.remainingQuestionsLabel(remaining: remaining))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppTheme.textPrimary)
            if showsLastQuestionNudge {
                Text("Your next answer is still free. Pro continues after that with unlimited Scripture-cited answers.")
                    .font(.caption)
                    .foregroundColor(AppTheme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                if let onSeePro {
                    Button("See Pro plans", action: onSeePro)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(remaining == 1 ? AppTheme.gold.opacity(0.12) : AppTheme.surfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(remaining == 1 ? AppTheme.gold.opacity(0.7) : AppTheme.surfaceBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

/// Inline nudge at 2 of 3 used. It does not cover the follow-up field.
struct LastFreeQuestionNudge: View {
    let onSeePro: () -> Void

    var body: some View {
        FreeQuestionsStatus(
            remaining: 1,
            showsLastQuestionNudge: true,
            onSeePro: onSeePro
        )
    }
}

// MARK: - Activity View (reliable share sheet for iMessage/social)

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        // Exclude irrelevant actions
        controller.excludedActivityTypes = [.assignToContact, .addToReadingList]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Legacy alias
typealias ShareSheet = ActivityView
