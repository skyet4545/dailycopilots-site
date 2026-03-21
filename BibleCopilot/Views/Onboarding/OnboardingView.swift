import SwiftUI

struct OnboardingView: View {
    @State private var currentSlide = 0
    let onComplete: () -> Void

    private let slides = OnboardingSlide.slides

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentSlide < slides.count - 1 {
                        Button("Skip") {
                            onComplete()
                        }
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                        .padding()
                    }
                }
                .frame(height: 44)

                Spacer()

                // Slide content
                VStack(spacing: 24) {
                    let slide = slides[currentSlide]

                    if currentSlide == 0 {
                        // First slide shows the app logo
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .shadow(color: AppTheme.gold.opacity(0.3), radius: 10, y: 4)
                    } else {
                        Circle()
                            .fill(slide.iconColor.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: slide.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(slide.iconColor)
                            )
                    }

                    Text(slide.title)
                        .font(.title.bold())
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(slide.subtitle)
                        .font(.body)
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .animation(.easeInOut(duration: 0.3), value: currentSlide)

                Spacer()

                // Dot indicators
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentSlide ? AppTheme.accent : AppTheme.textMuted.opacity(0.3))
                            .frame(width: index == currentSlide ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentSlide)
                    }
                }
                .padding(.bottom, 32)

                // Button
                Button {
                    if currentSlide < slides.count - 1 {
                        currentSlide += 1
                    } else {
                        onComplete()
                    }
                    HapticService.lightImpact()
                } label: {
                    Text(currentSlide < slides.count - 1 ? "Continue" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
