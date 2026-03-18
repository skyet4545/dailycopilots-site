import SwiftUI

/// Centralized theme constants from the Bible Copilot design spec.
enum AppTheme {

    // MARK: - Colors (Dark Theme Primary)

    static let background = Color(hex: "0A1628")
    static let surface = Color.white.opacity(0.04)
    static let surfaceLight = Color.white.opacity(0.08)
    static let accent = Color(hex: "60A5FA")
    static let accentDark = Color(hex: "3B82F6")
    static let gold = Color(hex: "FBBF24")
    static let goldDark = Color(hex: "D4AF37")

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "E8E8E8")
    static let textMuted = Color(hex: "8E8E93")

    static let tabBarBackground = Color(hex: "0D1F35")
    static let success = Color(hex: "34D399")
    static let error = Color(hex: "F87171")

    // MARK: - Study Mode Colors

    static let observeColor = Color(hex: "60A5FA")
    static let interpretColor = Color(hex: "A78BFA")
    static let theologyColor = Color(hex: "34D399")
    static let applyColor = Color(hex: "F87171")
    static let apologeticsColor = Color(hex: "FBBF24")

    // MARK: - Typography

    static let scriptureFont = Font.custom("Georgia", size: 18)
    static let scriptureFontLarge = Font.custom("Georgia", size: 20)
    static let headingFont = Font.system(size: 28, weight: .bold)
    static let subheadingFont = Font.system(size: 22, weight: .semibold)
    static let sectionFont = Font.system(size: 18, weight: .semibold)
    static let bodyFont = Font.system(size: 16)
    static let captionFont = Font.system(size: 14)
    static let labelFont = Font.system(size: 12, weight: .medium)

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacing2XL: CGFloat = 32
    static let spacing3XL: CGFloat = 48

    // MARK: - Corner Radius

    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 12
    static let cornerRadiusLG: CGFloat = 18

    // MARK: - Accessibility

    static let minTouchTarget: CGFloat = 44
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
