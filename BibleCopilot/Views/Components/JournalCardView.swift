import SwiftUI

struct JournalCardView: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.reference)
                    .font(.headline)
                    .foregroundColor(AppTheme.gold)

                if let mode = entry.studyMode {
                    Text(mode.label)
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(mode.color)
                        .clipShape(Capsule())
                }

                Spacer()

                Text(entry.createdAt.relativeFormatted)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textMuted)
            }

            Text(entry.response)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(4)
                .lineSpacing(2)
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
