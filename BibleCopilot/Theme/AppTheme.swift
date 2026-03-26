import SwiftUI

// MARK: - Theme Manager

@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    @ObservationIgnored
    @AppStorage("appTheme") var themeMode: String = {
        // Existing users (onboarding done) default to dark, new users to system
        if UserDefaults.standard.bool(forKey: "onboardingComplete") {
            return "dark"
        }
        return "system"
    }()

    var colorScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil // system
        }
    }

    var isDark: Bool {
        switch themeMode {
        case "light": return false
        case "dark": return true
        default:
            // System: check current trait
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
}

enum AppThemeMode: String, CaseIterable {
    case system, light, dark

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

// MARK: - Theme Colors

enum AppTheme {
    private static var isDark: Bool { ThemeManager.shared.isDark }

    // MARK: - Primary Colors
    static var background: Color {
        isDark ? Color(hex: "0A1628") : Color(hex: "FFFFFF")
    }
    static var surface: Color {
        isDark ? Color.white.opacity(0.04) : Color(hex: "F2F2F7")
    }
    static var surfaceLight: Color {
        isDark ? Color.white.opacity(0.08) : Color(hex: "E5E5EA")
    }
    static var surfaceBorder: Color {
        isDark ? Color.white.opacity(0.10) : Color(hex: "C6C6C8")
    }

    static let accent = Color(hex: "60A5FA")
    static let accentDark = Color(hex: "3B82F6")
    static let gold = Color(hex: "FBBF24")
    static let goldDark = Color(hex: "D4AF37")

    // MARK: - Text Colors
    static var textPrimary: Color {
        isDark ? .white : Color(hex: "1C1C1E")
    }
    static var textSecondary: Color {
        isDark ? Color(hex: "E8E8E8") : Color(hex: "3C3C43")
    }
    static var textMuted: Color {
        Color(hex: "8E8E93")
    }

    // MARK: - Semantic Colors
    static let error = Color(hex: "F87171")
    static let success = Color(hex: "34D399")
    static var warning: Color { Color(hex: "FBBF24") }

    // MARK: - Tab Bar
    static var tabBar: Color {
        isDark ? Color(hex: "0D1F35") : Color(hex: "F8F8F8")
    }
    static var tabBarBorder: Color {
        isDark ? Color.white.opacity(0.06) : Color(hex: "D1D1D6")
    }

    // MARK: - Cards
    static var cardBackground: Color {
        isDark ? Color.white.opacity(0.05) : Color(hex: "FFFFFF")
    }
    static var cardBorder: Color {
        isDark ? Color.white.opacity(0.08) : Color(hex: "E5E5EA")
    }

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
