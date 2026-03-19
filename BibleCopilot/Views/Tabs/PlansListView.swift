import SwiftUI
import SwiftData

struct PlansListView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [ReadingPlanProgress]
    @State private var selectedPlan: ReadingPlan?

    let onStudyVerse: (String) -> Void
    let onShowPaywall: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if !subscriptionService.isPro {
                    ProLockOverlay(
                        title: "Reading Plans",
                        subtitle: "Follow guided reading plans through Scripture",
                        onUpgrade: onShowPaywall
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(ReadingPlan.allPlans) { plan in
                                PlanRowView(
                                    plan: plan,
                                    progress: progressFor(plan)
                                ) {
                                    selectedPlan = plan
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Reading Plans")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedPlan) { plan in
                PlanDetailView(
                    plan: plan,
                    progress: progressFor(plan),
                    onStudyVerse: onStudyVerse,
                    modelContext: modelContext
                )
            }
        }
    }

    private func progressFor(_ plan: ReadingPlan) -> ReadingPlanProgress? {
        allProgress.first { $0.planId == plan.id }
    }
}

// Make ReadingPlan hashable for navigation
extension ReadingPlan: Hashable {
    static func == (lhs: ReadingPlan, rhs: ReadingPlan) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Plan Row

struct PlanRowView: View {
    let plan: ReadingPlan
    let progress: ReadingPlanProgress?
    let action: () -> Void

    private var completedCount: Int { progress?.completedCount ?? 0 }
    private var progressFraction: Double {
        guard plan.dayCount > 0 else { return 0 }
        return Double(completedCount) / Double(plan.dayCount)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: plan.icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)

                    Text(plan.description)
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)
                        .lineLimit(2)

                    if completedCount > 0 {
                        ProgressView(value: progressFraction)
                            .tint(AppTheme.accent)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(plan.dayCount)")
                        .font(.title3.bold())
                        .foregroundColor(AppTheme.textPrimary)
                    Text("days")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textMuted)
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
        .buttonStyle(.plain)
    }
}
