import SwiftUI
import SwiftData

struct SavedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedPassage.savedAt, order: .reverse) private var passages: [SavedPassage]
    @State private var passageToDelete: SavedPassage?

    let onStudyVerse: (String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if passages.isEmpty {
                    EmptyStateView(
                        icon: "bookmark",
                        title: "No Saved Passages",
                        subtitle: "Bookmark verses during study to save them here"
                    )
                } else {
                    List {
                        ForEach(passages) { passage in
                            SavedPassageCard(passage: passage)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    HapticService.lightImpact()
                                    onStudyVerse(passage.reference)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        passageToDelete = passage
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .alert("Delete Passage?", isPresented: .init(
                get: { passageToDelete != nil },
                set: { if !$0 { passageToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let passage = passageToDelete {
                        modelContext.delete(passage)
                        HapticService.success()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
        }
    }
}
