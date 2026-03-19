import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var reference: String
    var mode: String
    var response: String
    var reflection: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        reference: String,
        mode: String,
        response: String,
        reflection: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.reference = reference
        self.mode = mode
        self.response = response
        self.reflection = reflection
        self.createdAt = createdAt
    }

    var studyMode: StudyMode? {
        StudyMode(rawValue: mode)
    }
}
