import Foundation

// MARK: - Steps Data
struct StepsData: Codable, Identifiable, Sendable {
    var id: String { date.ISO8601Format() }
    var date: Date
    var steps: Int
    var distance: Double // in kilometers
    
    var stepProgress: Double {
        Double(steps) / Double(AppConstants.defaultStepGoal)
    }
}

// MARK: - User Goals
struct UserGoals: Codable, Sendable {
    var dailyStepGoal: Int
    var dailyWaterGoal: Double // in mL
    
    static let `default` = UserGoals(
        dailyStepGoal: AppConstants.defaultStepGoal,
        dailyWaterGoal: AppConstants.defaultWaterGoal
    )
}

// MARK: - Streak Data
struct StreakData: Codable, Sendable {
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date?
    
    static let empty = StreakData(currentStreak: 0, longestStreak: 0, lastActiveDate: nil)
    
    mutating func recordGoalMet(on date: Date) {
        if let lastDate = lastActiveDate {
            let daysBetween = Calendar.current.dateComponents([.day], from: lastDate.startOfDay, to: date.startOfDay).day ?? 0
            if daysBetween == 1 {
                currentStreak += 1
            } else if daysBetween > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        longestStreak = max(longestStreak, currentStreak)
        lastActiveDate = date
    }
    
    mutating func checkAndResetIfNeeded() {
        guard let lastDate = lastActiveDate else { return }
        let daysSince = Calendar.current.dateComponents([.day], from: lastDate.startOfDay, to: Date().startOfDay).day ?? 0
        if daysSince > 1 {
            currentStreak = 0
        }
    }
}

// MARK: - Achievement
struct Achievement: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    static let allAchievements: [Achievement] = [
        Achievement(id: "streak7", title: "Week Warrior", subtitle: "7 day streak", icon: "flame.fill", isUnlocked: false),
        Achievement(id: "streak30", title: "Monthly Master", subtitle: "30 day streak", icon: "crown.fill", isUnlocked: false),
        Achievement(id: "steps10k", title: "10K Walker", subtitle: "10,000 steps in a day", icon: "figure.walk", isUnlocked: false),
        Achievement(id: "water5days", title: "Hydration Hero", subtitle: "Water goal 5 days in a row", icon: "drop.fill", isUnlocked: false),
        Achievement(id: "distance5k", title: "5K Champion", subtitle: "Walk 5km in a day", icon: "map.fill", isUnlocked: false),
        Achievement(id: "firstGoal", title: "First Steps", subtitle: "Reach your first goal", icon: "star.fill", isUnlocked: false),
    ]
}

// MARK: - Chart Data Point
struct ChartDataPoint: Identifiable, Sendable {
    let id = UUID()
    let label: String
    let value: Double
    let date: Date
}
