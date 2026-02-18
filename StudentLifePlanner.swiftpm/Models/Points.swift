import Foundation

struct Points: Codable {
    var totalPoints: Int
    var balance: Int
    var history: [PointTransaction]
    
    init(totalPoints: Int = 0, balance: Int = 0, history: [PointTransaction] = []) {
        self.totalPoints = totalPoints
        self.balance = balance
        self.history = history
    }
    
    struct PointTransaction: Codable, Identifiable {
        var id = UUID()
        var amount: Int
        var reason: String
        var timestamp: Date
    }
}
