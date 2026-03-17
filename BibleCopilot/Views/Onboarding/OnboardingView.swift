import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentSlide = 0

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Welcome to\nBible Copilot",
            subtitle: "Your AI-powered Bible study companion",
            icon: "book.open.fill",
            color: AppTheme.accent
        ),
        OnboardingSlide(
            title: "Not Just\nAny AI",
            subtitle: "Trained on trusted commentaries and theological resources for accurate, faithful answers",
            icon: "brain.head.profile",
            color: AppTheme.interpretColor
        ),
        OnboardingSlide(
            title: "The Method\nMatters",
            subtitle: "Five study modes guide you through observation, interpretation, theology, application, and apologetics",
            icon: "safari.fill",
            color: AppTheme.theologyColor
        ),
        OnboardingSlide(
            title: "Go Deep",
            subtitle: "Cross-references, original language insights, and historical context at your fingertips",
            icon: "square.3.layers.3d",
            color: AppTheme.gold
        ),
        OnboardingSlide(
            title: "Ready to\nStudy?",
            subtitle: "Start with any verse. Ask any question. Grow in understanding.",
            icon: "paperplane.fill",
            color: AppTheme.accent
        ),
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: AppTheme.spacing2XL) {
                // Skip button
                HStack {
                    Spacer()
                    if currentSlide < slides.count - 1 {
                        Button("Skip") {
                            onComplete()
                        }
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)
                    }
                }
                .padding(.horizontal, AppTheme.spacingXL)
                .frame(height: 44)

                Spacer()

                // Icon
                let slide = slides[currentSlide]
                ZStack {
                    Circle()
                        .fill(slide.color.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Image(systemName: slide.icon)
                        .font(.system(size: 48))
                        .foregroundColor(slide.color)
                }

                // Text
                VStack(spacing: AppTheme.spacingMD) {
                    Text(slide.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(slide.subtitle)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.spacing2XL)
                }

                Spacer()

                // Dots
                HStack(spacing: AppTheme.spacingSM) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentSlide ? AppTheme.accent : AppTheme.textMuted.opacity(0.3))
                            .frame(width: index == currentSlide ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentSlide)
                    }
                }

                // Button
                Button {
                    if currentSlide < slides.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentSlide += 1
                        }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(currentSlide == slides.count - 1 ? "Get Started" : "Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.spacingLG)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.accent, AppTheme.accentDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(AppTheme.cornerRadiusMD)
                }
                .padding(.horizontal, AppTheme.spacingXL)
                .padding(.bottom, AppTheme.spacing2XL)
            }
        }
    }
}

private struct OnboardingSlide {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}
