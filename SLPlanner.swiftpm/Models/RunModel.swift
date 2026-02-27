import Foundation

// MARK: - Run Data
struct RunData: Codable, Identifiable, Sendable {
    var id: String { date.ISO8601Format() }
    var date: Date
    var distance: Double  // in kilometers

    var runProgress: Double {
        distance / AppConstants.defaultRunGoal
    }
}

// MARK: - User Goals
struct UserGoals: Codable, Sendable {
    var dailyRunGoal: Double
    var dailyWaterGoal: Double  // in mL

    static let `default` = UserGoals(
        dailyRunGoal: AppConstants.defaultRunGoal,
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
            let daysBetween =
                Calendar.current.dateComponents(
                    [.day], from: lastDate.startOfDay, to: date.startOfDay
                ).day ?? 0
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
        let daysSince =
            Calendar.current.dateComponents(
                [.day], from: lastDate.startOfDay, to: Date().startOfDay
            ).day ?? 0
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
    var goalValue: Double
    var category: AchievementCategory

    init(
        id: String, title: String, subtitle: String, icon: String, isUnlocked: Bool,
        unlockedDate: Date? = nil, goalValue: Double = 0, category: AchievementCategory = .general
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.goalValue = goalValue
        self.category = category
    }

    static let allAchievements: [Achievement] = [
        // Streak
        Achievement(
            id: "streak3", title: "🔥 3 Day Streak", subtitle: "Complete wellness 3 days in a row",
            icon: "flame.fill", isUnlocked: false, goalValue: 3, category: .streak),
        Achievement(
            id: "streak7", title: "Week Warrior", subtitle: "7 day streak", icon: "flame.fill",
            isUnlocked: false, goalValue: 7, category: .streak),
        Achievement(
            id: "streak21", title: "Habit Builder", subtitle: "21 day streak", icon: "flame.fill",
            isUnlocked: false, goalValue: 21, category: .streak),
        Achievement(
            id: "streak90", title: "Iron Discipline", subtitle: "90 day streak", icon: "crown.fill",
            isUnlocked: false, goalValue: 90, category: .streak),

        // Running
        Achievement(
            id: "run5km", title: "🏃 First 5 KM", subtitle: "Run total 5 KM", icon: "figure.run",
            isUnlocked: false, goalValue: 5, category: .running),
        Achievement(
            id: "run10km", title: "10 KM Runner", subtitle: "Run total 10 KM", icon: "figure.run",
            isUnlocked: false, goalValue: 10, category: .running),
        Achievement(
            id: "run25km", title: "Marathon Prep", subtitle: "Run total 25 KM", icon: "figure.run",
            isUnlocked: false, goalValue: 25, category: .running),
        Achievement(
            id: "run50km", title: "Ultra Runner", subtitle: "Run total 50 KM", icon: "figure.run",
            isUnlocked: false, goalValue: 50, category: .running),
        Achievement(
            id: "run100km", title: "Centurion", subtitle: "Run total 100 KM", icon: "figure.run",
            isUnlocked: false, goalValue: 100, category: .running),

        // Yoga
        Achievement(
            id: "yoga50", title: "🧘 50 Min Yoga", subtitle: "Complete 50 minutes yoga",
            icon: "figure.yoga", isUnlocked: false, goalValue: 50, category: .yoga),
        Achievement(
            id: "yoga100", title: "100 Min Yoga", subtitle: "Complete 100 minutes yoga",
            icon: "figure.yoga", isUnlocked: false, goalValue: 100, category: .yoga),
        Achievement(
            id: "yoga200", title: "Yoga Journey", subtitle: "Complete 200 minutes yoga",
            icon: "figure.yoga", isUnlocked: false, goalValue: 200, category: .yoga),
        Achievement(
            id: "yoga500", title: "Yoga Master", subtitle: "Complete 500 minutes yoga",
            icon: "figure.yoga", isUnlocked: false, goalValue: 500, category: .yoga),

        // Breathing
        Achievement(
            id: "breath10", title: "🌬 10 Sessions", subtitle: "Complete 10 breathing sessions",
            icon: "wind", isUnlocked: false, goalValue: 10, category: .breathing),
        Achievement(
            id: "breath50", title: "Breath Master", subtitle: "Complete 50 sessions", icon: "wind",
            isUnlocked: false, goalValue: 50, category: .breathing),
        Achievement(
            id: "breath100", title: "Deep Focus", subtitle: "Complete 100 sessions", icon: "wind",
            isUnlocked: false, goalValue: 100, category: .breathing),
        Achievement(
            id: "breath200", title: "Zen Mind", subtitle: "Complete 200 sessions", icon: "wind",
            isUnlocked: false, goalValue: 200, category: .breathing),

        // General / Legacy
        Achievement(
            id: "firstGoal", title: "First Steps", subtitle: "Reach your first goal",
            icon: "star.fill", isUnlocked: false, goalValue: 1, category: .general),
        Achievement(
            id: "water5days", title: "Hydration Hero", subtitle: "Water goal 5 days in a row",
            icon: "drop.fill", isUnlocked: false, goalValue: 5, category: .general),

        // Master
        Achievement(
            id: "master10days", title: "🧠 Discipline Pro",
            subtitle: "Complete all daily goals 10 times", icon: "brain.head.profile",
            isUnlocked: false, goalValue: 10, category: .master),
        Achievement(
            id: "level5", title: "Reach Level 5", subtitle: "Level up to 5", icon: "bolt.fill",
            isUnlocked: false, goalValue: 5, category: .master),
        Achievement(
            id: "level10", title: "Reach Level 10", subtitle: "Level up to 10",
            icon: "bolt.shield.fill", isUnlocked: false, goalValue: 10, category: .master),
        Achievement(
            id: "level20", title: "Reach Level 20", subtitle: "Level up to 20", icon: "star.fill",
            isUnlocked: false, goalValue: 20, category: .master),
    ]
}

// MARK: - Achievement Category
enum AchievementCategory: String, Codable, Sendable {
    case streak, running, yoga, breathing, general, master
}

// MARK: - Chart Data Point
struct ChartDataPoint: Identifiable, Sendable {
    let id = UUID()
    let label: String
    let value: Double
    let date: Date
}
