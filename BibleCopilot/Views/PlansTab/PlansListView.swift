import SwiftUI
import SwiftData

struct PlansListView: View {
    @State private var viewModel = PlansViewModel()
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [ReadingPlanProgress]
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    ForEach(viewModel.plans) { plan in
                        let progress = viewModel.progress(for: plan.id, from: allProgress)
                        let completion = viewModel.completionPercentage(plan: plan, progress: progress)

                        if subscriptionManager.isPro {
                            NavigationLink {
                                PlanDetailView(plan: plan)
                            } label: {
                                planCard(plan: plan, completion: completion, progress: progress)
                            }
                        } else {
                            Button {
                                showPaywall = true
                            } label: {
                                planCard(plan: plan, completion: completion, progress: progress)
                                    .overlay(proOverlay)
                            }
                        }
                    }
                }
                .padding(AppTheme.spacingLG)
            }
            .background(AppTheme.background)
            .navigationTitle("Reading Plans")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private func planCard(plan: ReadingPlanDefinition, completion: Double, progress: ReadingPlanProgress?) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: plan.icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.gold)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.gold.opacity(0.15))
                    .cornerRadius(AppTheme.cornerRadiusSM)

                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("\(plan.days.count) days")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textMuted)
            }

            Text(plan.description)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)

            if progress != nil {
                ProgressView(value: completion)
                    .tint(AppTheme.accent)
                    .background(AppTheme.surface)

                Text("\(Int(completion * 100))% complete")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(AppTheme.spacingLG)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadiusMD)
    }

    private var proOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                .fill(Color.black.opacity(0.4))

            VStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundColor(AppTheme.gold)
                Text("Pro")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.gold)
            }
        }
    }
}
