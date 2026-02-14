import Foundation

@MainActor
class CalendarService {
    nonisolated static let shared = CalendarService()
    
    private var storage: DataStorageService { DataStorageService.shared }
    
    nonisolated private init() {}
    
    // Get all days in current month
    func getCurrentMonthDays() -> [Date] {
        return DateHelper.getDaysInCurrentMonth()
    }
    
    // Check if a specific day has completed routine
    func isDayCompleted(_ date: Date) -> Bool {
        return storage.isDayCompleted(date)
    }
    
    // Mark a day as completed
    func markDayCompleted(_ date: Date) {
        storage.markDayCompleted(date, completed: true)
    }
    
    // Get current streak (consecutive days)
    func getCurrentStreak() -> Int {
        let history = storage.loadPointsHistory()
        return history.currentStreak
    }
    
    // Get longest streak ever
    func getLongestStreak() -> Int {
        let history = storage.loadPointsHistory()
        return history.longestStreak
    }
    
    // Get completion rate for current month
    func getMonthlyCompletionRate() -> Double {
        let daysInMonth = getCurrentMonthDays()
        let today = Date()
        
        // Only count days up to today
        let pastDays = daysInMonth.filter { $0 <= today }
        guard !pastDays.isEmpty else { return 0.0 }
        
        let completedDays = pastDays.filter { isDayCompleted($0) }.count
        return Double(completedDays) / Double(pastDays.count)
    }
    
    // Get total completed days
    func getTotalCompletedDays() -> Int {
        let history = storage.loadPointsHistory()
        return history.records.filter { $0.completionRate >= 0.8 }.count
    }
    
    // Get stats for last 7 days
    func getWeeklyStats() -> (completedDays: Int, totalPoints: Int) {
        let history = storage.loadPointsHistory()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let recentRecords = history.records.filter { $0.date >= sevenDaysAgo }
        let completed = recentRecords.filter { $0.completionRate >= 0.8 }.count
        let points = recentRecords.reduce(0) { $0 + $1.pointsEarned }
        
        return (completed, points)
    }
}
