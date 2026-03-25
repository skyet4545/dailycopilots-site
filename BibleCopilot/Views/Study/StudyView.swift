import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var viewModel: StudyViewModel
    @State private var showShareSheet = false

    let onShowPaywall: () -> Void

    init(verse: String, initialMode: StudyMode?, onShowPaywall: @escaping () -> Void) {
        _viewModel = State(initialValue: StudyViewModel(verse: verse, initialMode: initialMode))
        self.onShowPaywall = onShowPaywall
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Verse Card
                    VerseCardView(
                        reference: viewModel.verse,
                        text: viewModel.verseText,
                        isLoading: viewModel.verseLoading,
                        isBookmarked: viewModel.isBookmarked,
                        onBookmark: { viewModel.savePassage(context: modelContext) },
                        onShare: {
                            showShareSheet = true
                        }
                    )

                    // Study Mode Pills
                    StudyModePillsView(
                        selectedMode: viewModel.selectedMode,
                        onSelect: { mode in
                            Task {
                                await viewModel.selectMode(mode, isPro: subscriptionService.isPro, onShowPaywall: onShowPaywall)
                            }
                        }
                    )

                    // AI Response
                    if viewModel.aiLoading || !viewModel.aiResponse.isEmpty {
                        AIResponseView(
                            response: viewModel.aiResponse,
                            isLoading: viewModel.aiLoading,
                            error: viewModel.aiError,
                            onSaveToJournal: { viewModel.saveToJournal(context: modelContext) }
                        )
                    }

                    // Follow-up question
                    if viewModel.showFollowUp && !viewModel.aiLoading {
                        VStack(spacing: 8) {
                            HStack(spacing: 10) {
                                TextField("Ask a follow-up question...", text: $viewModel.followUpText)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .submitLabel(.send)
                                    .onSubmit {
                                        Task {
                                            await viewModel.askFollowUp(
                                                isPro: subscriptionService.isPro,
                                                onShowPaywall: onShowPaywall
                                            )
                                        }
                                    }

                                if !viewModel.followUpText.isEmpty {
                                    Button {
                                        Task {
                                            await viewModel.askFollowUp(
                                                isPro: subscriptionService.isPro,
                                                onShowPaywall: onShowPaywall
                                            )
                                        }
                                    } label: {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(AppTheme.accent)
                                    }
                                }
                            }
                            .padding()
                            .background(AppTheme.surfaceLight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.surfaceBorder, lineWidth: 1)
                            )
                        }
                    }

                    // Cross References
                    if !viewModel.crossReferences.isEmpty {
                        CrossReferencesView(references: viewModel.crossReferences) { ref in
                            // Navigate to new study for this reference & auto-trigger AI
                            let currentMode = viewModel.selectedMode ?? .observe
                            viewModel.verse = ref
                            viewModel.aiResponse = ""
                            viewModel.crossReferences = []
                            Task {
                                await viewModel.fetchVerse()
                                await viewModel.selectMode(
                                    currentMode,
                                    isPro: subscriptionService.isPro,
                                    onShowPaywall: onShowPaywall
                                )
                            }
                        }
                    }

                    // Error state
                    if let error = viewModel.verseError {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.error)
                            .padding()
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
        }
        .task { await viewModel.fetchVerse() }
        .onDisappear { viewModel.cancelStream() }
        .sheet(isPresented: $showShareSheet) {
            let text = "\(viewModel.verse)\n\n\(viewModel.verseText)\n\n— Studied with Bible Copilot"
            ActivityView(activityItems: [text])
        }
    }
}
