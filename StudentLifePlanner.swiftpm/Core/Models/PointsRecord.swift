import Foundation

struct PointsRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let pointsEarned: Int
    let tasksCompleted: Int
    let totalTasks: Int
    let completionRate: Double
    
    init(date: Date = Date(), pointsEarned: Int, tasksCompleted: Int, totalTasks: Int) {
        self.id = UUID()
        self.date = date
        self.pointsEarned = pointsEarned
        self.tasksCompleted = tasksCompleted
        self.totalTasks = totalTasks
        self.completionRate = totalTasks > 0 ? Double(tasksCompleted) / Double(totalTasks) : 0.0
    }
}

struct PointsHistory: Codable {
    var records: [PointsRecord]
    var totalPoints: Int
    var currentStreak: Int
    var longestStreak: Int
    
    init() {
        self.records = []
        self.totalPoints = 0
        self.currentStreak = 0
        self.longestStreak = 0
    }
    
    mutating func addRecord(_ record: PointsRecord) {
        records.append(record)
        totalPoints += record.pointsEarned
        updateStreak()
    }
    
    private mutating func updateStreak() {
        // Calculate current streak based on consecutive days
        guard !records.isEmpty else {
            currentStreak = 0
            return
        }
        
        let sortedRecords = records.sorted { $0.date > $1.date }
        var streak = 0
        var lastDate: Date?
        
        for record in sortedRecords {
            if let previous = lastDate {
                let daysDiff = Calendar.current.dateComponents([.day], from: record.date, to: previous).day ?? 0
                if daysDiff == 1 {
                    streak += 1
                } else {
                    break
                }
            } else {
                streak = 1
            }
            lastDate = record.date
        }
        
        currentStreak = streak
        longestStreak = max(longestStreak, streak)
    }
}
