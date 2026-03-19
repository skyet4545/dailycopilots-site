import SwiftUI

struct SavedPassageCard: View {
    let passage: SavedPassage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(passage.reference)
                    .font(.headline)
                    .foregroundColor(AppTheme.gold)

                Text(passage.translation.uppercased())
                    .font(.caption2.bold())
                    .foregroundColor(AppTheme.textMuted)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.surfaceLight)
                    .clipShape(Capsule())

                Spacer()

                Text(passage.savedAt.relativeFormatted)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textMuted)
            }

            Text(passage.text)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(3)
                .lineSpacing(2)

            if let notes = passage.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(AppTheme.textMuted)
                    .italic()
                    .lineLimit(2)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        )
    }
}
