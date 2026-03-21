import SwiftUI

struct DailyVerseCard: View {
    let reference: String
    let text: String
    let isLoading: Bool
    let onStudy: () -> Void
    let onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(AppTheme.gold)
                Text("Verse of the Day")
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.gold)
                    .tracking(0.5)

                Spacer()

                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textMuted)
                }
            }

            Text(reference)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            if isLoading {
                HStack {
                    LoadingDotsView()
                    Spacer()
                }
                .frame(height: 60)
            } else {
                Text(text)
                    .font(.body)
                    .italic()
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
                    .lineLimit(4)
            }

            Button(action: onStudy) {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                    Text("Study This Verse")
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [AppTheme.cardBackground, AppTheme.gold.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .stroke(AppTheme.gold.opacity(0.2), lineWidth: 1)
        )
    }
}
