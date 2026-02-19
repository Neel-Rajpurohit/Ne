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
    
    // MARK: - GK Quiz Logic
    struct GKQuestion {
        let question: String
        let answer: String
        let options: [String]
    }
    
    func generateGKQuestion() -> GKQuestion {
        let questions = [
            GKQuestion(question: "What is the capital of France?", answer: "Paris", options: ["London", "Berlin", "Paris", "Madrid"]),
            GKQuestion(question: "Which planet is known as the Red Planet?", answer: "Mars", options: ["Venus", "Mars", "Jupiter", "Saturn"]),
            GKQuestion(question: "What is the largest mammal in the world?", answer: "Blue Whale", options: ["Elephant", "Blue Whale", "Giraffe", "Orca"]),
            GKQuestion(question: "Who painted the Mona Lisa?", answer: "Leonardo da Vinci", options: ["Pablo Picasso", "Vincent van Gogh", "Leonardo da Vinci", "Claude Monet"]),
            GKQuestion(question: "What is the smallest country in the world?", answer: "Vatican City", options: ["Monaco", "Nauru", "Vatican City", "Tuvalu"]),
            GKQuestion(question: "Which element has the chemical symbol 'O'?", answer: "Oxygen", options: ["Gold", "Silver", "Oxygen", "Iron"]),
            GKQuestion(question: "What is the longest river in the world?", answer: "Nile", options: ["Amazon", "Nile", "Mississippi", "Yangtze"]),
            GKQuestion(question: "Who wrote 'Romeo and Juliet'?", answer: "William Shakespeare", options: ["Charles Dickens", "William Shakespeare", "Mark Twain", "Jane Austen"]),
            GKQuestion(question: "In which year did the Titanic sink?", answer: "1912", options: ["1905", "1912", "1920", "1915"]),
            GKQuestion(question: "What is the hardest natural substance on Earth?", answer: "Diamond", options: ["Gold", "Iron", "Diamond", "Quartz"])
        ]
        return questions.randomElement()!
    }
}
