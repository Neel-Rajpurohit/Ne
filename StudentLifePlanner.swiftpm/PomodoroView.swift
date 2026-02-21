import SwiftUI

// MARK: - Pomodoro View (25-5 System)
struct PomodoroView: View {
    let subject: String
    let durationMinutes: Int
    
    @State private var timeRemaining: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var isBreak = false
    @State private var currentCycle = 1
    @State private var totalCycles = 0
    @State private var completedCycles = 0
    @State private var showBreakMenu = false
    @State private var isComplete = false
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    private var studyDuration: Int { ProfileManager.shared.profile.recommendedStudyMinutes * 60 }
    private var breakDuration: Int { ProfileManager.shared.profile.recommendedBreakMinutes * 60 }
    
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalSeconds))
    }
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if isComplete {
                completionView
            } else {
                timerView
            }
        }
        .onAppear { setupTimer() }
        .onDisappear { timer?.invalidate() }
    }
    
    // MARK: - Timer View
    private var timerView: some View {
        VStack(spacing: 30) {
            // Top Bar
            HStack {
                Button(action: { timer?.invalidate(); dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(AppTheme.textTertiary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(isBreak ? "Break Time" : subject)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Cycle \(currentCycle)/\(totalCycles)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                // Cycle indicators
                HStack(spacing: 4) {
                    ForEach(0..<totalCycles, id: \.self) { i in
                        Circle()
                            .fill(i < completedCycles ? AppTheme.healthGreen : AppTheme.textTertiary)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal, 20).padding(.top, 20)
            
            Spacer()
            
            // Timer Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 240, height: 240)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(isBreak ? AppTheme.healthGradient : AppTheme.studyGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                VStack(spacing: 8) {
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(isBreak ? "🎮 Break" : "📚 Focus")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            
            // Phase label
            HStack(spacing: 8) {
                Image(systemName: isBreak ? "gamecontroller.fill" : "book.fill")
                    .foregroundStyle(isBreak ? AppTheme.healthGreen : AppTheme.studyBlue)
                Text(isBreak ? "Relax & Recharge" : "Stay Focused")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(Color.white.opacity(0.06))
            .clipShape(Capsule())
            
            Spacer()
            
            // Controls
            HStack(spacing: 30) {
                // Pause/Resume
                Button(action: togglePause) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.title2).foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(isBreak ? AppTheme.healthGradient : AppTheme.studyGradient)
                        .clipShape(Circle())
                        .shadow(color: (isBreak ? AppTheme.healthGreen : AppTheme.studyBlue).opacity(0.4), radius: 10)
                }
                
                // Break Games (during break)
                if isBreak {
                    Button(action: { showBreakMenu = true }) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.title2).foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(AppTheme.quizGradient)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $showBreakMenu) {
            BreakGameMenu()
        }
    }
    
    // MARK: - Completion
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checkmark.circle.fill").font(.system(size: 70)).foregroundStyle(AppTheme.healthGreen)
            Text("Session Complete!").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text("\(completedCycles) cycles × \(ProfileManager.shared.profile.recommendedStudyMinutes) min")
                .font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
            
            let xp = completedCycles * GameEngineManager.xpStudyPerMinute * ProfileManager.shared.profile.recommendedStudyMinutes
            HStack(spacing: 8) {
                Image(systemName: "star.fill").foregroundStyle(AppTheme.warmOrange)
                Text("+\(xp) XP").font(.system(.title3, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.warmOrange)
            }
            .padding(16).glassBackground()
            
            Spacer()
            Button(action: { dismiss() }) {
                Text("Done").font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white).frame(maxWidth: .infinity).padding(16)
                    .background(AppTheme.studyGradient).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 30).padding(.bottom, 40)
        }
    }
    
    // MARK: - Logic
    private func setupTimer() {
        let cycleLength = ProfileManager.shared.profile.recommendedStudyMinutes + ProfileManager.shared.profile.recommendedBreakMinutes
        totalCycles = max(1, durationMinutes / cycleLength)
        currentCycle = 1
        startStudyPhase()
    }
    
    private func startStudyPhase() {
        isBreak = false
        totalSeconds = studyDuration
        timeRemaining = studyDuration
        startCountdown()
    }
    
    private func startBreakPhase() {
        isBreak = true
        totalSeconds = breakDuration
        timeRemaining = breakDuration
        completedCycles += 1
        HapticManager.notification(.success)
        startCountdown()
    }
    
    private func startCountdown() {
        isRunning = true; isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    if isBreak {
                        if currentCycle >= totalCycles {
                            completeSession()
                        } else {
                            currentCycle += 1
                            startStudyPhase()
                        }
                    } else {
                        startBreakPhase()
                    }
                }
            }
        }
    }
    
    private func togglePause() {
        if isPaused {
            isPaused = false; startCountdown()
        } else {
            isPaused = true; timer?.invalidate()
        }
        HapticManager.impact(.medium)
    }
    
    private func completeSession() {
        isComplete = true
        let xp = completedCycles * GameEngineManager.xpStudyPerMinute * ProfileManager.shared.profile.recommendedStudyMinutes
        GameEngineManager.shared.awardXP(amount: xp, source: subject, icon: "book.fill")
        HapticManager.notification(.success)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
