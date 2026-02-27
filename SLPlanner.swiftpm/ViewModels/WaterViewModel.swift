import SwiftUI

// MARK: - Water ViewModel
@MainActor
class WaterViewModel: ObservableObject {
    @Published var storage = StorageManager.shared
    
    var todayIntake: Double { storage.todayWater.totalML }
    var waterGoal: Double { storage.userGoals.dailyWaterGoal }
    
    var progress: Double {
        storage.todayWater.progress(goal: waterGoal)
    }
    
    var remaining: Double {
        max(0, waterGoal - todayIntake)
    }
    
    var weeklyChartData: [ChartDataPoint] {
        storage.weeklyWater.map { intake in
            ChartDataPoint(
                label: intake.date.singleLetterDay,
                value: intake.totalML,
                date: intake.date
            )
        }
    }
    
    var hydrationInsight: String {
        if todayIntake == 0 {
            return "Time to start hydrating! 💧"
        } else if progress >= 1.0 {
            return "Amazing! You've reached your water goal! 🎉"
        } else {
            return "You need \(remaining.asLiters) more to reach your goal 💧"
        }
    }
    
    func addWater(_ amount: Double) {
        storage.addWater(amount)
    }
    
    func undoLast() {
        storage.removeLastWaterEntry()
    }
    
    func refresh() {
        // Re-read from storage
        objectWillChange.send()
    }
}
