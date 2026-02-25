import Foundation
import SwiftUI

// MARK: - Daily Wellness Record
struct DailyWellness: Codable, Sendable {
    var date: Date
    var waterML: Double
    var runKM: Double
    var yogaMin: Double
    var breathingMin: Double
    
    var waterGoal: Double
    var runGoal: Double
    var yogaGoal: Double
    var breathingGoal: Double
    
    var waterComplete: Bool { waterML >= waterGoal }
    var runComplete: Bool { runKM >= runGoal }
    var yogaComplete: Bool { yogaMin >= yogaGoal }
    var breathingComplete: Bool { breathingMin >= breathingGoal }
    
    var completedCount: Int {
        [waterComplete, runComplete, yogaComplete, breathingComplete].filter { $0 }.count
    }
    
    var wellnessPercent: Int {
        completedCount * 25
    }
    
    var waterProgress: Double { waterGoal > 0 ? min(waterML / waterGoal, 1.0) : 0 }
    var runProgress: Double { runGoal > 0 ? min(runKM / runGoal, 1.0) : 0 }
    var yogaProgress: Double { yogaGoal > 0 ? min(yogaMin / yogaGoal, 1.0) : 0 }
    var breathingProgress: Double { breathingGoal > 0 ? min(breathingMin / breathingGoal, 1.0) : 0 }
    
    static func empty(for date: Date, profile: UserProfile) -> DailyWellness {
        DailyWellness(
            date: Calendar.current.startOfDay(for: date),
            waterML: 0, runKM: 0, yogaMin: 0, breathingMin: 0,
            waterGoal: profile.recommendedWaterML,
            runGoal: profile.recommendedRunKM,
            yogaGoal: profile.recommendedYogaMin,
            breathingGoal: profile.recommendedBreathingMin
        )
    }
}

// MARK: - Lifetime Stats
struct LifetimeWellnessStats: Codable, Sendable {
    var totalRunKM: Double
    var totalYogaMin: Double
    var totalBreathingSessions: Int
    var totalDaysCompleted: Int // days at 100%
    
    static let empty = LifetimeWellnessStats(
        totalRunKM: 0, totalYogaMin: 0,
        totalBreathingSessions: 0, totalDaysCompleted: 0
    )
}

// MARK: - Wellness Data Store
@MainActor
class WellnessDataStore: ObservableObject {
    static let shared = WellnessDataStore()
    
    @Published var today: DailyWellness
    @Published var lifetime: LifetimeWellnessStats
    @Published var weeklyWellness: [Int] = [] // last 7 days wellness %
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let lifetimeKey = "wellness_lifetime"
    
    private init() {
        let profile = ProfileManager.shared.profile
        
        // Load lifetime
        if let data = UserDefaults.standard.data(forKey: lifetimeKey),
           let saved = try? JSONDecoder().decode(LifetimeWellnessStats.self, from: data) {
            self.lifetime = saved
        } else {
            self.lifetime = .empty
        }
        
        // Load today
        let todayKey = Self.dayKey(for: Date())
        if let data = UserDefaults.standard.data(forKey: todayKey),
           let saved = try? JSONDecoder().decode(DailyWellness.self, from: data) {
            self.today = saved
        } else {
            self.today = .empty(for: Date(), profile: profile)
        }
        
        generateWeeklyData()
    }
    
    // MARK: - Date Key
    nonisolated static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "wellness_\(formatter.string(from: date))"
    }
    
    // MARK: - Day Check & Reset
    func checkDayReset() {
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())
        let startOfStored = cal.startOfDay(for: today.date)
        
        if startOfToday != startOfStored {
            // Previous day: check if 100% was reached
            if today.wellnessPercent >= 100 {
                lifetime.totalDaysCompleted += 1
                saveLifetime()
            }
            
            // Reset for new day
            let profile = ProfileManager.shared.profile
            today = .empty(for: Date(), profile: profile)
            
            // Sync water from StorageManager
            today.waterML = StorageManager.shared.todayWater.totalML
            
            saveToday()
            generateWeeklyData()
        }
    }
    
    // MARK: - Water Sync
    /// Call this when water is added from StorageManager
    func syncWater(_ totalML: Double) {
        today.waterML = totalML
        saveToday()
    }
    
    // MARK: - Running
    func addRun(_ km: Double) {
        today.runKM += km
        lifetime.totalRunKM += km
        saveToday()
        saveLifetime()
        checkAchievements()
        
        if today.wellnessPercent >= 100 {
            onDailyComplete()
        }
    }
    
    // MARK: - Yoga
    func addYoga(_ minutes: Double) {
        today.yogaMin += minutes
        lifetime.totalYogaMin += minutes
        saveToday()
        saveLifetime()
        checkAchievements()
        
        if today.wellnessPercent >= 100 {
            onDailyComplete()
        }
    }
    
    // MARK: - Breathing
    func addBreathing(_ minutes: Double) {
        today.breathingMin += minutes
        lifetime.totalBreathingSessions += 1
        saveToday()
        saveLifetime()
        checkAchievements()
        
        if today.wellnessPercent >= 100 {
            onDailyComplete()
        }
    }
    
    // MARK: - Daily Complete Callback
    private func onDailyComplete() {
        // Record streak
        StorageManager.shared.recordDailyGoalMet()
        
        // Award XP
        GameEngineManager.shared.awardXP(
            amount: 50, source: "Daily Wellness 100%", icon: "heart.fill"
        )
        
        // Schedule completion notification
        NotificationManager.shared.scheduleWellnessCompletionNotification()
    }
    
    // MARK: - Achievement Checking
    private func checkAchievements() {
        let storage = StorageManager.shared
        
        // Running achievements
        if lifetime.totalRunKM >= 5 { storage.unlockAchievementPublic("run5km") }
        if lifetime.totalRunKM >= 10 { storage.unlockAchievementPublic("run10km") }
        if lifetime.totalRunKM >= 25 { storage.unlockAchievementPublic("run25km") }
        if lifetime.totalRunKM >= 50 { storage.unlockAchievementPublic("run50km") }
        if lifetime.totalRunKM >= 100 { storage.unlockAchievementPublic("run100km") }
        
        // Yoga achievements
        if lifetime.totalYogaMin >= 50 { storage.unlockAchievementPublic("yoga50") }
        if lifetime.totalYogaMin >= 100 { storage.unlockAchievementPublic("yoga100") }
        if lifetime.totalYogaMin >= 200 { storage.unlockAchievementPublic("yoga200") }
        if lifetime.totalYogaMin >= 500 { storage.unlockAchievementPublic("yoga500") }
        
        // Breathing achievements
        if lifetime.totalBreathingSessions >= 10 { storage.unlockAchievementPublic("breath10") }
        if lifetime.totalBreathingSessions >= 50 { storage.unlockAchievementPublic("breath50") }
        if lifetime.totalBreathingSessions >= 100 { storage.unlockAchievementPublic("breath100") }
        if lifetime.totalBreathingSessions >= 200 { storage.unlockAchievementPublic("breath200") }
        
        // Master achievements
        if lifetime.totalDaysCompleted >= 10 { storage.unlockAchievementPublic("master10days") }
        
        let level = GameEngineManager.shared.profile.level
        if level >= 5 { storage.unlockAchievementPublic("level5") }
        if level >= 10 { storage.unlockAchievementPublic("level10") }
        if level >= 20 { storage.unlockAchievementPublic("level20") }
    }
    
    // MARK: - Weekly Data
    private func generateWeeklyData() {
        let cal = Calendar.current
        weeklyWellness = (0..<7).reversed().map { offset in
            guard let date = cal.date(byAdding: .day, value: -offset, to: Date()) else { return 0 }
            let key = Self.dayKey(for: date)
            if let data = defaults.data(forKey: key),
               let day = try? decoder.decode(DailyWellness.self, from: data) {
                return day.wellnessPercent
            }
            return 0
        }
    }
    
    // MARK: - Persistence
    private func saveToday() {
        let key = Self.dayKey(for: Date())
        if let data = try? encoder.encode(today) {
            defaults.set(data, forKey: key)
        }
        generateWeeklyData()
    }
    
    private func saveLifetime() {
        if let data = try? encoder.encode(lifetime) {
            defaults.set(data, forKey: lifetimeKey)
        }
    }
}
