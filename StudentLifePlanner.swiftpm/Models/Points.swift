import Foundation

struct Points: Codable {
    var balance: Int
    var history: [PointTransaction]
    
    struct PointTransaction: Codable, Identifiable {
        var id = UUID()
        var amount: Int
        var reason: String
        var timestamp: Date
    }
}
