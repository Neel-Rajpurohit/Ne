import Foundation

struct StudySession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let focusDuration: Int // in seconds (typically 25 * 60 = 1500)
    let breakDuration: Int // in seconds (typically 5 * 60 = 300)
    let sessionsCompleted: Int
    let totalFocusTime: Int // total focus time in seconds
    
    init(date: Date = Date(), focusDuration: Int = 1500, breakDuration: Int = 300, sessionsCompleted: Int = 0, totalFocusTime: Int = 0) {
        self.id = UUID()
        self.date = date
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.sessionsCompleted = sessionsCompleted
        self.totalFocusTime = totalFocusTime
    }
}

enum TimerState: String, Codable {
    case idle
    case focus
    case break_time
    case paused
}
