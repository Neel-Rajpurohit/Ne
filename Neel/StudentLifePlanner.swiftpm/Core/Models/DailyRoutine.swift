import Foundation

enum RoutineCategory: String, Codable {
    case study = "Study"
    case meal = "Meal"
    case exercise = "Exercise"
    case relaxation = "Relaxation"
    case sleep = "Sleep"
}

struct RoutineTask: Identifiable, Codable {
    let id: UUID
    let title: String
    let time: String
    let category: RoutineCategory
    var isCompleted: Bool
    
    init(title: String, time: String, category: RoutineCategory, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.time = time
        self.category = category
        self.isCompleted = isCompleted
    }
}
