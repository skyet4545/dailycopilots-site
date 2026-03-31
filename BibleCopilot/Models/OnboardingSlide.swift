import SwiftUI

struct OnboardingSlide: Identifiable {
    let id: Int
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    static let slides: [OnboardingSlide] = [
        OnboardingSlide(
            id: 0,
            icon: "book.fill",
            iconColor: AppTheme.accent,
            title: "Welcome to\nBible Copilot",
            subtitle: "Your AI-powered Bible study companion"
        ),
        OnboardingSlide(
            id: 1,
            icon: "brain.head.profile",
            iconColor: Color(hex: "A78BFA"),
            title: "Scripture-Grounded\nInsight",
            subtitle: "Every answer is rooted in the Bible. Cross-references, original languages, and historical context — all at your fingertips."
        ),
        OnboardingSlide(
            id: 2,
            icon: "safari",
            iconColor: Color(hex: "34D399"),
            title: "Five Study\nModes",
            subtitle: "Observation, interpretation, theology, application, and apologetics — guided by time-tested methods."
        )
    ]
}

// MARK: - Personalization Options

struct StudyGoal: Identifiable, Hashable {
    let id: String
    let icon: String
    let label: String

    static let goals: [StudyGoal] = [
        StudyGoal(id: "daily", icon: "sun.max.fill", label: "Daily devotional study"),
        StudyGoal(id: "deep", icon: "magnifyingglass", label: "Deep theological understanding"),
        StudyGoal(id: "context", icon: "clock.fill", label: "Historical & cultural context"),
        StudyGoal(id: "apply", icon: "heart.fill", label: "Applying Scripture to my life"),
        StudyGoal(id: "share", icon: "person.2.fill", label: "Teaching & sharing with others")
    ]
}

enum ExperienceLevel: String, CaseIterable, Identifiable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .beginner: return "Just beginning"
        case .intermediate: return "Some experience"
        case .advanced: return "Advanced student"
        }
    }

    var icon: String {
        switch self {
        case .beginner: return "leaf.fill"
        case .intermediate: return "book.fill"
        case .advanced: return "graduationcap.fill"
        }
    }
}
