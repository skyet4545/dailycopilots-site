import SwiftUI

struct UsageCounterView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        let remaining = subscriptionManager.remainingQuestions
        let total = subscriptionManager.freeQuestionLimit

        HStack(spacing: AppTheme.spacingSM) {
            Image(systemName: remaining > 0 ? "questionmark.circle" : "lock.fill")
                .foregroundColor(remaining > 0 ? AppTheme.textMuted : AppTheme.gold)
                .font(AppTheme.captionFont)

            Text(remaining > 0
                ? "\(remaining)/\(total) free questions today"
                : "Free questions used — upgrade to continue")
                .font(AppTheme.captionFont)
                .foregroundColor(remaining > 0 ? AppTheme.textMuted : AppTheme.gold)

            Spacer()
        }
        .padding(.horizontal, AppTheme.spacingMD)
        .padding(.vertical, AppTheme.spacingSM)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusSM)
    }
}
