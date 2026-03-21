import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    var onStudy: (String, StudyMode?) -> Void
    var onShowPaywall: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: AppTheme.gold.opacity(0.3), radius: 8, y: 4)

                        Text("Bible Copilot")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.textPrimary)

                        Text("AI-powered Bible study")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(.top, 20)

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

                        // 2x2 grid
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

                        // Full-width Apologetics card
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
        }
    }

    private func handleSearch() {
        if let verse = viewModel.searchVerse() {
            onStudy(verse, nil)
        }
    }
}
