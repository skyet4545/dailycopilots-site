import SwiftUI

/// The five study modes used throughout the app.
enum StudyMode: String, CaseIterable, Codable, Identifiable {
    case observe
    case interpret
    case theology
    case apply
    case apologetics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .observe: return "Observation"
        case .interpret: return "Interpretation"
        case .theology: return "Theology"
        case .apply: return "Application"
        case .apologetics: return "Apologetics"
        }
    }

    var subtitle: String {
        switch self {
        case .observe: return "What does the text say?"
        case .interpret: return "What does it mean?"
        case .theology: return "What does it teach about God?"
        case .apply: return "How should I respond?"
        case .apologetics: return "How do I defend this?"
        }
    }

    var icon: String {
        switch self {
        case .observe: return "book.fill"
        case .interpret: return "magnifyingglass"
        case .theology: return "cross.fill"
        case .apply: return "hands.clap.fill"
        case .apologetics: return "shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .observe: return AppTheme.observeColor
        case .interpret: return AppTheme.interpretColor
        case .theology: return AppTheme.theologyColor
        case .apply: return AppTheme.applyColor
        case .apologetics: return AppTheme.apologeticsColor
        }
    }
}
