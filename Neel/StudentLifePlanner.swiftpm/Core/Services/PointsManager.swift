import Foundation

@MainActor
class PointsManager {
    static let shared = PointsManager()
    private let pointsKey = "user_total_points"
    private let lastSubmissionKey = "last_submission_date"
    
    func getTotalPoints() -> Int {
        return UserDefaults.standard.integer(forKey: pointsKey)
    }
    
    func canSubmitToday() -> Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: lastSubmissionKey) as? Date else {
            return true
        }
        return !Calendar.current.isDateInToday(lastDate)
    }
    
    func calculateDailyPoints(tasks: [RoutineTask]) -> Int {
        guard !tasks.isEmpty else { return 0 }
        
        let completedCount = tasks.filter { $0.isCompleted }.count
        if completedCount == tasks.count {
            return 10
        } else {
            // "If any task is missed, points are reduced to 5"
            return 5
        }
    }
    
    func addPoints(_ points: Int) {
        let currentPoints = getTotalPoints()
        UserDefaults.standard.set(currentPoints + points, forKey: pointsKey)
        UserDefaults.standard.set(Date(), forKey: lastSubmissionKey)
    }
    
    func getPerformanceLevel() -> String {
        let points = getTotalPoints()
        if points > 100 {
            return "Excellent Discipline"
        } else if points > 50 {
            return "Good Progress"
        } else if points > 0 {
            return "Keep Going!"
        } else {
            return "Start Your Journey"
        }
    }
}
