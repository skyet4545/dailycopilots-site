import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var streakService = StreakService.shared
    @State private var showShareSheet = false
    @State private var shareText = ""
    var onStudy: (String, StudyMode?) -> Void
    var onShowPaywall: () -> Void

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

                    // Daily Verse
                    DailyVerseCard(
                        reference: viewModel.dailyVerseRef,
                        text: viewModel.dailyVerseText,
                        isLoading: viewModel.dailyVerseLoading,
                        onStudy: {
                            onStudy(viewModel.dailyVerseRef, nil)
                        },
                        onShare: {
                            shareText = viewModel.shareText(
                                for: viewModel.dailyVerseRef,
                                text: viewModel.dailyVerseText
                            )
                            showShareSheet = true
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
                                    onStudy(pick, nil)
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
                            onStudy(viewModel.searchText.isEmpty ? "John 3:16" : viewModel.searchText, .summary)
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach([StudyMode.observe, .interpret, .theology, .apply]) { mode in
                                StudyModeCard(mode: mode) {
                                    onStudy(viewModel.searchText.isEmpty ? "John 3:16" : viewModel.searchText, mode)
                                }
                            }
                        }
                        .padding(.horizontal)

                        StudyModeCard(mode: .apologetics, isFullWidth: true) {
                            onStudy(viewModel.searchText.isEmpty ? "John 3:16" : viewModel.searchText, .apologetics)
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(AppTheme.background)
            .scrollDismissesKeyboard(.immediately)
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: [shareText])
            }
        }
        .task {
            await viewModel.loadDailyVerse()
        }
    }

    private func handleSearch() {
        if let verse = viewModel.searchVerse() {
            onStudy(verse, nil)
        }
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
