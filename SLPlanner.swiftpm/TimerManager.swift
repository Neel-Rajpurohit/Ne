import SwiftUI
import Combine

// MARK: - Timer Manager (Study + Breathing)
@MainActor
class TimerManager: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var totalTime: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var isCompleted: Bool = false
    
    private var timer: Timer?
    var onComplete: (() -> Void)?
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalTime))
    }
    
    var formattedTime: String {
        let mins = timeRemaining / 60
        let secs = timeRemaining % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    func start(duration: Int) {
        totalTime = duration
        timeRemaining = duration
        isRunning = true
        isPaused = false
        isCompleted = false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    func pause() {
        isPaused = true
        isRunning = false
        timer?.invalidate()
    }
    
    func resume() {
        isPaused = false
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        timeRemaining = 0
    }
    
    func reset() {
        stop()
        isCompleted = false
        timeRemaining = totalTime
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            timer?.invalidate()
            isRunning = false
            isCompleted = true
            HapticManager.notification(.success)
            onComplete?()
        }
    }
}
