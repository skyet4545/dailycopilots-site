import SwiftUI
import SwiftData

struct PlanDetailView: View {
    let plan: ReadingPlan
    @State var progress: ReadingPlanProgress?
    let onStudyVerse: (String) -> Void
    let modelContext: ModelContext

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: plan.icon)
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.accent)

                    Text(plan.title)
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)

                    Text(plan.description)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)

                    // Progress bar
                    let completed = progress?.completedCount ?? 0
                    ProgressView(value: Double(completed), total: Double(plan.dayCount))
                        .tint(AppTheme.accent)
                        .padding(.horizontal)

                    Text("\(completed) of \(plan.dayCount) days completed")
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)
                }
                .padding()

                // Day list
                LazyVStack(spacing: 10) {
                    ForEach(Array(plan.verses.enumerated()), id: \.offset) { index, verse in
                        let isComplete = progress?.isCompleted(day: index) ?? false

                        Button {
                            toggleDay(index)
                            onStudyVerse(verse)
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(isComplete ? AppTheme.accent : AppTheme.surfaceLight)
                                        .frame(width: 32, height: 32)

                                    if isComplete {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)
                                    } else {
                                        Text("\(index + 1)")
                                            .font(.caption.bold())
                                            .foregroundColor(AppTheme.textMuted)
                                    }
                                }

                                Text("Day \(index + 1): \(verse)")
                                    .font(.subheadline)
                                    .foregroundColor(isComplete ? AppTheme.textMuted : AppTheme.textPrimary)
                                    .strikethrough(isComplete)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { ensureProgress() }
    }

    private func ensureProgress() {
        if progress == nil {
            let newProgress = ReadingPlanProgress(planId: plan.id)
            modelContext.insert(newProgress)
            progress = newProgress
        }
    }

    private func toggleDay(_ day: Int) {
        ensureProgress()
        guard let progress else { return }

        if progress.isCompleted(day: day) {
            progress.completedDays.removeAll { $0 == day }
        } else {
            progress.completedDays.append(day)
            progress.lastReadAt = .now
        }
        HapticService.success()
    }
}
