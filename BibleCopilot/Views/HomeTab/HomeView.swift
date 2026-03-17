import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var navigateToStudy = false
    @State private var selectedVerse = ""
    @State private var selectedMode: StudyMode?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    // Header
                    VStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.accent)

                        Text("Bible Copilot")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Your AI Bible study companion")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(.top, AppTheme.spacingXL)

                    // Search Bar
                    HStack(spacing: AppTheme.spacingMD) {
                        Image(systemName: "book.fill")
                            .foregroundColor(AppTheme.textMuted)
                        TextField("Enter any verse...", text: $viewModel.searchText)
                            .foregroundColor(AppTheme.textPrimary)
                            .onSubmit {
                                if !viewModel.searchText.isEmpty {
                                    selectedVerse = viewModel.searchText
                                    selectedMode = nil
                                    navigateToStudy = true
                                }
                            }
                    }
                    .padding(AppTheme.spacingMD)
                    .background(AppTheme.surfaceLight)
                    .cornerRadius(AppTheme.cornerRadiusSM)
                    .padding(.horizontal, AppTheme.spacingLG)

                    // Verse of the Day
                    if let verse = viewModel.verseOfTheDay {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            HStack {
                                Text("Verse of the Day")
                                    .font(AppTheme.labelFont)
                                    .foregroundColor(AppTheme.gold)
                                    .textCase(.uppercase)
                                Spacer()
                            }

                            Text(verse.text)
                                .font(AppTheme.scriptureFont)
                                .foregroundColor(AppTheme.textPrimary)
                                .lineSpacing(6)

                            Text("— \(verse.reference)")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .padding(AppTheme.spacingLG)
                        .background(AppTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                                .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(AppTheme.cornerRadiusMD)
                        .padding(.horizontal, AppTheme.spacingLG)
                        .onTapGesture {
                            selectedVerse = verse.reference
                            selectedMode = nil
                            navigateToStudy = true
                        }
                    } else if viewModel.isLoadingVerse {
                        ProgressView()
                            .tint(AppTheme.accent)
                            .padding()
                    }

                    // Quick Picks
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text("Popular Passages")
                            .font(AppTheme.sectionFont)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal, AppTheme.spacingLG)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.spacingMD) {
                                ForEach(viewModel.quickPicks, id: \.self) { pick in
                                    Button {
                                        selectedVerse = pick
                                        selectedMode = nil
                                        navigateToStudy = true
                                    } label: {
                                        Text(pick)
                                            .font(AppTheme.captionFont)
                                            .foregroundColor(AppTheme.accent)
                                            .padding(.horizontal, AppTheme.spacingMD)
                                            .padding(.vertical, AppTheme.spacingSM)
                                            .background(AppTheme.accent.opacity(0.15))
                                            .cornerRadius(AppTheme.cornerRadiusSM)
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.spacingLG)
                        }
                    }

                    // Study Modes
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text("How do you want to study?")
                            .font(AppTheme.sectionFont)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal, AppTheme.spacingLG)
                            .textCase(.uppercase)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: AppTheme.spacingMD),
                            GridItem(.flexible(), spacing: AppTheme.spacingMD)
                        ], spacing: AppTheme.spacingMD) {
                            ForEach(StudyMode.allCases.prefix(4)) { mode in
                                StudyModeCard(mode: mode) {
                                    selectedMode = mode
                                    if !viewModel.searchText.isEmpty {
                                        selectedVerse = viewModel.searchText
                                    } else {
                                        selectedVerse = viewModel.quickPicks.first ?? "John 3:16"
                                    }
                                    navigateToStudy = true
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingLG)

                        // Apologetics full-width
                        if let apologetics = StudyMode.allCases.last {
                            StudyModeCard(mode: apologetics) {
                                selectedMode = apologetics
                                if !viewModel.searchText.isEmpty {
                                    selectedVerse = viewModel.searchText
                                } else {
                                    selectedVerse = viewModel.quickPicks.first ?? "John 3:16"
                                }
                                navigateToStudy = true
                            }
                            .padding(.horizontal, AppTheme.spacingLG)
                        }
                    }

                    Spacer(minLength: AppTheme.spacing3XL)
                }
            }
            .background(AppTheme.background)
            .navigationDestination(isPresented: $navigateToStudy) {
                StudyView(initialReference: selectedVerse, initialMode: selectedMode)
            }
            .task {
                await viewModel.loadVerseOfTheDay()
            }
        }
    }
}

struct StudyModeCard: View {
    let mode: StudyMode
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(mode.color)

                Text(mode.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(mode.subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textMuted)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppTheme.spacingMD)
            .background(AppTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM)
                    .stroke(mode.color.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(AppTheme.cornerRadiusSM)
        }
    }
}
