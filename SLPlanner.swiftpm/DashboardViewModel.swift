import SwiftUI

// MARK: - Dashboard ViewModel
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var healthKit = HealthKitManager.shared
    @Published var storage = StorageManager.shared
    @Published var gameEngine = GameEngineManager.shared
    @Published var wellness = WellnessDataStore.shared

    var totalRunDistance: Double {
        healthKit.todayDistance + wellness.today.runKM
    }

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

        let runProgress =
            ProfileManager.shared.profile.recommendedRunKM > 0
            ? totalRunDistance / ProfileManager.shared.profile.recommendedRunKM : 0
        let waterProgress =
            storage.userGoals.dailyWaterGoal > 0
            ? storage.todayWater.totalML / storage.userGoals.dailyWaterGoal : 0
        motivationalMessage = GreetingHelper.motivationalMessage(
            runProgress: runProgress, waterProgress: waterProgress)

        if runProgress >= 1.0 && waterProgress >= 1.0 {
            storage.recordDailyGoalMet()
        }
    }

    var runProgress: Double {
        let profile = ProfileManager.shared.profile
        guard profile.recommendedRunKM > 0 else { return 0 }
        return totalRunDistance / profile.recommendedRunKM
    }

    var waterProgress: Double {
        storage.todayWater.progress(goal: storage.userGoals.dailyWaterGoal)
    }
}
