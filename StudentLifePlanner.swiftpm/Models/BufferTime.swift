import Foundation

struct BufferTime: Codable, Identifiable {
    var id = UUID()
    var durationMinutes: Int
    var reason: String
}
