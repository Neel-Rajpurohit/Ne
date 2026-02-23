import SwiftUI

// MARK: - Steps ViewModel
@MainActor
class StepsViewModel: ObservableObject {
    @Published var healthKit = HealthKitManager.shared
    @Published var storage = StorageManager.shared
    
    var todaySteps: Int { healthKit.todaySteps }
    var todayDistance: Double { healthKit.todayDistance }
    var todayCalories: Int { healthKit.todayCalories }
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
    
    // MARK: - Yesterday Comparison
    var yesterdayComparison: Int { healthKit.yesterdayComparison }
    
    // MARK: - Weekly Stats
    var weeklyAverage: Int { healthKit.weeklyAverage }
    
    var bestDayLabel: String {
        guard let best = healthKit.bestDay else { return "—" }
        return "\(best.date.shortDayName): \(best.steps.withCommas)"
    }
    
    // MARK: - Habit Score (0-100)
    var habitScore: Int { healthKit.habitScore }
    
    // MARK: - Smart Insight
    var todayInsight: String {
        // Using mock data notice
        if healthKit.isUsingMockData {
            return "📱 Install on iPhone for real step data"
        }
        
        let comparison = healthKit.yesterdayComparison
        if healthKit.yesterdaySteps == 0 {
            if todaySteps > 0 {
                return "Great start to a new day! Keep moving 🚀"
            }
            return "Time to start walking! 👟"
        }
        
        if comparison > 20 {
            return "You walked \(comparison)% more than yesterday! 🚀"
        } else if comparison > 0 {
            return "Slightly ahead of yesterday — keep going! ⬆️"
        } else if comparison == 0 {
            return "Same as yesterday — keep it up! ⭐️"
        } else if comparison > -20 {
            return "You need \(abs(todaySteps - healthKit.yesterdaySteps).withCommas) more steps to beat yesterday 💪"
        } else {
            return "Let's push harder today! You're \(abs(comparison))% behind yesterday 🏃"
        }
    }
    
    // MARK: - Active Time (estimated)
    var estimatedActiveMinutes: Int {
        todaySteps / 100 // ~100 steps per minute
    }
    
    func refresh() {
        healthKit.refresh()
    }
}
