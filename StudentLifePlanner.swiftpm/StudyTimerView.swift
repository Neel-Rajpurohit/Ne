import SwiftUI

// MARK: - Study Timer View (Customizable Pomodoro Engine)
// Flow: Select Subject → Pick Cycles → Study 25m → Break 5m → ... → Complete
// After 4 cycles: automatic 15-min long break
struct StudyTimerView: View {
    let subjects: [Subject]
    var onComplete: (UUID, Int) -> Void
    
    // Setup
    @State private var selectedSubjectId: UUID?
    @State private var selectedCycles: Int = 2
    
    // Timer State
    @State private var isSessionActive = false
    @State private var currentCycle = 1
    @State private var currentPhase: PomodoroPhase = .study
    @State private var timeRemaining = 0
    @State private var totalPhaseTime = 0
    @State private var isPaused = false
    @State private var isComplete = false
    @State private var completedCycles = 0
    @State private var timer: Timer?
    @State private var showBreakMenu = false
    @State private var ringPulse: CGFloat = 1.0
    @State private var showConfetti = false
    @State private var phaseTransitionOpacity: Double = 1.0
    @State private var totalFocusedSeconds: Int = 0
    @State private var isLongBreak = false
    
    @Environment(\.dismiss) private var dismiss
    
    // Constants
    private let studyMinutes = 25
    private let breakMinutes = 5
    private let longBreakMinutes = 15
    
    private let cycleOptions = [1, 2, 4]
    
    private var selectedSubject: Subject? {
        subjects.first { $0.id == selectedSubjectId }
    }
    
    var progress: Double {
        guard totalPhaseTime > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalPhaseTime))
    }
    
    var sessionProgress: Double {
        let totalPhases = selectedCycles * 2
        let completedPhases: Int
        if currentPhase == .study {
            completedPhases = (currentCycle - 1) * 2
        } else {
            completedPhases = (currentCycle - 1) * 2 + 1
        }
        let phaseProgress = progress
        return (Double(completedPhases) + phaseProgress) / Double(totalPhases)
    }
    
    var totalStudyTime: Int { selectedCycles * studyMinutes }
    var totalBreakTime: Int { selectedCycles * breakMinutes }
    var totalSessionTime: Int { totalStudyTime + totalBreakTime }
    
    var currentAccentColor: Color {
        if isLongBreak { return AppTheme.breathingCyan }
        return currentPhase == .study ? AppTheme.primaryPurple : AppTheme.healthGreen
    }
    
    var currentGradient: LinearGradient {
        if isLongBreak { return AppTheme.breathingGradient }
        return currentPhase == .study ? AppTheme.pomodoroStudyGradient : AppTheme.pomodoroBreakGradient
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic background
                (currentPhase == .study && !isLongBreak
                    ? LinearGradient(colors: [Color(hex: "0F0C29"), Color(hex: "1A1145"), Color(hex: "24243E")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color(hex: "0A1628"), Color(hex: "0D2818"), Color(hex: "1A2332")], startPoint: .topLeading, endPoint: .bottomTrailing)
                ).ignoresSafeArea()
                
                if isComplete {
                    completionView
                } else if isSessionActive {
                    timerActiveView
                } else {
                    setupView
                }
                
                ConfettiView(isActive: $showConfetti)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !isSessionActive {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .onDisappear { timer?.invalidate() }
    }
    
    // MARK: - Setup View
    private var setupView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.primaryPurple.opacity(0.15))
                    .frame(width: 100, height: 100)
                Circle()
                    .fill(AppTheme.primaryPurple.opacity(0.08))
                    .frame(width: 130, height: 130)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.pomodoroStudyGradient)
            }
            
            Text("Pomodoro Session")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            // Cycle Picker
            VStack(spacing: 10) {
                Text("Number of Cycles")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                
                HStack(spacing: 12) {
                    ForEach(cycleOptions, id: \.self) { count in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCycles = count
                            }
                            HapticManager.selection()
                        }) {
                            VStack(spacing: 4) {
                                Text("\(count)")
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                                Text(count == 1 ? "Cycle" : "Cycles")
                                    .font(.system(.caption2, design: .rounded))
                            }
                            .foregroundStyle(selectedCycles == count ? .white : AppTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedCycles == count ? AnyShapeStyle(AppTheme.pomodoroStudyGradient) : AnyShapeStyle(Color.white.opacity(0.06)))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(selectedCycles == count ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Show long break note for 4 cycles
                if selectedCycles == 4 {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.breathingCyan)
                        Text("Includes 15-min long break after completion")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(AppTheme.breathingCyan)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            
            // Session Stats
            HStack(spacing: 16) {
                sessionStatCard(icon: "clock.fill", value: "\(totalStudyTime) min", label: "Study", color: AppTheme.primaryPurple)
                sessionStatCard(icon: "leaf.fill", value: "\(totalBreakTime) min", label: "Break", color: AppTheme.healthGreen)
                sessionStatCard(icon: "hourglass", value: "\(totalSessionTime) min", label: "Total", color: AppTheme.neonCyan)
            }
            .padding(.horizontal, 20)
            
            // Subject Picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Select Subject")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(subjects) { subj in
                            Button(action: { selectedSubjectId = subj.id; HapticManager.selection() }) {
                                HStack(spacing: 8) {
                                    Circle().fill(subj.color).frame(width: 10, height: 10)
                                    Text(subj.name)
                                        .font(.system(.caption, design: .rounded, weight: .semibold))
                                }
                                .foregroundStyle(selectedSubjectId == subj.id ? .white : subj.color)
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(selectedSubjectId == subj.id ? AnyShapeStyle(subj.color) : AnyShapeStyle(subj.color.opacity(0.15)))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()

            // Start Button
            Button(action: startSession) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text("Start Session")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(18)
                .background(AppTheme.pomodoroStudyGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: AppTheme.primaryPurple.opacity(0.4), radius: 10)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20)
            .disabled(selectedSubjectId == nil)
            .opacity(selectedSubjectId == nil ? 0.5 : 1)
            
            Spacer()
        }
    }
    
    private func sessionStatCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.caption).foregroundStyle(color)
            Text(value).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .glassBackground(cornerRadius: 14)
    }
    
    // MARK: - Timer Active View
    private var timerActiveView: some View {
        VStack(spacing: 24) {
            // Top bar
            HStack {
                Button(action: endSession) {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(AppTheme.textTertiary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(isLongBreak ? "Long Break" : (selectedSubject?.name ?? "Study"))
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(isLongBreak ? "Relax & Recharge" : "Cycle \(currentCycle) of \(selectedCycles)")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(currentAccentColor)
                }
                Spacer()
                // Cycle dots
                HStack(spacing: 6) {
                    ForEach(1...selectedCycles, id: \.self) { cycle in
                        Circle()
                            .fill(cycle < currentCycle ? AppTheme.healthGreen :
                                  cycle == currentCycle ? currentAccentColor :
                                  Color.white.opacity(0.2))
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(.horizontal, 20).padding(.top, 20)
            
            // Session progress bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.1))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(currentGradient)
                            .frame(width: geo.size.width * sessionProgress)
                            .animation(.easeInOut(duration: 0.5), value: sessionProgress)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 20)
                
                Text("\(Int(sessionProgress * 100))% Complete")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            Spacer()
            
            // Timer Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 14)
                    .frame(width: 240, height: 240)
                
                // Glow
                Circle()
                    .stroke(currentAccentColor.opacity(0.15), lineWidth: 24)
                    .frame(width: 240, height: 240)
                    .blur(radius: 12)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        currentGradient,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                VStack(spacing: 8) {
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .monospacedDigit()
                    Text(isLongBreak ? "Long Break" : (currentPhase == .study ? "Focus Time" : "Break Time"))
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(currentAccentColor)
                }
            }
            .scaleEffect(ringPulse)
            
            // Phase indicator
            HStack(spacing: 8) {
                Image(systemName: isLongBreak ? "sparkles" : (currentPhase == .study ? "brain.head.profile" : "leaf.fill"))
                    .foregroundStyle(currentAccentColor)
                Text(isLongBreak ? "Deep Relaxation" : (currentPhase == .study ? "Stay Focused" : "Relax & Recharge"))
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(currentAccentColor.opacity(0.12))
            .clipShape(Capsule())
            .opacity(phaseTransitionOpacity)
            
            // Today's focus
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.warmOrange)
                Text("Total Focus Today: \(formattedTotalFocus)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 30) {
                Button(action: togglePause) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.title2).foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
                
                Button(action: endSession) {
                    Image(systemName: "stop.fill")
                        .font(.title2).foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(AppTheme.dangerRed.opacity(0.8))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $showBreakMenu) {
            BreakGameMenu()
        }
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Trophy
            ZStack {
                Circle()
                    .fill(AppTheme.warmOrange.opacity(0.15))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(AppTheme.warmOrange.opacity(0.08))
                    .frame(width: 160, height: 160)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.xpGradient)
            }
            
            Text("Session Complete!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text(selectedSubject?.name ?? "Study")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(selectedSubject?.color ?? AppTheme.primaryPurple)
            
            // Stats grid
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    completionStat(label: "Focused", value: "\(completedCycles * studyMinutes) min", icon: "brain.head.profile", color: AppTheme.primaryPurple)
                    completionStat(label: "Rest", value: "\(completedCycles * breakMinutes) min", icon: "leaf.fill", color: AppTheme.healthGreen)
                }
                HStack(spacing: 16) {
                    completionStat(label: "Streak", value: "\(streakDays) Days", icon: "flame.fill", color: AppTheme.warmOrange)
                    let xp = calculateXP()
                    completionStat(label: "Earned", value: "+\(xp) XP", icon: "star.fill", color: Color(hex: "FFD200"))
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Done")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(AppTheme.healthGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 30).padding(.bottom, 40)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
    
    private func completionStat(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .glassBackground(cornerRadius: 16)
    }
    
    // MARK: - Timer Logic
    private func startSession() {
        guard selectedSubjectId != nil else { return }
        isSessionActive = true
        currentCycle = 1
        completedCycles = 0
        totalFocusedSeconds = 0
        isLongBreak = false
        startStudyPhase()
        HapticManager.impact(.heavy)
        startBreathingAnimation()
    }
    
    private func startStudyPhase() {
        currentPhase = .study
        isLongBreak = false
        totalPhaseTime = studyMinutes * 60
        timeRemaining = totalPhaseTime
        startCountdown()
    }
    
    private func startBreakPhase() {
        currentPhase = .breakTime
        isLongBreak = false
        totalPhaseTime = breakMinutes * 60
        timeRemaining = totalPhaseTime
        completedCycles += 1
        HapticManager.notification(.success)
        startCountdown()
    }
    
    private func startLongBreak() {
        currentPhase = .breakTime
        isLongBreak = true
        totalPhaseTime = longBreakMinutes * 60
        timeRemaining = totalPhaseTime
        HapticManager.notification(.success)
        startCountdown()
    }
    
    private func startCountdown() {
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    if currentPhase == .study && !isLongBreak {
                        totalFocusedSeconds += 1
                    }
                } else {
                    timer?.invalidate()
                    handlePhaseComplete()
                }
            }
        }
    }
    
    private func handlePhaseComplete() {
        HapticManager.notification(.warning)
        
        if isLongBreak {
            // Long break done → session complete
            completeSession()
        } else if currentPhase == .study {
            // Study done → auto-switch to break
            transitionToPhase { startBreakPhase() }
        } else {
            // Break done → check if more cycles
            if currentCycle >= selectedCycles {
                // All cycles done
                if selectedCycles == 4 {
                    // 4 cycles → long break first
                    transitionToPhase { startLongBreak() }
                } else {
                    completeSession()
                }
            } else {
                currentCycle += 1
                transitionToPhase { startStudyPhase() }
            }
        }
    }
    
    private func transitionToPhase(_ action: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.3)) {
            phaseTransitionOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
            withAnimation(.easeInOut(duration: 0.3)) {
                phaseTransitionOpacity = 1
            }
        }
    }
    
    private func togglePause() {
        if isPaused {
            isPaused = false
            startCountdown()
        } else {
            isPaused = true
            timer?.invalidate()
        }
        HapticManager.impact(.medium)
    }
    
    private func endSession() {
        timer?.invalidate()
        
        if totalFocusedSeconds > 60 {
            let partialMinutes = totalFocusedSeconds / 60
            let partialXP = partialMinutes * GameEngineManager.xpStudyPerMinute
            GameEngineManager.shared.awardXP(amount: partialXP, source: "\(selectedSubject?.name ?? "Study") (partial)", icon: "book.fill")
        }
        
        dismiss()
    }
    
    private func completeSession() {
        isComplete = true
        ringPulse = 1.0
        
        let xp = calculateXP()
        
        // Award XP
        GameEngineManager.shared.awardXP(amount: xp, source: selectedSubject?.name ?? "Study", icon: "book.fill")
        
        // Record study session
        if let subId = selectedSubjectId {
            onComplete(subId, completedCycles * studyMinutes)
        }
        
        // Complete study task in TaskCompletionManager
        TaskCompletionManager.shared.completeTimerTask(
            id: TaskCompletionManager.shared.dailyTaskSet.tasks.first(where: { $0.category == .study && !$0.isCompleted })?.id ?? UUID(),
            elapsedMinutes: Double(completedCycles * studyMinutes)
        )
        
        // Save session record
        if let subj = selectedSubject {
            let session = PomodoroSession(
                subjectName: subj.name,
                subjectColorHex: subj.colorHex,
                cyclesCompleted: completedCycles,
                isFullyCompleted: true,
                xpEarned: xp
            )
            savePomodoroSession(session)
        }
        
        HapticManager.notification(.success)
    }
    
    private func calculateXP() -> Int {
        completedCycles * GameEngineManager.xpStudyPerMinute * studyMinutes
    }
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    
    private var formattedTotalFocus: String {
        let existing = StudyViewModel().totalStudyMinutesToday
        let current = totalFocusedSeconds / 60
        let total = existing + current
        if total >= 60 { return "\(total / 60)h \(total % 60)m" }
        return "\(total)m"
    }
    
    private var streakDays: Int {
        max(UserDefaults.standard.integer(forKey: "studyStreak"), 1)
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            ringPulse = 1.03
        }
    }
    
    // MARK: - Persistence
    private func savePomodoroSession(_ session: PomodoroSession) {
        let key = "pomodoroSessions"
        var sessions: [PomodoroSession] = []
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([PomodoroSession].self, from: data) {
            sessions = decoded
        }
        sessions.append(session)
        if sessions.count > 30 { sessions = Array(sessions.suffix(30)) }
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
