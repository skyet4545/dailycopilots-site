import SwiftUI
import UIKit

enum VerseShareTheme: String, CaseIterable, Identifiable {
    case midnight
    case parchment
    case sunrise

    var id: String { rawValue }

    var label: String {
        switch self {
        case .midnight: return "Midnight"
        case .parchment: return "Parchment"
        case .sunrise: return "Sunrise"
        }
    }

    var colors: [Color] {
        switch self {
        case .midnight: return [Color(hex: "081426"), Color(hex: "173D68")]
        case .parchment: return [Color(hex: "F8EFD8"), Color(hex: "D9B978")]
        case .sunrise: return [Color(hex: "402A65"), Color(hex: "E67E72")]
        }
    }

    var foreground: Color {
        self == .parchment ? Color(hex: "281D13") : .white
    }

    var accent: Color {
        self == .parchment ? Color(hex: "75521C") : Color(hex: "FBBF24")
    }
}

struct VerseShareComposerView: View {
    let reference: String
    let verseText: String
    let reflection: String
    let suggestedQuestion: String

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTheme: VerseShareTheme = .midnight
    @State private var shareService = TikTokVerseShareService()
    @State private var nativeShareImages: [UIImage] = []
    @State private var showsNativeShare = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    TabView {
                        VerseShareCard(
                            reference: reference,
                            primaryText: verseText,
                            secondaryText: "",
                            theme: selectedTheme,
                            slide: 1
                        )
                        VerseShareCard(
                            reference: reference,
                            primaryText: reflectionText,
                            secondaryText: questionText,
                            theme: selectedTheme,
                            slide: 2
                        )
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 470)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose a style")
                            .font(.headline)

                        HStack(spacing: 10) {
                            ForEach(VerseShareTheme.allCases) { theme in
                                Button {
                                    selectedTheme = theme
                                } label: {
                                    Text(theme.label)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(selectedTheme == theme ? Color.white : AppTheme.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(selectedTheme == theme ? AppTheme.accent : AppTheme.surfaceLight)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    Button {
                        Task {
                            let images = VerseShareRenderer.render(
                                reference: reference,
                                verseText: verseText,
                                reflection: reflectionText,
                                question: questionText,
                                theme: selectedTheme
                            )
                            await shareService.share(images: images)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if shareService.isSharing {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "music.note")
                            }
                            Text(shareService.isSharing ? "Preparing verse cards…" : "Share to TikTok")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(shareService.isSharing || verseText.isEmpty)

                    Button("More sharing options") {
                        nativeShareImages = VerseShareRenderer.render(
                            reference: reference,
                            verseText: verseText,
                            reflection: reflectionText,
                            question: questionText,
                            theme: selectedTheme
                        )
                        AnalyticsService.shared.track(AnalyticsEvent.verseShared, ["destination": "share_sheet"])
                        showsNativeShare = true
                    }
                    .font(.subheadline.bold())
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationTitle("Share This Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showsNativeShare) {
                ActivityView(activityItems: nativeShareImages)
            }
            .alert(shareService.alertTitle, isPresented: $shareService.showsAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(shareService.alertMessage)
            }
        }
    }

    private var reflectionText: String {
        reflection.isEmpty
            ? "Pause and read the passage again. What word or promise stands out to you?"
            : reflection
    }

    private var questionText: String {
        suggestedQuestion.isEmpty
            ? "What does this passage reveal about God—and how will you respond today?"
            : suggestedQuestion
    }
}

private struct VerseShareCard: View {
    let reference: String
    let primaryText: String
    let secondaryText: String
    let theme: VerseShareTheme
    let slide: Int

    var body: some View {
        ZStack {
            LinearGradient(colors: theme.colors, startPoint: .topLeading, endPoint: .bottomTrailing)

            Circle()
                .fill(theme.accent.opacity(0.14))
                .frame(width: 720, height: 720)
                .offset(x: 390, y: -720)

            VStack(alignment: .leading, spacing: 54) {
                HStack {
                    Image(systemName: "book.closed.fill")
                    Text(slide == 1 ? "VERSE OF THE DAY" : "REFLECT")
                        .tracking(4)
                    Spacer()
                    Text("\(slide)/2")
                }
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(theme.accent)

                Spacer()

                Text(reference)
                    .font(.system(size: 74, weight: .bold, design: .serif))
                    .foregroundStyle(theme.accent)

                Text(primaryText)
                    .font(.system(size: slide == 1 ? 62 : 58, weight: .semibold, design: .serif))
                    .foregroundStyle(theme.foreground)
                    .lineSpacing(18)
                    .minimumScaleFactor(0.55)

                if !secondaryText.isEmpty {
                    Rectangle()
                        .fill(theme.accent.opacity(0.75))
                        .frame(height: 3)

                    Text(secondaryText)
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(theme.foreground.opacity(0.88))
                        .lineSpacing(14)
                        .minimumScaleFactor(0.65)
                }

                Spacer()

                HStack(spacing: 18) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 84, height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Bible Copilot")
                            .font(.system(size: 38, weight: .bold))
                        Text("Study Scripture with clarity")
                            .font(.system(size: 27, weight: .medium))
                            .opacity(0.78)
                    }
                    .foregroundStyle(theme.foreground)
                }
            }
            .padding(96)
        }
        .aspectRatio(9 / 16, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 34)
    }
}

@MainActor
private enum VerseShareRenderer {
    static func render(
        reference: String,
        verseText: String,
        reflection: String,
        question: String,
        theme: VerseShareTheme
    ) -> [UIImage] {
        [
            renderCard(
                VerseShareCard(
                    reference: reference,
                    primaryText: verseText,
                    secondaryText: "",
                    theme: theme,
                    slide: 1
                )
            ),
            renderCard(
                VerseShareCard(
                    reference: reference,
                    primaryText: reflection,
                    secondaryText: question,
                    theme: theme,
                    slide: 2
                )
            )
        ].compactMap { $0 }
    }

    private static func renderCard(_ card: VerseShareCard) -> UIImage? {
        let renderer = ImageRenderer(
            content: card
                .frame(width: 1080, height: 1920)
                .ignoresSafeArea()
        )
        renderer.scale = 1
        renderer.isOpaque = true
        return renderer.uiImage
    }
}
