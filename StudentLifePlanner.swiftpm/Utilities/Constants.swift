import Foundation

struct Constants {
    // Timer Durations
    static let focusDuration: Int = 25 * 60 // 25 minutes in seconds
    static let breakDuration: Int = 5 * 60  // 5 minutes in seconds
    
    // UserDefaults Keys
    static let userProfileKey = "user_profile"
    static let timetableKey = "user_timetable"
    static let pointsHistoryKey = "points_history"
    static let routineTasksKey = "routine_tasks"
    static let studySessionsKey = "study_sessions"
    static let lastSubmissionKey = "last_submission_date"
    static let completionHistoryKey = "completion_history"
    
    // Points System
    static let fullCompletionPoints = 10
    static let partialCompletionPoints = 5
    
    // Default Values
    static let defaultAge = 18
    static let defaultEducationLevel = "University"
    
    // UI Constants
    static let cardCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let standardPadding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24
    
    // Animation
    static let standardAnimationDuration: Double = 0.3
    static let slowAnimationDuration: Double = 0.5
    
    // Routine Generation
    static let wakeUpTime = (hour: 6, minute: 0)
    static let sleepTime = (hour: 22, minute: 0)
    static let minStudySessionMinutes = 30
    static let maxStudySessionMinutes = 120
    static let breakIntervalMinutes = 90
    
    // Academic Buffers
    static let prepBufferMinutes = 60
    static let restBufferMinutes = 30
}
