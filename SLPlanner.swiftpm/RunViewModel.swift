import SwiftUI

// MARK: - Run ViewModel
@MainActor
class RunViewModel: ObservableObject {
    @Published var healthKit = HealthKitManager.shared
    @Published var storage = StorageManager.shared
    @Published var wellness = WellnessDataStore.shared

    var todayDistance: Double { healthKit.todayDistance + wellness.today.runKM }
    var todayCalories: Int { healthKit.todayCalories }

    var runGoalKM: Double { ProfileManager.shared.profile.recommendedRunKM }

    var progress: Double {
        guard runGoalKM > 0 else { return 0 }
        return todayDistance / runGoalKM
    }

    var weeklyChartData: [ChartDataPoint] {
        healthKit.weeklyDistance.map { data in
            ChartDataPoint(
                label: data.date.singleLetterDay,
                value: data.distance,
                date: data.date
            )
        }
    }

    // MARK: - Weekly Stats
    var weeklyAverage: Double { healthKit.weeklyAverage }

    var bestDayLabel: String {
        guard let best = healthKit.bestDay else { return "—" }
        return "\(best.date.shortDayName): \(String(format: "%.1f", best.distance)) KM"
    }

    // MARK: - Habit Score (0-100)
    var habitScore: Int { healthKit.habitScore }

    // MARK: - Smart Insight
    var todayInsight: String {
        // Using mock data notice
        if healthKit.isUsingMockData {
            return "📱 Tracker active"
        }

        if todayDistance > 0 {
            return "Great start to a new day! Keep moving 🚀"
        }
        return "Time to start your run! 👟"
    }

    // MARK: - Active Time (estimated)
    var estimatedActiveMinutes: Int {
        Int(todayDistance * 10)  // ~10 mins per km
    }

    func refresh() {
        healthKit.refresh()
    }
}
