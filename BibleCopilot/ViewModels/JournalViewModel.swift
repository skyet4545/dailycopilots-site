import SwiftUI
import SwiftData

@MainActor
class JournalViewModel: ObservableObject {
    @Published var searchText = ""

    func filteredEntries(_ entries: [JournalEntry]) -> [JournalEntry] {
        if searchText.isEmpty {
            return entries.sorted { $0.updatedAt > $1.updatedAt }
        }
        return entries.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText) ||
            $0.verseReference.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.updatedAt > $1.updatedAt }
    }

    func createEntry(
        verseReference: String,
        title: String,
        content: String,
        studyMode: StudyMode?,
        context: ModelContext
    ) {
        let entry = JournalEntry(
            verseReference: verseReference,
            title: title,
            content: content,
            studyMode: studyMode
        )
        context.insert(entry)
    }

    func deleteEntry(_ entry: JournalEntry, context: ModelContext) {
        context.delete(entry)
    }
}
