import SwiftUI

struct ProLockOverlay: View {
    let title: String
    let subtitle: String
    let onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 44))
                .foregroundColor(AppTheme.gold)

            Text(title)
                .font(.title2.bold())
                .foregroundColor(AppTheme.textPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)

            Button(action: onUpgrade) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Unlock with Pro")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(AppTheme.goldGradient)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.opacity(0.95))
    }
}
