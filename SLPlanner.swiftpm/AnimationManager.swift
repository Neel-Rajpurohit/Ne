import SwiftUI

// MARK: - Breathing Phase
enum BreathingPhase: String {
    case inhale = "Inhale"
    case holdIn = "Hold"
    case exhale = "Exhale"
    case holdOut = "Rest"
    case idle = "Ready"
}

// MARK: - Animation Manager (Breathing State Machine)
@MainActor
class AnimationManager: ObservableObject {
    @Published var breathingPhase: BreathingPhase = .idle
    @Published var circleScale: CGFloat = 0.4
    @Published var cyclesCompleted: Int = 0
    @Published var isActive: Bool = false
    @Published var phaseTimeRemaining: Int = 0
    
    var totalCycles: Int = 4
    var inhaleTime: Int = 4
    var holdInTime: Int = 4
    var exhaleTime: Int = 6
    var holdOutTime: Int = 2
    
    private var timer: Timer?
    var onSessionComplete: (() -> Void)?
    
    func startBreathing(cycles: Int = 4, inhale: Int = 4, holdIn: Int = 4, exhale: Int = 6, holdOut: Int = 2) {
        totalCycles = cycles
        inhaleTime = inhale
        holdInTime = holdIn
        exhaleTime = exhale
        holdOutTime = holdOut
        cyclesCompleted = 0
        isActive = true
        
        nextPhase(.inhale)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isActive = false
        breathingPhase = .idle
        circleScale = 0.4
    }
    
    private func nextPhase(_ phase: BreathingPhase) {
        guard isActive else { return }
        
        if phase == .inhale && cyclesCompleted >= totalCycles {
            // Session complete
            isActive = false
            breathingPhase = .idle
            circleScale = 0.4
            onSessionComplete?()
            return
        }
        
        breathingPhase = phase
        
        let duration: Int
        let targetScale: CGFloat
        let nextP: BreathingPhase
        
        switch phase {
        case .inhale:
            duration = inhaleTime
            targetScale = 1.0
            nextP = .holdIn
        case .holdIn:
            duration = holdInTime
            targetScale = 1.0
            nextP = .exhale
        case .exhale:
            duration = exhaleTime
            targetScale = 0.4
            nextP = .holdOut
        case .holdOut:
            duration = holdOutTime
            targetScale = 0.4
            cyclesCompleted += 1
            nextP = .inhale
        case .idle:
            return
        }
        
        phaseTimeRemaining = duration
        
        withAnimation(.easeInOut(duration: Double(duration))) {
            circleScale = targetScale
        }
        
        // Countdown
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.phaseTimeRemaining > 1 {
                    self.phaseTimeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                    self.nextPhase(nextP)
                }
            }
        }
    }
}
