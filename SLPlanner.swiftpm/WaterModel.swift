import Foundation

// MARK: - Water Intake Record
struct WaterIntake: Codable, Identifiable, Sendable {
    var id: String { date.ISO8601Format() }
    var date: Date
    var totalML: Double
    var entries: [WaterEntry]
    
    var totalLiters: Double { totalML / 1000.0 }
    
    func progress(goal: Double) -> Double {
        (totalML / goal).clamped01
    }
    
    static func empty(for date: Date) -> WaterIntake {
        WaterIntake(date: date.startOfDay, totalML: 0, entries: [])
    }
}

// MARK: - Individual Water Entry
struct WaterEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let timestamp: Date
    let amountML: Double
    
    init(amountML: Double, timestamp: Date = Date()) {
        self.id = UUID()
        self.timestamp = timestamp
        self.amountML = amountML
    }
}
