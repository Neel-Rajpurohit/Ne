import SwiftUI
import Combine

@MainActor
class PlannerViewModel: ObservableObject {
    @Published var dailyPlan: DailyPlan?
    @Published var points: Points = Points(balance: 10, history: [])
    @Published var profile: UserProfile?
    
    private let storage = LocalStorageService.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        profile = storage.loadUserProfile()
        points = storage.loadPoints()
        
        let plans = storage.loadDailyPlans()
        let today = Date()
        
        if let currentPlan = plans.first(where: { DateHelper.shared.isSameDay($0.date, today) }) {
            dailyPlan = currentPlan
        } else {
            regeneratePlan()
        }
    }
    
    func regeneratePlan() {
        let today = Date()
        let newPlan = PlannerGeneratorService.shared.generatePlan(for: today)
        dailyPlan = newPlan
        
        var plans = storage.loadDailyPlans()
        // Remove existing plan for today if any
        plans.removeAll(where: { DateHelper.shared.isSameDay($0.date, today) })
        plans.append(newPlan)
        storage.saveDailyPlans(plans)
    }
    
    var completionProgress: Double {
        guard let activities = dailyPlan?.activities, !activities.isEmpty else { return 0 }
        let completed = activities.filter { $0.isCompleted }.count
        return Double(completed) / Double(activities.count)
    }
    
    func toggleCompletion(for activityId: UUID) {
        guard var plan = dailyPlan else { return }
        if let index = plan.activities.firstIndex(where: { $0.id == activityId }) {
            plan.activities[index].isCompleted.toggle()
            dailyPlan = plan
            
            // Update points logic could go here
            if plan.activities[index].isCompleted {
                addPoints(2, reason: "Completed \(plan.activities[index].title)")
            } else {
                addPoints(-2, reason: "Unmarked \(plan.activities[index].title)")
            }
            
            savePlan(plan)
        }
    }
    
    private func addPoints(_ amount: Int, reason: String) {
        points.balance += amount
        points.history.insert(Points.PointTransaction(amount: amount, reason: reason, timestamp: Date()), at: 0)
        storage.savePoints(points)
    }
    
    private func savePlan(_ plan: DailyPlan) {
        var plans = storage.loadDailyPlans()
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
        } else {
            plans.append(plan)
        }
        storage.saveDailyPlans(plans)
    }
}
