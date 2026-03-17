import SwiftUI
import SwiftData

@MainActor
class BookmarksViewModel: ObservableObject {
    @Published var selectedFilter: SavedItemType? = nil

    func filteredItems(_ items: [SavedItem]) -> [SavedItem] {
        let sorted = items.sorted { $0.savedAt > $1.savedAt }
        guard let filter = selectedFilter else { return sorted }
        return sorted.filter { $0.itemType == filter }
    }

    func saveVerse(reference: String, text: String, context: ModelContext) {
        let item = SavedItem(type: .verse, verseReference: reference, content: text)
        context.insert(item)
    }

    func saveResponse(reference: String, response: String, studyMode: StudyMode?, context: ModelContext) {
        let item = SavedItem(type: .response, verseReference: reference, content: response, studyMode: studyMode)
        context.insert(item)
    }

    func deleteItem(_ item: SavedItem, context: ModelContext) {
        context.delete(item)
    }
}
