import Foundation

struct GameScore: Codable {
    var candyMatchHighScore: Int = 0
    var memoryHighScore: Int = 0
    var mathHighScore: Int = 0
    var lastPlayedDate: Date?
    var pointsEarnedToday: Int = 0
    
    static let maxDailyPoints = 3
}
