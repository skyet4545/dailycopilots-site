import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var viewModel: StudyViewModel

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
                        onBookmark: { viewModel.savePassage(context: modelContext) }
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

                    // Cross References
                    if !viewModel.crossReferences.isEmpty {
                        CrossReferencesView(references: viewModel.crossReferences) { ref in
                            // Navigate to new study for this reference
                            viewModel.verse = ref
                            viewModel.selectedMode = nil
                            viewModel.aiResponse = ""
                            viewModel.crossReferences = []
                            Task { await viewModel.fetchVerse() }
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
    }
}
