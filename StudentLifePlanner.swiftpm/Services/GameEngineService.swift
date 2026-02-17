import SwiftUI
import Combine

@MainActor
class GameEngineService: ObservableObject {
    static let shared = GameEngineService()
    
    @Published var currentGamePoints: Int = 0
    
    private let storage = LocalStorageService.shared
    
    private init() {}
    
    // MARK: - Points & Rewards
    func awardBonusPoint() {
        var score = loadGameScore()
        let today = Calendar.current.startOfDay(for: Date())
        
        // Reset daily points if it's a new day
        if let lastDate = score.lastPlayedDate, Calendar.current.startOfDay(for: lastDate) < today {
            score.pointsEarnedToday = 0
        }
        
        if score.pointsEarnedToday < GameScore.maxDailyPoints {
            score.pointsEarnedToday += 1
            score.lastPlayedDate = Date()
            saveGameScore(score)
            
            // Add to main points system
            let points = storage.loadPoints()
            var history = points.history
            history.append(Points.PointTransaction(amount: 1, reason: "Played a Mind Game", timestamp: Date()))
            storage.savePoints(Points(balance: points.balance + 1, history: history))
        }
    }
    
    // MARK: - Persistence
    func saveGameScore(_ score: GameScore) {
        if let encoded = try? JSONEncoder().encode(score) {
            UserDefaults.standard.set(encoded, forKey: "game_score")
        }
    }
    
    func loadGameScore() -> GameScore {
        guard let data = UserDefaults.standard.data(forKey: "game_score"),
              let score = try? JSONDecoder().decode(GameScore.self, from: data) else {
            return GameScore()
        }
        return score
    }
    
    // MARK: - Math Game Logic
    struct MathProblem {
        let question: String
        let answer: Int
        let options: [Int]
    }
    
    func generateMathProblem() -> MathProblem {
        let a = Int.random(in: 1...20)
        let b = Int.random(in: 1...20)
        let operation = ["+", "-", "×"].randomElement()!
        
        let answer: Int
        switch operation {
        case "+": answer = a + b
        case "-": answer = a - b
        default: answer = a * b
        }
        
        var options = Set<Int>()
        options.insert(answer)
        while options.count < 4 {
            options.insert(answer + Int.random(in: -10...10))
        }
        
        return MathProblem(question: "\(a) \(operation) \(b)", answer: answer, options: Array(options).sorted())
    }
}
