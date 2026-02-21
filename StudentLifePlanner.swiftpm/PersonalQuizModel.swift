import Foundation
import SwiftUI

// MARK: - Personal Quiz Models

struct PersonalQuiz: Codable, Identifiable {
    let id: UUID
    var title: String
    var questions: [PersonalQuestion]
    var createdAt: Date
    
    init(title: String, questions: [PersonalQuestion] = []) {
        self.id = UUID()
        self.title = title
        self.questions = questions
        self.createdAt = Date()
    }
    
    var questionCount: Int { questions.count }
}

struct PersonalQuestion: Codable, Identifiable {
    let id: UUID
    var question: String
    var options: [String]
    var correctIndex: Int
    
    init(question: String, options: [String], correctIndex: Int) {
        self.id = UUID()
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
    }
}

// MARK: - Personal Quiz Manager
@MainActor
class PersonalQuizManager: ObservableObject {
    static let shared = PersonalQuizManager()
    
    @Published var quizzes: [PersonalQuiz] = []
    private let key = "personalQuizzes"
    
    private init() { load() }
    
    func addQuiz(_ quiz: PersonalQuiz) {
        quizzes.insert(quiz, at: 0)
        save()
    }
    
    func deleteQuiz(id: UUID) {
        quizzes.removeAll { $0.id == id }
        save()
    }
    
    func updateQuiz(_ quiz: PersonalQuiz) {
        if let idx = quizzes.firstIndex(where: { $0.id == quiz.id }) {
            quizzes[idx] = quiz
            save()
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([PersonalQuiz].self, from: data) {
            quizzes = saved
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(quizzes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // MARK: - PDF Text → Questions Generator
    static func generateQuestions(from text: String, count: Int = 10) -> [PersonalQuestion] {
        // Split text into sentences
        let sentences = text
            .replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 20 && $0.count < 200 }
        
        guard !sentences.isEmpty else { return [] }
        
        var questions: [PersonalQuestion] = []
        let shuffled = sentences.shuffled()
        
        for sentence in shuffled.prefix(count) {
            let words = sentence.components(separatedBy: " ").filter { $0.count > 3 }
            guard words.count >= 4 else { continue }
            
            // Pick a key word to blank out
            let keyWords = words.filter { $0.first?.isUppercase == true || $0.count > 5 }
            let targetWord = (keyWords.isEmpty ? words : keyWords).randomElement() ?? words[0]
            let cleanTarget = targetWord.trimmingCharacters(in: .punctuationCharacters)
            
            // Create question
            let questionText = sentence.replacingOccurrences(of: cleanTarget, with: "______")
            
            // Generate wrong options from other words in the text
            let otherWords = sentences.flatMap { $0.components(separatedBy: " ") }
                .filter { $0.count > 3 && $0 != cleanTarget }
                .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            let uniqueOthers = Array(Set(otherWords)).shuffled()
            
            var options = [cleanTarget]
            for w in uniqueOthers where options.count < 4 && !options.contains(w) {
                options.append(w)
            }
            while options.count < 4 { options.append("Option \(options.count)") }
            
            let correctIdx = 0
            options.shuffle()
            let finalCorrectIdx = options.firstIndex(of: cleanTarget) ?? 0
            
            let _ = correctIdx // suppress warning
            questions.append(PersonalQuestion(question: "Fill in: \(questionText)", options: options, correctIndex: finalCorrectIdx))
        }
        
        return questions
    }
}
