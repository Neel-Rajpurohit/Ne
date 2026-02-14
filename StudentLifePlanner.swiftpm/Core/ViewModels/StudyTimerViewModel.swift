import Foundation
import Combine

@MainActor
class StudyTimerViewModel: ObservableObject {
    @Published var timeRemaining: Int = Constants.focusDuration
    @Published var currentState: TimerState = .idle
    @Published var sessionsCompleted: Int = 0
    @Published var totalFocusTime: Int = 0 // in seconds
    
    private var timer: Timer?
    private let storage: DataStorageService
    
    var isRunning: Bool {
        return currentState == TimerState.focus || currentState == TimerState.break_time
    }
    
    var isFocusMode: Bool {
        return currentState == TimerState.focus
    }
    
    var isBreakMode: Bool {
        return currentState == TimerState.break_time
    }
    
    var progress: Double {
        let total = isFocusMode ? Constants.focusDuration : Constants.breakDuration
        return Double(timeRemaining) / Double(total)
    }
    
    var formattedTime: String {
        return TimeFormatter.formatTimer(timeRemaining)
    }
    
    var sessionInfo: String {
        if sessionsCompleted == 0 {
            return "Ready to start"
        }
        return "Session \(sessionsCompleted + 1)"
    }
    
    
    nonisolated init() {
        self.storage = DataStorageService.shared
    }
    
    // MARK: - Timer Controls
    
    func startTimer() {
        if currentState == .idle {
            currentState = .focus
            timeRemaining = Constants.focusDuration
        } else if currentState == .paused {
            // Resume
            currentState = isFocusMode ? .focus : .break_time
        }
        
        startCountdown()
    }
    
    func pauseTimer() {
        currentState = .paused
        stopCountdown()
    }
    
    func resetTimer() {
        currentState = .idle
        timeRemaining = Constants.focusDuration
        stopCountdown()
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            handleTimerComplete()
            return
        }
        
        timeRemaining -= 1
        
        // Track focus time
        if currentState == .focus {
            totalFocusTime += 1
        }
    }
    
    private func handleTimerComplete() {
        stopCountdown()
        
        if currentState == .focus {
            // Focus session complete - start break
            sessionsCompleted += 1
            saveSession()
            currentState = .break_time
            timeRemaining = Constants.breakDuration
            startCountdown()
        } else if currentState == .break_time {
            // Break complete - ready for next session
            currentState = .idle
            timeRemaining = Constants.focusDuration
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveSession() {
        let session = StudySession(
            date: Date(),
            focusDuration: Constants.focusDuration,
            breakDuration: Constants.breakDuration,
            sessionsCompleted: 1,
            totalFocusTime: Constants.focusDuration
        )
        storage.addStudySession(session)
    }
    
    func loadTodayStats() {
        let sessions = storage.loadStudySessions()
        let todaySessions = sessions.filter { DateHelper.isToday($0.date) }
        
        sessionsCompleted = todaySessions.reduce(0) { $0 + $1.sessionsCompleted }
        totalFocusTime = todaySessions.reduce(0) { $0 + $1.totalFocusTime }
    }
    
    func getTodayFocusTime() -> String {
        return TimeFormatter.formatDuration(totalFocusTime)
    }
    
    func getAllTimeFocusTime() -> String {
        let sessions = storage.loadStudySessions()
        let total = sessions.reduce(0) { $0 + $1.totalFocusTime }
        return TimeFormatter.formatDuration(total)
    }
    
    func getRecentSessions(limit: Int = 10) -> [StudySession] {
        let sessions = storage.loadStudySessions()
        return Array(sessions.sorted { $0.date > $1.date }.prefix(limit))
    }
}
