import SwiftUI

struct StudyModePillsView: View {
    let selectedMode: StudyMode?
    let onSelect: (StudyMode) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(StudyMode.allCases) { mode in
                Button {
                    onSelect(mode)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: mode.icon)
                            .font(.caption)
                        Text(mode.label)
                            .font(.footnote.weight(.medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedMode == mode ? .white : mode.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
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
