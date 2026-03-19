import Foundation
import SwiftData

@Model
final class SavedPassage {
    var id: UUID
    var reference: String
    var text: String
    var translation: String
    var savedAt: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        reference: String,
        text: String,
        translation: String,
        savedAt: Date = .now,
        notes: String? = nil
    ) {
        self.id = id
        self.reference = reference
        self.text = text
        self.translation = translation
        self.savedAt = savedAt
        self.notes = notes
    }
}
