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
            title: "Not Just\nAny AI",
            subtitle: "Every answer is rooted in Scripture alone. No opinions, no speculation — just faithful, Bible-grounded insight"
        ),
        OnboardingSlide(
            id: 2,
            icon: "safari",
            iconColor: Color(hex: "34D399"),
            title: "The Method\nMatters",
            subtitle: "Five study modes guide you through observation, interpretation, theology, application, and apologetics"
        ),
        OnboardingSlide(
            id: 3,
            icon: "square.3.layers.3d",
            iconColor: AppTheme.gold,
            title: "Go Deep",
            subtitle: "Cross-references, original language insights, and historical context at your fingertips"
        ),
        OnboardingSlide(
            id: 4,
            icon: "paperplane.fill",
            iconColor: AppTheme.accent,
            title: "Ready to\nStudy?",
            subtitle: "Start with any verse. Ask any question. Grow in understanding."
        )
    ]
}
