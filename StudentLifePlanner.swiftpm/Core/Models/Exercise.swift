import Foundation

enum ExerciseCategory: String, Codable, CaseIterable {
    case fitness = "Fitness"
    case yoga = "Yoga"
    case breathing = "Breathing"
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let duration: String
    let category: ExerciseCategory
    let iconName: String
    
    init(name: String, description: String, duration: String, category: ExerciseCategory, iconName: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.duration = duration
        self.category = category
        self.iconName = iconName
    }
}
