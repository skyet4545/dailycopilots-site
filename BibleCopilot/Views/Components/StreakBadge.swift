import SwiftUI

struct StreakBadge: View {
    let streak: Int
    let emoji: String
    let studiedToday: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 1) {
                Text("\(streak) day streak")
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.textPrimary)

                Text(studiedToday ? "Studied today" : "Study to keep streak")
                    .font(.system(size: 10))
                    .foregroundColor(studiedToday ? AppTheme.success : AppTheme.gold)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppTheme.cardBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(studiedToday ? AppTheme.success.opacity(0.3) : AppTheme.gold.opacity(0.3), lineWidth: 1)
        )
    }
}
