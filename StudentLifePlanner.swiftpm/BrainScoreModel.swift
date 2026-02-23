import SwiftUI
import Foundation

// MARK: - Brain Score Model
// Tracks performance across all brain games

struct BrainScore: Codable, Sendable {
    var focusPoints: Int = 0    // From Focus Runner
    var memoryPoints: Int = 0   // From Memory Cards
    var speedPoints: Int = 0    // From Brain Match
    var gamesPlayed: Int = 0
    var date: Date = Date()
    
    var totalPoints: Int { focusPoints + memoryPoints + speedPoints }
    
    var performancePercent: Int {
        guard gamesPlayed > 0 else { return 0 }
        let maxPerGame = 100
        let maxTotal = gamesPlayed * maxPerGame
        return min(100, (totalPoints * 100) / max(1, maxTotal))
    }
}

// MARK: - Brain Score Manager
@MainActor
class BrainScoreManager: ObservableObject {
    static let shared = BrainScoreManager()
    
    @Published var todayScore: BrainScore = BrainScore()
    
    private let key = "brainScoreToday"
    private let dateKey = "brainScoreDate"
    
    private init() { load() }
    
    // MARK: - Add Points
    func addFocusPoints(_ points: Int) {
        todayScore.focusPoints += points
        todayScore.gamesPlayed += 1
        save()
    }
    
    func addMemoryPoints(_ points: Int) {
        todayScore.memoryPoints += points
        todayScore.gamesPlayed += 1
        save()
    }
    
    func addSpeedPoints(_ points: Int) {
        todayScore.speedPoints += points
        todayScore.gamesPlayed += 1
        save()
    }
    
    // MARK: - Persistence
    private func load() {
        // Check if score is from today
        if let savedDate = UserDefaults.standard.object(forKey: dateKey) as? Date,
           Calendar.current.isDateInToday(savedDate),
           let data = UserDefaults.standard.data(forKey: key),
           let score = try? JSONDecoder().decode(BrainScore.self, from: data) {
            todayScore = score
        } else {
            // New day — reset
            todayScore = BrainScore()
            save()
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(todayScore) {
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.set(Date(), forKey: dateKey)
        }
    }
}
