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

struct Denomination: Identifiable, Hashable {
    let id: String
    let icon: String
    let label: String

    static let options: [Denomination] = [
        Denomination(id: "nondenominational", icon: "cross.fill", label: "Non-denominational"),
        Denomination(id: "baptist", icon: "drop.fill", label: "Baptist"),
        Denomination(id: "catholic", icon: "building.columns.fill", label: "Catholic"),
        Denomination(id: "methodist", icon: "flame.fill", label: "Methodist"),
        Denomination(id: "pentecostal", icon: "wind", label: "Pentecostal / Charismatic"),
        Denomination(id: "lutheran", icon: "book.closed.fill", label: "Lutheran"),
        Denomination(id: "reformed", icon: "books.vertical.fill", label: "Presbyterian / Reformed"),
        Denomination(id: "orthodox", icon: "sun.max.fill", label: "Orthodox"),
        Denomination(id: "exploring", icon: "sparkle.magnifyingglass", label: "Exploring / Other")
    ]
}

struct BibleTranslation: Identifiable, Hashable {
    let id: String
    let label: String
    let blurb: String

    static let options: [BibleTranslation] = [
        BibleTranslation(id: "KJV", label: "King James Version", blurb: "Classic, poetic language"),
        BibleTranslation(id: "NIV", label: "New International Version", blurb: "Clear modern English"),
        BibleTranslation(id: "ESV", label: "English Standard Version", blurb: "Word-for-word accuracy"),
        BibleTranslation(id: "NLT", label: "New Living Translation", blurb: "Easy to read"),
        BibleTranslation(id: "NKJV", label: "New King James Version", blurb: "Classic, updated wording"),
        BibleTranslation(id: "unsure", label: "Not sure yet", blurb: "We'll start you with KJV")
    ]
}

struct LifeStruggle: Identifiable, Hashable {
    let id: String
    let icon: String
    let label: String

    static let options: [LifeStruggle] = [
        LifeStruggle(id: "anxiety", icon: "cloud.rain.fill", label: "Anxiety & worry"),
        LifeStruggle(id: "purpose", icon: "location.north.line.fill", label: "Purpose & direction"),
        LifeStruggle(id: "relationships", icon: "person.2.fill", label: "Relationships & family"),
        LifeStruggle(id: "grief", icon: "heart.slash.fill", label: "Grief & loss"),
        LifeStruggle(id: "forgiveness", icon: "arrow.uturn.left.circle.fill", label: "Forgiveness"),
        LifeStruggle(id: "doubt", icon: "questionmark.circle.fill", label: "Doubt & hard questions"),
        LifeStruggle(id: "habits", icon: "arrow.triangle.2.circlepath", label: "Breaking old habits"),
        LifeStruggle(id: "gratitude", icon: "sun.max.fill", label: "Growing in gratitude")
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
