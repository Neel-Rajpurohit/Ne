import SwiftUI

// MARK: - Game Model
struct PlayerProfile: Codable, Sendable {
    var level: Int
    var currentXP: Int
    var totalXP: Int
    var title: String
    
    var xpForNextLevel: Int {
        GameEngineManager.xpRequired(for: level + 1)
    }
    
    var levelProgress: Double {
        let currentLevelXP = GameEngineManager.xpRequired(for: level)
        let nextLevelXP = GameEngineManager.xpRequired(for: level + 1)
        let range = nextLevelXP - currentLevelXP
        guard range > 0 else { return 1.0 }
        return Double(currentXP - currentLevelXP) / Double(range)
    }
    
    static let starter = PlayerProfile(level: 1, currentXP: 0, totalXP: 0, title: "Beginner")
}

struct XPEvent: Identifiable, Sendable {
    let id = UUID()
    let source: String
    let amount: Int
    let timestamp: Date
    let icon: String
}

// MARK: - Game Engine Manager
@MainActor
class GameEngineManager: ObservableObject {
    static let shared = GameEngineManager()
    
    @Published var profile: PlayerProfile
    @Published var recentXP: [XPEvent] = []
    @Published var showXPPopup: Bool = false
    @Published var lastXPGained: Int = 0
    
    private let defaults = UserDefaults.standard
    private let profileKey = "playerProfile"
    
    // XP Rewards
    static let xpStudyPerMinute = 2
    static let xpStepGoalMet = 50
    static let xpWaterGoalMet = 30
    static let xpQuizCorrect = 10
    static let xpQuizPerfect = 50
    static let xpExerciseComplete = 25
    static let xpYogaComplete = 20
    static let xpBreathingComplete = 15
    static let xpSleepGoalMet = 20
    static let xpMoodLogged = 10
    static let xpStreakBonus = 10
    
    // Level thresholds: each level needs more XP
    nonisolated static func xpRequired(for level: Int) -> Int {
        guard level > 1 else { return 0 }
        return (level - 1) * (level - 1) * 100
    }
    
    // RPG Titles
    nonisolated static func title(for level: Int) -> String {
        switch level {
        case 1...3: return "Beginner"
        case 4...6: return "Apprentice"
        case 7...10: return "Scholar"
        case 11...15: return "Warrior"
        case 16...20: return "Champion"
        case 21...25: return "Master"
        case 26...30: return "Grandmaster"
        case 31...40: return "Legend"
        default: return "Mythic"
        }
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let saved = try? JSONDecoder().decode(PlayerProfile.self, from: data) {
            self.profile = saved
        } else {
            self.profile = .starter
        }
    }
    
    func awardXP(amount: Int, source: String, icon: String) {
        profile.currentXP += amount
        profile.totalXP += amount
        lastXPGained = amount
        
        let event = XPEvent(source: source, amount: amount, timestamp: Date(), icon: icon)
        recentXP.insert(event, at: 0)
        if recentXP.count > 20 { recentXP = Array(recentXP.prefix(20)) }
        
        // Check level up
        while profile.currentXP >= GameEngineManager.xpRequired(for: profile.level + 1) {
            profile.level += 1
            profile.title = GameEngineManager.title(for: profile.level)
            HapticManager.notification(.success)
        }
        
        showXPPopup = true
        save()
        
        // Auto-hide popup
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showXPPopup = false
        }
    }
    
    func resetProfile() {
        profile = .starter
        recentXP = []
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: profileKey)
        }
    }
}
