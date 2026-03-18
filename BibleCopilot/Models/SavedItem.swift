import Foundation
import SwiftData

enum SavedItemType: String, Codable {
    case verse
    case response
}

@Model
final class SavedItem {
    var id: UUID
    var type: String
    var verseReference: String
    var content: String
    var studyMode: String?
    var notes: String?
    var savedAt: Date

    init(type: SavedItemType, verseReference: String, content: String, studyMode: StudyMode? = nil, notes: String? = nil) {
        self.id = UUID()
        self.type = type.rawValue
        self.verseReference = verseReference
        self.content = content
        self.studyMode = studyMode?.rawValue
        self.notes = notes
        self.savedAt = Date()
    }

    var itemType: SavedItemType {
        SavedItemType(rawValue: type) ?? .verse
    }
}
