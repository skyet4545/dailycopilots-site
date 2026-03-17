import Foundation
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var text: String
    var isUser: Bool
    var timestamp: Date
    var studyMode: String?
    var verseReference: String?

    init(text: String, isUser: Bool, studyMode: StudyMode? = nil, verseReference: String? = nil) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
        self.timestamp = Date()
        self.studyMode = studyMode?.rawValue
        self.verseReference = verseReference
    }
}
