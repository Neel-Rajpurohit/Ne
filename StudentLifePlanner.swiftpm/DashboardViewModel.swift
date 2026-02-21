import SwiftUI

// MARK: - Dashboard ViewModel
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var healthKit = HealthKitManager.shared
    @Published var storage = StorageManager.shared
    @Published var gameEngine = GameEngineManager.shared
    
    @Published var greeting: String = ""
    @Published var motivationalMessage: String = ""
    @Published var todayDate: String = ""
    
    init() {
        refresh()
    }
    
    func refresh() {
        greeting = GreetingHelper.greeting()
        todayDate = Date().greetingDate
        healthKit.refresh()
        
        let stepsProgress = Double(healthKit.todaySteps) / Double(storage.userGoals.dailyStepGoal)
        let waterProgress = storage.todayWater.progress(goal: storage.userGoals.dailyWaterGoal)
        motivationalMessage = GreetingHelper.motivationalMessage(stepsProgress: stepsProgress, waterProgress: waterProgress)
        
        storage.checkStepAchievements(steps: healthKit.todaySteps, distance: healthKit.todayDistance)
        
        if stepsProgress >= 1.0 && waterProgress >= 1.0 {
            storage.recordDailyGoalMet()
        }
    }
    
    var stepsProgress: Double {
        Double(healthKit.todaySteps) / Double(storage.userGoals.dailyStepGoal)
    }
    
    var waterProgress: Double {
        storage.todayWater.progress(goal: storage.userGoals.dailyWaterGoal)
    }
}
