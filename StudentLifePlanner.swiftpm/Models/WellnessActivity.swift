import Foundation

struct WellnessActivity: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: WellnessType
    var durationMinutes: Int
    
    enum WellnessType: String, Codable, CaseIterable {
        case meditation = "Meditation"
        case exercise = "Exercise"
        case yoga = "Yoga"
        case breathing = "Breathing"
    }
}
