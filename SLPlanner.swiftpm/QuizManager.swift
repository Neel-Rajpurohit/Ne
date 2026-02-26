import Foundation

// MARK: - Quiz Manager
@MainActor
class QuizManager: ObservableObject {
    static let shared = QuizManager()
    
    @Published var results: [QuizResult] = []
    
    private let defaults = UserDefaults.standard
    private let resultsKey = "quizResults"
    
    // MARK: - Question Bank (50+ questions)
    let questionBank: [GKQuestion] = [
        // SCIENCE
        GKQuestion(question: "What is the chemical symbol for water?", options: ["H2O", "CO2", "NaCl", "O2"], correctAnswerIndex: 0, category: .science, difficulty: .easy),
        GKQuestion(question: "What planet is known as the Red Planet?", options: ["Venus", "Mars", "Jupiter", "Saturn"], correctAnswerIndex: 1, category: .science, difficulty: .easy),
        GKQuestion(question: "What is the speed of light?", options: ["300,000 km/s", "150,000 km/s", "500,000 km/s", "100,000 km/s"], correctAnswerIndex: 0, category: .science, difficulty: .medium),
        GKQuestion(question: "What is the powerhouse of the cell?", options: ["Nucleus", "Ribosome", "Mitochondria", "Golgi Body"], correctAnswerIndex: 2, category: .science, difficulty: .easy),
        GKQuestion(question: "What gas do plants absorb from the atmosphere?", options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"], correctAnswerIndex: 2, category: .science, difficulty: .easy),
        GKQuestion(question: "What is the hardest natural substance on Earth?", options: ["Gold", "Iron", "Diamond", "Platinum"], correctAnswerIndex: 2, category: .science, difficulty: .easy),
        GKQuestion(question: "What is the smallest unit of matter?", options: ["Molecule", "Atom", "Electron", "Quark"], correctAnswerIndex: 1, category: .science, difficulty: .medium),
        GKQuestion(question: "What is the largest organ in the human body?", options: ["Heart", "Brain", "Liver", "Skin"], correctAnswerIndex: 3, category: .science, difficulty: .medium),
        GKQuestion(question: "What force keeps planets in orbit?", options: ["Magnetism", "Gravity", "Friction", "Inertia"], correctAnswerIndex: 1, category: .science, difficulty: .easy),
        GKQuestion(question: "What is the pH of pure water?", options: ["5", "7", "9", "14"], correctAnswerIndex: 1, category: .science, difficulty: .medium),
        
        // HISTORY
        GKQuestion(question: "Who was the first President of the United States?", options: ["Abraham Lincoln", "Thomas Jefferson", "George Washington", "John Adams"], correctAnswerIndex: 2, category: .history, difficulty: .easy),
        GKQuestion(question: "In what year did World War II end?", options: ["1943", "1944", "1945", "1946"], correctAnswerIndex: 2, category: .history, difficulty: .easy),
        GKQuestion(question: "Who discovered America in 1492?", options: ["Vasco da Gama", "Christopher Columbus", "Ferdinand Magellan", "Marco Polo"], correctAnswerIndex: 1, category: .history, difficulty: .easy),
        GKQuestion(question: "What ancient civilization built the pyramids?", options: ["Romans", "Greeks", "Egyptians", "Persians"], correctAnswerIndex: 2, category: .history, difficulty: .easy),
        GKQuestion(question: "Who wrote the Declaration of Independence?", options: ["Benjamin Franklin", "George Washington", "Thomas Jefferson", "John Adams"], correctAnswerIndex: 2, category: .history, difficulty: .medium),
        GKQuestion(question: "What year did India gain independence?", options: ["1945", "1946", "1947", "1948"], correctAnswerIndex: 2, category: .history, difficulty: .easy),
        GKQuestion(question: "Who was known as Mahatma Gandhi?", options: ["Jawaharlal Nehru", "Subhas Chandra Bose", "Sardar Patel", "Mohandas Karamchand Gandhi"], correctAnswerIndex: 3, category: .history, difficulty: .easy),
        GKQuestion(question: "The Renaissance began in which country?", options: ["France", "England", "Italy", "Germany"], correctAnswerIndex: 2, category: .history, difficulty: .medium),
        GKQuestion(question: "Who was the first man to walk on the Moon?", options: ["Buzz Aldrin", "Neil Armstrong", "Yuri Gagarin", "John Glenn"], correctAnswerIndex: 1, category: .history, difficulty: .easy),
        GKQuestion(question: "What wall fell in 1989?", options: ["Great Wall of China", "Berlin Wall", "Hadrian's Wall", "Wall Street"], correctAnswerIndex: 1, category: .history, difficulty: .medium),
        
        // GEOGRAPHY
        GKQuestion(question: "What is the largest continent?", options: ["Africa", "North America", "Europe", "Asia"], correctAnswerIndex: 3, category: .geography, difficulty: .easy),
        GKQuestion(question: "What is the longest river in the world?", options: ["Amazon", "Nile", "Mississippi", "Yangtze"], correctAnswerIndex: 1, category: .geography, difficulty: .easy),
        GKQuestion(question: "What is the capital of Japan?", options: ["Seoul", "Beijing", "Tokyo", "Bangkok"], correctAnswerIndex: 2, category: .geography, difficulty: .easy),
        GKQuestion(question: "What is the smallest country in the world?", options: ["Monaco", "Vatican City", "San Marino", "Liechtenstein"], correctAnswerIndex: 1, category: .geography, difficulty: .medium),
        GKQuestion(question: "Which ocean is the largest?", options: ["Atlantic", "Indian", "Arctic", "Pacific"], correctAnswerIndex: 3, category: .geography, difficulty: .easy),
        GKQuestion(question: "What is the tallest mountain in the world?", options: ["K2", "Kangchenjunga", "Mount Everest", "Lhotse"], correctAnswerIndex: 2, category: .geography, difficulty: .easy),
        GKQuestion(question: "Which desert is the largest in the world?", options: ["Sahara", "Gobi", "Antarctic", "Arabian"], correctAnswerIndex: 2, category: .geography, difficulty: .hard),
        GKQuestion(question: "What country has the most population?", options: ["USA", "India", "China", "Indonesia"], correctAnswerIndex: 1, category: .geography, difficulty: .easy),
        GKQuestion(question: "What is the capital of Australia?", options: ["Sydney", "Melbourne", "Canberra", "Perth"], correctAnswerIndex: 2, category: .geography, difficulty: .medium),
        GKQuestion(question: "Which country is known as the Land of the Rising Sun?", options: ["China", "Korea", "Japan", "Thailand"], correctAnswerIndex: 2, category: .geography, difficulty: .easy),
        
        // TECHNOLOGY
        GKQuestion(question: "Who founded Apple?", options: ["Bill Gates", "Steve Jobs", "Elon Musk", "Jeff Bezos"], correctAnswerIndex: 1, category: .technology, difficulty: .easy),
        GKQuestion(question: "What does HTML stand for?", options: ["Hyper Text Markup Language", "High Tech Modern Language", "Hyper Transfer Model Language", "Home Tool Markup Language"], correctAnswerIndex: 0, category: .technology, difficulty: .easy),
        GKQuestion(question: "What year was the iPhone first released?", options: ["2005", "2006", "2007", "2008"], correctAnswerIndex: 2, category: .technology, difficulty: .medium),
        GKQuestion(question: "What does CPU stand for?", options: ["Central Processing Unit", "Computer Personal Unit", "Central Program Utility", "Core Processing Unit"], correctAnswerIndex: 0, category: .technology, difficulty: .easy),
        GKQuestion(question: "Who is the CEO of Tesla?", options: ["Tim Cook", "Elon Musk", "Sundar Pichai", "Mark Zuckerberg"], correctAnswerIndex: 1, category: .technology, difficulty: .easy),
        GKQuestion(question: "What programming language is used for iOS apps?", options: ["Java", "Python", "Swift", "C++"], correctAnswerIndex: 2, category: .technology, difficulty: .easy),
        GKQuestion(question: "What does AI stand for?", options: ["Automated Intelligence", "Artificial Intelligence", "Advanced Integration", "Applied Information"], correctAnswerIndex: 1, category: .technology, difficulty: .easy),
        GKQuestion(question: "What company created Android?", options: ["Apple", "Microsoft", "Google", "Samsung"], correctAnswerIndex: 2, category: .technology, difficulty: .easy),
        GKQuestion(question: "What is the largest tech company by market cap (2024)?", options: ["Google", "Microsoft", "Apple", "Amazon"], correctAnswerIndex: 2, category: .technology, difficulty: .medium),
        GKQuestion(question: "What does RAM stand for?", options: ["Random Access Memory", "Read Access Mode", "Rapid Access Memory", "Remote Access Module"], correctAnswerIndex: 0, category: .technology, difficulty: .easy),
        
        // GENERAL
        GKQuestion(question: "How many continents are there?", options: ["5", "6", "7", "8"], correctAnswerIndex: 2, category: .general, difficulty: .easy),
        GKQuestion(question: "What is the currency of Japan?", options: ["Yuan", "Won", "Yen", "Ringgit"], correctAnswerIndex: 2, category: .general, difficulty: .easy),
        GKQuestion(question: "How many colors are in a rainbow?", options: ["5", "6", "7", "8"], correctAnswerIndex: 2, category: .general, difficulty: .easy),
        GKQuestion(question: "What sport is played at Wimbledon?", options: ["Cricket", "Soccer", "Tennis", "Golf"], correctAnswerIndex: 2, category: .general, difficulty: .easy),
        GKQuestion(question: "How many players are on a soccer team?", options: ["9", "10", "11", "12"], correctAnswerIndex: 2, category: .general, difficulty: .easy),
        GKQuestion(question: "What is the largest animal in the world?", options: ["Elephant", "Blue Whale", "Giraffe", "Great White Shark"], correctAnswerIndex: 1, category: .general, difficulty: .easy),
        GKQuestion(question: "What is the main language spoken in Brazil?", options: ["Spanish", "Portuguese", "English", "French"], correctAnswerIndex: 1, category: .general, difficulty: .medium),
        GKQuestion(question: "How many bones are in the adult human body?", options: ["196", "206", "216", "226"], correctAnswerIndex: 1, category: .general, difficulty: .medium),
        GKQuestion(question: "What is the fastest land animal?", options: ["Lion", "Cheetah", "Gazelle", "Horse"], correctAnswerIndex: 1, category: .general, difficulty: .easy),
        GKQuestion(question: "What element does the Sun primarily consist of?", options: ["Oxygen", "Carbon", "Helium", "Hydrogen"], correctAnswerIndex: 3, category: .general, difficulty: .medium),
    ]
    
    private init() {
        loadResults()
    }
    
    func getQuestions(category: QuizCategory?, count: Int = 10) -> [GKQuestion] {
        var pool = questionBank
        if let category = category {
            pool = pool.filter { $0.category == category }
        }
        return Array(pool.shuffled().prefix(count))
    }
    
    func saveResult(_ result: QuizResult) {
        results.insert(result, at: 0)
        if results.count > 50 { results = Array(results.prefix(50)) }
        
        if let data = try? JSONEncoder().encode(results) {
            defaults.set(data, forKey: resultsKey)
        }
    }
    
    var averageAccuracy: Double {
        guard !results.isEmpty else { return 0 }
        return results.reduce(0) { $0 + $1.accuracy } / Double(results.count)
    }
    
    var totalQuizzesTaken: Int { results.count }
    
    func bestResult(for category: QuizCategory) -> QuizResult? {
        results.filter { $0.category == category }.max(by: { $0.accuracy < $1.accuracy })
    }
    
    private func loadResults() {
        if let data = defaults.data(forKey: resultsKey),
           let saved = try? JSONDecoder().decode([QuizResult].self, from: data) {
            results = saved
        }
    }
}
