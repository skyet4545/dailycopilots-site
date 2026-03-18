import SwiftUI
import SwiftData

struct PlanDetailView: View {
    let plan: ReadingPlanDefinition

    @State private var viewModel = PlansViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [ReadingPlanProgress]
    @State private var navigateToStudy = false
    @State private var selectedReference = ""

    private var progress: ReadingPlanProgress? {
        viewModel.progress(for: plan.id, from: allProgress)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLG) {
                // Header
                VStack(spacing: AppTheme.spacingMD) {
                    Image(systemName: plan.icon)
                        .font(.system(size: 36))
                        .foregroundColor(AppTheme.gold)

                    Text(plan.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(plan.description)
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)

                    let completion = viewModel.completionPercentage(plan: plan, progress: progress)
                    if progress != nil {
                        VStack(spacing: 4) {
                            ProgressView(value: completion)
                                .tint(AppTheme.gold)
                            Text("\(Int(completion * 100))% complete")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .padding(.horizontal, AppTheme.spacingXL)
                    }
                }
                .padding(.top, AppTheme.spacingXL)

                // Start button if not started
                if progress == nil {
                    Button {
                        _ = viewModel.startPlan(planId: plan.id, context: modelContext)
                    } label: {
                        Text("Start Plan")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacingMD)
                            .background(AppTheme.accent)
                            .cornerRadius(AppTheme.cornerRadiusSM)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                }

                // Day list
                VStack(spacing: AppTheme.spacingSM) {
                    ForEach(plan.days) { day in
                        let isCompleted = progress?.isCompleted(day: day.day) ?? false

                        Button {
                            if let progress = progress {
                                viewModel.toggleDay(day.day, for: progress)
                            }
                            selectedReference = day.reference
                            navigateToStudy = true
                        } label: {
                            HStack(spacing: AppTheme.spacingMD) {
                                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundColor(isCompleted ? AppTheme.success : AppTheme.textMuted)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Day \(day.day)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(AppTheme.textMuted)
                                    Text(day.title)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text(day.reference)
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(AppTheme.accent)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            .padding(AppTheme.spacingMD)
                            .background(isCompleted ? AppTheme.success.opacity(0.08) : AppTheme.surface)
                            .cornerRadius(AppTheme.cornerRadiusSM)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacingLG)

                Spacer(minLength: AppTheme.spacing3XL)
            }
        }
        .background(AppTheme.background)
        .navigationTitle(plan.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToStudy) {
            StudyView(initialReference: selectedReference, initialMode: nil)
        }
    }
}
