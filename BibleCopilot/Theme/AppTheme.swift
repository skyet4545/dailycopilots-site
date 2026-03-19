import SwiftUI

enum AppTheme {
    // MARK: - Primary Colors
    static let background = Color(hex: "0A1628")
    static let surface = Color.white.opacity(0.04)
    static let surfaceLight = Color.white.opacity(0.08)
    static let surfaceBorder = Color.white.opacity(0.10)

    static let accent = Color(hex: "60A5FA")
    static let accentDark = Color(hex: "3B82F6")
    static let gold = Color(hex: "FBBF24")
    static let goldDark = Color(hex: "D4AF37")

    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "E8E8E8")
    static let textMuted = Color(hex: "8E8E93")

    // MARK: - Semantic Colors
    static let error = Color(hex: "F87171")
    static let success = Color(hex: "34D399")

    // MARK: - Tab Bar
    static let tabBar = Color(hex: "0D1F35")
    static let tabBarBorder = Color.white.opacity(0.06)

    // MARK: - Cards
    static let cardBackground = Color.white.opacity(0.05)
    static let cardBorder = Color.white.opacity(0.08)

    // MARK: - Corner Radii
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 20

    // MARK: - Gradients
    static let goldGradient = LinearGradient(
        colors: [gold, accentDark],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let accentGradient = LinearGradient(
        colors: [accent, accentDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Font Size Preference

enum FontSizePreference: String, CaseIterable {
    case small, medium, large

    var bodySize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 19
        }
    }

    var verseSize: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 18
        case .large: return 22
        }
    }

    var label: String {
        rawValue.capitalized
    }
}
