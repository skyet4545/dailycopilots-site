import SwiftUI

enum StudyMode: String, CaseIterable, Codable, Identifiable {
    case summary
    case observe
    case interpret
    case theology
    case apply
    case apologetics

    var id: String { rawValue }

    var label: String {
        switch self {
        case .summary: return "Summary"
        case .observe: return "Observe"
        case .interpret: return "Interpret"
        case .theology: return "Theology"
        case .apply: return "Apply"
        case .apologetics: return "Apologetics"
        }
    }

    var icon: String {
        switch self {
        case .summary: return "text.book.closed"
        case .observe: return "eye"
        case .interpret: return "lightbulb"
        case .theology: return "book"
        case .apply: return "hand.raised"
        case .apologetics: return "shield.checkered"
        }
    }

    var color: Color {
        switch self {
        case .summary: return Color(hex: "2DD4BF")
        case .observe: return Color(hex: "60A5FA")
        case .interpret: return Color(hex: "A78BFA")
        case .theology: return Color(hex: "34D399")
        case .apply: return Color(hex: "F87171")
        case .apologetics: return Color(hex: "FBBF24")
        }
    }

    var description: String {
        switch self {
        case .summary: return "What's this chapter about?"
        case .observe: return "What does the text say?"
        case .interpret: return "What does it mean?"
        case .theology: return "What does it teach about God?"
        case .apply: return "How does it apply to my life?"
        case .apologetics: return "How do we defend this truth?"
        }
    }
}
