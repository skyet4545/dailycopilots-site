import SwiftUI

struct StudyModePillsView: View {
    let selectedMode: StudyMode?
    let onSelect: (StudyMode) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(StudyMode.allCases) { mode in
                    Button {
                        onSelect(mode)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: mode.icon)
                                .font(.caption)
                            Text(mode.label)
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundColor(selectedMode == mode ? .white : mode.color)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedMode == mode ? mode.color : mode.color.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(mode.color.opacity(0.3), lineWidth: selectedMode == mode ? 0 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
