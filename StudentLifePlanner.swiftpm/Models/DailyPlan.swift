import Foundation

struct DailyPlan: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var activities: [Activity]
}
