import Foundation

// MARK: - Storage Manager
@MainActor
class StorageManager: ObservableObject {
    static let shared = StorageManager()

    @Published var userGoals: UserGoals
    @Published var streakData: StreakData
    @Published var todayWater: WaterIntake
    @Published var weeklyWater: [WaterIntake] = []
    @Published var achievements: [Achievement]
    @Published var isDarkMode: Bool

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        // Load goals
        if let data = UserDefaults.standard.data(forKey: AppConstants.runGoalKey),
            let goals = try? JSONDecoder().decode(UserGoals.self, from: data)
        {
            self.userGoals = goals
        } else {
            self.userGoals = .default
        }

        // Load streak
        if let data = UserDefaults.standard.data(forKey: AppConstants.streakKey),
            let streak = try? JSONDecoder().decode(StreakData.self, from: data)
        {
            self.streakData = streak
        } else {
            self.streakData = .empty
        }

        // Load dark mode
        self.isDarkMode = UserDefaults.standard.bool(forKey: AppConstants.darkModeKey)

        // Load achievements
        if let data = UserDefaults.standard.data(forKey: AppConstants.achievementsKey),
            let saved = try? JSONDecoder().decode([Achievement].self, from: data)
        {

            // Merge newly added achievements with the saved ones to ensure users get updates
            var merged = saved
            for defaultAchievement in Achievement.allAchievements {
                if !merged.contains(where: { $0.id == defaultAchievement.id }) {
                    merged.append(defaultAchievement)
                }
            }
            self.achievements = merged

        } else {
            self.achievements = Achievement.allAchievements
        }

        // Load today's water
        self.todayWater = .empty(for: Date())
        self.weeklyWater = []

        loadWaterData()
        generateWeeklyWater()
        streakData.checkAndResetIfNeeded()
    }

    // MARK: - Water Management
    func addWater(_ amount: Double) {
        let entry = WaterEntry(amountML: amount)
        todayWater.entries.append(entry)
        todayWater.totalML += amount
        saveWaterData()

        // Update weekly data
        if let idx = weeklyWater.firstIndex(where: { $0.date.isSameDay(as: Date()) }) {
            weeklyWater[idx] = todayWater
        }

        checkAchievements()
    }

    func removeLastWaterEntry() {
        guard let last = todayWater.entries.last else { return }
        todayWater.totalML -= last.amountML
        todayWater.entries.removeLast()
        saveWaterData()
    }

    // MARK: - Goals
    func updateRunGoal(_ goal: Double) {
        userGoals.dailyRunGoal = goal
        saveGoals()
    }

    func updateWaterGoal(_ goal: Double) {
        userGoals.dailyWaterGoal = goal
        saveGoals()
    }

    // MARK: - Streak
    func recordDailyGoalMet() {
        streakData.recordGoalMet(on: Date())
        saveStreak()
        checkAchievements()
    }

    // MARK: - Dark Mode
    func toggleDarkMode() {
        isDarkMode.toggle()
        defaults.set(isDarkMode, forKey: AppConstants.darkModeKey)
    }

    // MARK: - Reset
    func resetAllData() {
        todayWater = .empty(for: Date())
        streakData = .empty
        userGoals = .default
        achievements = Achievement.allAchievements
        weeklyWater = []

        defaults.removeObject(forKey: AppConstants.waterIntakeKey)
        defaults.removeObject(forKey: AppConstants.streakKey)
        defaults.removeObject(forKey: AppConstants.runGoalKey)
        defaults.removeObject(forKey: AppConstants.achievementsKey)

        generateWeeklyWater()
    }

    // MARK: - Achievement Checking
    func checkAchievements() {
        // First Goal
        if todayWater.totalML >= userGoals.dailyWaterGoal {
            unlockAchievement("firstGoal")
        }

        // Streak achievements
        if streakData.currentStreak >= 3 {
            unlockAchievement("streak3")
        }
        if streakData.currentStreak >= 7 {
            unlockAchievement("streak7")
        }
        if streakData.currentStreak >= 21 {
            unlockAchievement("streak21")
        }
        if streakData.currentStreak >= 90 {
            unlockAchievement("streak90")
        }

        saveAchievements()
    }

    private func unlockAchievement(_ id: String) {
        if let idx = achievements.firstIndex(where: { $0.id == id && !$0.isUnlocked }) {
            achievements[idx].isUnlocked = true
            achievements[idx].unlockedDate = Date()
        }
    }

    /// Public wrapper for WellnessDataStore achievement unlocking
    func unlockAchievementPublic(_ id: String) {
        unlockAchievement(id)
        saveAchievements()
    }

    // MARK: - Persistence
    private func saveWaterData() {
        if let data = try? encoder.encode(todayWater) {
            let key = waterKey(for: Date())
            defaults.set(data, forKey: key)
        }
    }

    private func loadWaterData() {
        let key = waterKey(for: Date())
        if let data = defaults.data(forKey: key),
            let intake = try? decoder.decode(WaterIntake.self, from: data)
        {
            todayWater = intake
        } else {
            todayWater = .empty(for: Date())
        }
    }

    private func generateWeeklyWater() {
        weeklyWater = Date.lastSevenDays.map { date in
            let key = waterKey(for: date)
            if let data = defaults.data(forKey: key),
                let intake = try? decoder.decode(WaterIntake.self, from: data)
            {
                return intake
            } else if Calendar.current.isDateInToday(date) {
                return todayWater
            } else {
                // Generate mock historical water data
                let amount = Double.random(in: 800...3000)
                return WaterIntake(date: date.startOfDay, totalML: amount, entries: [])
            }
        }
    }

    private func waterKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "water_\(formatter.string(from: date))"
    }

    private func saveGoals() {
        if let data = try? encoder.encode(userGoals) {
            defaults.set(data, forKey: AppConstants.runGoalKey)
        }
    }

    private func saveStreak() {
        if let data = try? encoder.encode(streakData) {
            defaults.set(data, forKey: AppConstants.streakKey)
        }
    }

    private func saveAchievements() {
        if let data = try? encoder.encode(achievements) {
            defaults.set(data, forKey: AppConstants.achievementsKey)
        }
    }
}
