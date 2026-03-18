import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
class PlansViewModel {
    var plans: [ReadingPlanDefinition] = ReadingPlans.all

    func progress(for planId: String, from progressList: [ReadingPlanProgress]) -> ReadingPlanProgress? {
        progressList.first { $0.planId == planId }
    }

    func startPlan(planId: String, context: ModelContext) -> ReadingPlanProgress {
        let progress = ReadingPlanProgress(planId: planId)
        context.insert(progress)
        return progress
    }

    func toggleDay(_ day: Int, for progress: ReadingPlanProgress) {
        progress.toggleDay(day)
    }

    func completionPercentage(plan: ReadingPlanDefinition, progress: ReadingPlanProgress?) -> Double {
        guard let progress = progress, !plan.days.isEmpty else { return 0 }
        return Double(progress.totalCompleted) / Double(plan.days.count)
    }
}
