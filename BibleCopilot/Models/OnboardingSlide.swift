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
            iconColor: AppTheme.gold,
            title: "Welcome to\nBible Copilot",
            subtitle: "Your AI-powered companion for deeper Bible study"
        ),
        OnboardingSlide(
            id: 1,
            icon: "brain.head.profile",
            iconColor: AppTheme.accent,
            title: "Not Just AI",
            subtitle: "Grounded in proven study methods used by theologians for centuries"
        ),
        OnboardingSlide(
            id: 2,
            icon: "text.magnifyingglass",
            iconColor: Color(hex: "A78BFA"),
            title: "Method Matters",
            subtitle: "Observe, Interpret, Apply, and explore Theology & Apologetics"
        ),
        OnboardingSlide(
            id: 3,
            icon: "arrow.down.doc.fill",
            iconColor: AppTheme.success,
            title: "Go Deep",
            subtitle: "Save insights to your journal and build a library of understanding"
        ),
        OnboardingSlide(
            id: 4,
            icon: "checkmark.circle.fill",
            iconColor: AppTheme.gold,
            title: "Ready to Begin",
            subtitle: "Start with 10 free questions per day. Upgrade anytime for unlimited."
        )
    ]
}
