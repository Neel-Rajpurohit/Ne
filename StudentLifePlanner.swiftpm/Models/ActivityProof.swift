import Foundation

struct ActivityProof: Codable {
    var activityId: UUID
    var imagePath: String
    var timestamp: Date
}
