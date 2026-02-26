import Foundation

// MARK: - Quiz Category
enum QuizCategory: String, Codable, CaseIterable, Sendable {
    case science = "Science"
    case history = "History"
    case geography = "Geography"
    case technology = "Technology"
    case general = "General"
    
    var icon: String {
        switch self {
        case .science: return "atom"
        case .history: return "clock.arrow.circlepath"
        case .geography: return "globe.americas.fill"
        case .technology: return "desktopcomputer"
        case .general: return "lightbulb.fill"
        }
    }
}

// MARK: - Question Difficulty
enum QuizDifficulty: String, Codable, CaseIterable, Sendable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: String {
        switch self {
        case .easy: return "10B981"
        case .medium: return "F59E0B"
        case .hard: return "EF4444"
        }
    }
}

// MARK: - GK Question
struct GKQuestion: Codable, Identifiable, Sendable {
    let id: UUID
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let category: QuizCategory
    let difficulty: QuizDifficulty
    
    init(question: String, options: [String], correctAnswerIndex: Int, category: QuizCategory, difficulty: QuizDifficulty) {
        self.id = UUID()
        self.question = question
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.category = category
        self.difficulty = difficulty
    }
}

// MARK: - Quiz Result
struct QuizResult: Codable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let category: QuizCategory
    let totalQuestions: Int
    let correctAnswers: Int
    let timeTaken: Int // seconds
    let xpEarned: Int
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    var score: String {
        "\(correctAnswers)/\(totalQuestions)"
    }
    
    init(category: QuizCategory, totalQuestions: Int, correctAnswers: Int, timeTaken: Int, xpEarned: Int) {
        self.id = UUID()
        self.date = Date()
        self.category = category
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.timeTaken = timeTaken
        self.xpEarned = xpEarned
    }
}
