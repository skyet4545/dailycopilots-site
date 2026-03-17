import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var verseReference: String
    var title: String
    var content: String
    var studyMode: String?
    var createdAt: Date
    var updatedAt: Date

    init(verseReference: String, title: String, content: String, studyMode: StudyMode? = nil) {
        self.id = UUID()
        self.verseReference = verseReference
        self.title = title
        self.content = content
        self.studyMode = studyMode?.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
