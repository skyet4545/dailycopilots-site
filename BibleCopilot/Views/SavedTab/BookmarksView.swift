import SwiftUI
import SwiftData

struct BookmarksView: View {
    @State private var viewModel = BookmarksViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedItem.savedAt, order: .reverse) private var items: [SavedItem]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter
                Picker("Filter", selection: $viewModel.selectedFilter) {
                    Text("All").tag(SavedItemType?.none)
                    Text("Verses").tag(SavedItemType?.some(.verse))
                    Text("Responses").tag(SavedItemType?.some(.response))
                }
                .pickerStyle(.segmented)
                .padding(AppTheme.spacingLG)

                if items.isEmpty {
                    emptyState
                } else {
                    itemsList
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Spacer()
            Image(systemName: "bookmark")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textMuted)

            Text("No Saved Items")
                .font(AppTheme.sectionFont)
                .foregroundColor(AppTheme.textPrimary)

            Text("Save verses and AI responses while studying to find them here.")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacing2XL)
            Spacer()
        }
    }

    private var itemsList: some View {
        let filtered = viewModel.filteredItems(items)
        return List {
            ForEach(filtered) { item in
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    HStack {
                        Image(systemName: item.itemType == .verse ? "book.fill" : "brain.head.profile")
                            .font(.system(size: 12))
                            .foregroundColor(item.itemType == .verse ? AppTheme.gold : AppTheme.accent)

                        Text(item.verseReference)
                            .font(AppTheme.labelFont)
                            .foregroundColor(AppTheme.gold)

                        if let modeStr = item.studyMode, let mode = StudyMode(rawValue: modeStr) {
                            Text(mode.title)
                                .font(.system(size: 10))
                                .foregroundColor(mode.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(mode.color.opacity(0.15))
                                .cornerRadius(4)
                        }

                        Spacer()

                        Text(item.savedAt, style: .date)
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                    }

                    Text(item.content)
                        .font(item.itemType == .verse ? AppTheme.scriptureFont : AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(4)
                }
                .padding(.vertical, AppTheme.spacingXS)
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
