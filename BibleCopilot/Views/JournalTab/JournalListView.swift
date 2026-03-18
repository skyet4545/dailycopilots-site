import SwiftUI
import SwiftData

struct JournalListView: View {
    @State private var viewModel = JournalViewModel()
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.updatedAt, order: .reverse) private var entries: [JournalEntry]
    @State private var showNewEntry = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Group {
                if !subscriptionManager.isPro {
                    proGateView
                } else if entries.isEmpty {
                    emptyState
                } else {
                    journalList
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if subscriptionManager.isPro {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showNewEntry = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search journal...")
            .sheet(isPresented: $showNewEntry) {
                JournalEntryView(entry: nil)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var proGateView: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.gold)

            Text("Study Journal")
                .font(AppTheme.sectionFont)
                .foregroundColor(AppTheme.textPrimary)

            Text("Upgrade to Pro to save your reflections and build a personal study journal.")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacing2XL)

            Button {
                showPaywall = true
            } label: {
                Text("Upgrade to Pro")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.spacingXL)
                    .padding(.vertical, AppTheme.spacingMD)
                    .background(AppTheme.accent)
                    .cornerRadius(AppTheme.cornerRadiusSM)
            }
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Image(systemName: "note.text")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textMuted)

            Text("No Journal Entries")
                .font(AppTheme.sectionFont)
                .foregroundColor(AppTheme.textPrimary)

            Text("Start studying a verse and save your reflections here.")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacing2XL)

            Button {
                showNewEntry = true
            } label: {
                Text("Create Entry")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.spacingXL)
                    .padding(.vertical, AppTheme.spacingMD)
                    .background(AppTheme.accent)
                    .cornerRadius(AppTheme.cornerRadiusSM)
            }
        }
    }

    private var journalList: some View {
        let filtered = viewModel.filteredEntries(entries)
        return List {
            ForEach(filtered) { entry in
                NavigationLink {
                    JournalEntryView(entry: entry)
                } label: {
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        HStack {
                            Text(entry.verseReference)
                                .font(AppTheme.labelFont)
                                .foregroundColor(AppTheme.gold)
                            Spacer()
                            Text(entry.updatedAt, style: .date)
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Text(entry.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                        Text(entry.content)
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textMuted)
                            .lineLimit(2)
                    }
                    .padding(.vertical, AppTheme.spacingXS)
                }
                .listRowBackground(AppTheme.background)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(filtered[index])
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
