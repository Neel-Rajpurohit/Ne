import SwiftUI

// MARK: - Steps ViewModel
@MainActor
class StepsViewModel: ObservableObject {
    @Published var healthKit = HealthKitManager.shared
    @Published var storage = StorageManager.shared
    
    var todaySteps: Int { healthKit.todaySteps }
    var todayDistance: Double { healthKit.todayDistance }
    var stepGoal: Int { storage.userGoals.dailyStepGoal }
    
    var progress: Double {
        Double(todaySteps) / Double(stepGoal)
    }
    
    var weeklyChartData: [ChartDataPoint] {
        healthKit.weeklySteps.map { data in
            ChartDataPoint(
                label: data.date.singleLetterDay,
                value: Double(data.steps),
                date: data.date
            )
        }
    }
    
    var todayInsight: String {
        guard healthKit.weeklySteps.count >= 2 else { return "Keep walking!" }
        let yesterday = healthKit.weeklySteps.dropLast().last
        guard let yesterdaySteps = yesterday?.steps, yesterdaySteps > 0 else {
            return "Great start to a new day!"
        }
        let diff = todaySteps - yesterdaySteps
        let pct = abs(Int(Double(diff) / Double(yesterdaySteps) * 100))
        if diff > 0 {
            return "You walked \(pct)% more than yesterday! 🚀"
        } else if diff < 0 {
            return "You need \(abs(diff).withCommas) more steps to beat yesterday 💪"
        } else {
            return "Same as yesterday — keep it up! ⭐️"
        }
    }
    
    func refresh() {
        healthKit.refresh()
    }
}
