import SwiftUI

struct VerseCardView: View {
    let reference: String
    let text: String
    let isLoading: Bool
    let isBookmarked: Bool
    let onBookmark: () -> Void

    @AppStorage("translation") private var translation: String = "kjv"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(reference)
                    .font(.title3.bold())
                    .foregroundColor(AppTheme.gold)

                Spacer()

                Text(translation.uppercased())
                    .font(.caption2.bold())
                    .foregroundColor(AppTheme.textMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.surfaceLight)
                    .clipShape(Capsule())

                Button(action: onBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? AppTheme.gold : AppTheme.textMuted)
                }
            }

            if isLoading {
                ProgressView()
                    .tint(AppTheme.accent)
                    .frame(maxWidth: .infinity, minHeight: 60)
            } else if !text.isEmpty {
                Text(text)
                    .font(.body)
                    .italic()
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        )
    }
}
