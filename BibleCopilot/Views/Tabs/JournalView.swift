import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]
    @State private var entryToDelete: JournalEntry?

    let onShowPaywall: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if !subscriptionService.isPro {
                    ProLockOverlay(
                        title: "Study Journal",
                        subtitle: "Save and review your AI-powered Bible studies",
                        onUpgrade: onShowPaywall
                    )
                } else if entries.isEmpty {
                    EmptyStateView(
                        icon: "book.closed",
                        title: "No Journal Entries",
                        subtitle: "Your saved Bible studies will appear here"
                    )
                } else {
                    List {
                        ForEach(entries) { entry in
                            JournalCardView(entry: entry)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        entryToDelete = entry
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
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .alert("Delete Entry?", isPresented: .init(
                get: { entryToDelete != nil },
                set: { if !$0 { entryToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let entry = entryToDelete {
                        modelContext.delete(entry)
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
