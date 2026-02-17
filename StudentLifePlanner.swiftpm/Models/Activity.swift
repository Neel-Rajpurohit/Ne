import Foundation

struct Activity: Codable, Identifiable {
    var id = UUID()
    var title: String
    var startTime: Date
    var endTime: Date
    var type: ActivityType
    var isCompleted: Bool = false
    var proofImagePath: String?
    
    enum ActivityType: String, Codable {
        case study = "Study"
        case exercise = "Exercise"
        case yoga = "Yoga"
        case breathing = "Breathing"
        case rest = "Rest"
        case school = "School/College"
        case tuition = "Tuition"
        case extraClass = "Extra Class"
        case game = "Mind Game"
    }
}
