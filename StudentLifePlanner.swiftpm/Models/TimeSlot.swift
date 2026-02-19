import Foundation

struct TimeSlot: Codable, Identifiable {
    var id = UUID()
    var startTime: Date
    var endTime: Date
    var isOccupied: Bool = false
    var activityId: UUID?
}
