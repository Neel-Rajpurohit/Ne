import Foundation

enum YogaDifficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct YogaPose: Identifiable, Codable {
    let id: UUID
    let name: String
    let sanskritName: String
    let description: String
    let benefits: String
    let duration: String
    let difficulty: YogaDifficulty
    let iconName: String
    
    init(name: String, sanskritName: String, description: String, benefits: String, duration: String, difficulty: YogaDifficulty, iconName: String) {
        self.id = UUID()
        self.name = name
        self.sanskritName = sanskritName
        self.description = description
        self.benefits = benefits
        self.duration = duration
        self.difficulty = difficulty
        self.iconName = iconName
    }
}
