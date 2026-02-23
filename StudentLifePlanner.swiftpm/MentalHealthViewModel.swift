import SwiftUI

// MARK: - Mental Health ViewModel
@MainActor
class MentalHealthViewModel: ObservableObject {
    @Published var logs: [MentalHealthLog] = []
    @Published var todayMood: MoodType?
    
    private let defaults = UserDefaults.standard
    private let logsKey = "mentalHealthLogs"
    
    init() {
        loadLogs()
        todayMood = logs.first(where: { Calendar.current.isDateInToday($0.date) })?.mood
    }
    
    var recentLogs: [MentalHealthLog] { Array(logs.prefix(7)) }
    
    var averageStress: Double {
        let recent = logs.prefix(7)
        guard !recent.isEmpty else { return 0 }
        return Double(recent.reduce(0) { $0 + $1.stressLevel }) / Double(recent.count)
    }
    
    var moodInsight: String {
        guard let mood = todayMood else { return "How are you feeling today?" }
        switch mood {
        case .happy, .energetic, .calm: return "Great mood! Keep the positive energy going ⭐️"
        case .neutral: return "Doing okay. Small wins add up! 🌱"
        case .anxious, .stressed: return "Take a deep breath. Try the breathing exercise 🌬"
        case .sad, .tired: return "Be kind to yourself. Rest is productive too 💙"
        }
    }
    
    func logMood(mood: MoodType, stress: Int, journal: String) {
        let log = MentalHealthLog(mood: mood, stressLevel: stress, journalEntry: journal)
        logs.insert(log, at: 0)
        todayMood = mood
        if logs.count > 100 { logs = Array(logs.prefix(100)) }
        saveLogs()
        
        GameEngineManager.shared.awardXP(amount: GameEngineManager.xpMoodLogged, source: "Mood Logged", icon: "heart.fill")
    }
    
    private func loadLogs() {
        if let data = defaults.data(forKey: logsKey),
           let saved = try? JSONDecoder().decode([MentalHealthLog].self, from: data) { logs = saved }
    }
    private func saveLogs() {
        if let data = try? JSONEncoder().encode(logs) { defaults.set(data, forKey: logsKey) }
    }
}
