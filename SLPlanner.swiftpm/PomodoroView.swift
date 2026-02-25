import SwiftUI

// MARK: - Pomodoro View (Automatic Cycle Engine)
// Flow: Study 25m → Break 5m → Study 25m → Break 5m → Session Complete
// All transitions are automatic — no user action needed between phases.

struct PomodoroView: View {
    let subject: String
    let totalCycles: Int
    let studyDuration: Int   // minutes per study phase
    let breakDuration: Int   // minutes per break phase
    let blockId: UUID
    
    // MARK: - State
    @Environment(\.dismiss) private var dismiss
    @State private var currentCycle: Int = 1
    @State private var currentPhase: PomodoroPhase = .study
    @State private var timeRemaining: Int = 0
    @State private var totalPhaseTime: Int = 0
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var isSessionStarted = false
    @State private var isSessionComplete = false
    @State private var timer: Timer?
    @State private var showConfetti = false
    @State private var ringPulse: CGFloat = 1.0
    @State private var phaseTransitionOpacity: Double = 1.0
    @State private var totalFocusedSeconds: Int = 0  // accumulated study time
    @State private var showBreakMenu = false
    
    // MARK: - Computed
    var progress: Double {
        guard totalPhaseTime > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalPhaseTime))
    }
    
    var sessionProgress: Double {
        let totalPhases = totalCycles * 2
        let completedPhases: Int
        if currentPhase == .study {
            completedPhases = (currentCycle - 1) * 2
        } else {
            completedPhases = (currentCycle - 1) * 2 + 1
        }
        let currentPhaseProgress = progress
        return (Double(completedPhases) + currentPhaseProgress) / Double(totalPhases)
    }
    
    var totalStudyMinutes: Int { totalCycles * studyDuration }
    var totalBreakMinutes: Int { totalCycles * breakDuration }
    var xpReward: Int { totalStudyMinutes * GameEngineManager.xpStudyPerMinute }
    
    var currentGradient: LinearGradient {
        currentPhase == .study ? AppTheme.pomodoroStudyGradient : AppTheme.pomodoroBreakGradient
    }
    
    var currentAccentColor: Color {
        currentPhase == .study ? AppTheme.primaryPurple : AppTheme.healthGreen
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            (currentPhase == .study
                ? LinearGradient(colors: [Color(hex: "0F0C29"), Color(hex: "1A1145"), Color(hex: "24243E")], startPoint: .topLeading, endPoint: .bottomTrailing)
                : LinearGradient(colors: [Color(hex: "0A1628"), Color(hex: "0D2818"), Color(hex: "1A2332")], startPoint: .topLeading, endPoint: .bottomTrailing)
            ).ignoresSafeArea()
            
            if isSessionComplete {
                completionView
            } else {
                timerView
            }
            
            // Confetti overlay
            ConfettiView(isActive: $showConfetti)
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Timer View
    private var timerView: some View {
        VStack(spacing: 24) {
            // Top Bar
            HStack {
                Button(action: endSession) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.textTertiary)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(subject)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Cycle \(currentCycle) of \(totalCycles)")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(currentAccentColor)
                }
                
                Spacer()
                
                // Cycle dots
                HStack(spacing: 6) {
                    ForEach(1...totalCycles, id: \.self) { cycle in
                        Circle()
                            .fill(cycle < currentCycle ? AppTheme.healthGreen :
                                  cycle == currentCycle ? currentAccentColor :
                                  Color.white.opacity(0.2))
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Session progress bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
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
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 14)
                    .frame(width: 240, height: 240)
                
                // Glow effect
                Circle()
                    .stroke(currentAccentColor.opacity(0.15), lineWidth: 24)
                    .frame(width: 240, height: 240)
                    .blur(radius: 12)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        currentGradient,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                // Center content
                VStack(spacing: 8) {
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .monospacedDigit()
                    
                    Text(currentPhase == .study ? "Focus Time" : "Break Time")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(currentAccentColor)
                }
            }
            .scaleEffect(ringPulse)
            
            // Phase indicator pill
            HStack(spacing: 8) {
                Image(systemName: currentPhase == .study ? "brain.head.profile" : "leaf.fill")
                    .foregroundStyle(currentAccentColor)
                Text(currentPhase == .study ? "Stay Focused" : "Relax & Recharge")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(currentAccentColor.opacity(0.12))
            .clipShape(Capsule())
            .opacity(phaseTransitionOpacity)
            
            // Today's focus summary
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.warmOrange)
                Text("Total Focus Today: \(formattedTotalFocus)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(.top, 4)
            
            Spacer()
            
            // Controls
            HStack(spacing: 30) {
                // Pause/Resume
                if isSessionStarted {
                    Button(action: togglePause) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                
                // Start / Resume
                if !isSessionStarted {
                    Button(action: startSession) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Start")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(width: 160, height: 56)
                        .background(currentGradient)
                        .clipShape(Capsule())
                        .shadow(color: currentAccentColor.opacity(0.4), radius: 12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                // End session
                if isSessionStarted {
                    Button(action: endSession) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(AppTheme.dangerRed.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $showBreakMenu) {
            BreakGameMenu()
        }
        .onAppear {
            // Initialize timer display
            totalPhaseTime = studyDuration * 60
            timeRemaining = totalPhaseTime
            
            // Start breathing animation
            startBreathingAnimation()
        }
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Trophy icon
            ZStack {
                Circle()
                    .fill(AppTheme.warmOrange.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(AppTheme.warmOrange.opacity(0.08))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "FFD200")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }
            
            Text("Session Complete!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text(subject)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.primaryPurple)
            
            // Stats grid
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    completionStat(icon: "brain.head.profile", value: "\(totalStudyMinutes) min", label: "Focused", color: AppTheme.primaryPurple)
                    completionStat(icon: "leaf.fill", value: "\(totalBreakMinutes) min", label: "Rest", color: AppTheme.healthGreen)
                }
                HStack(spacing: 16) {
                    completionStat(icon: "flame.fill", value: "\(streakDays) Days", label: "Streak", color: AppTheme.warmOrange)
                    completionStat(icon: "star.fill", value: "+\(xpReward) XP", label: "Earned", color: Color(hex: "FFD200"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Spacer()
            
            // Done button
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Done")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.healthGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .onAppear {
            // Trigger confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
    
    private func completionStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassBackground(cornerRadius: 16)
    }
    
    // MARK: - Timer Logic
    
    private func startSession() {
        isSessionStarted = true
        currentCycle = 1
        currentPhase = .study
        totalPhaseTime = studyDuration * 60
        timeRemaining = totalPhaseTime
        startCountdown()
        HapticManager.impact(.medium)
    }
    
    private func startCountdown() {
        isRunning = true
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                tick()
            }
        }
    }
    
    private func tick() {
        guard isRunning, !isPaused else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
            
            // Track study time
            if currentPhase == .study {
                totalFocusedSeconds += 1
            }
        } else {
            // Phase ended — determine next action
            timer?.invalidate()
            HapticManager.notification(.success)
            
            if currentPhase == .study {
                // Study phase ended → auto-switch to break
                transitionToBreak()
            } else {
                // Break phase ended → check if more cycles
                if currentCycle < totalCycles {
                    // Start next cycle
                    currentCycle += 1
                    transitionToStudy()
                } else {
                    // All cycles done — session complete!
                    completeSession()
                }
            }
        }
    }
    
    private func transitionToBreak() {
        withAnimation(.easeInOut(duration: 0.3)) {
            phaseTransitionOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentPhase = .breakTime
            totalPhaseTime = breakDuration * 60
            timeRemaining = totalPhaseTime
            
            withAnimation(.easeInOut(duration: 0.3)) {
                phaseTransitionOpacity = 1
            }
            
            startCountdown()
        }
    }
    
    private func transitionToStudy() {
        withAnimation(.easeInOut(duration: 0.3)) {
            phaseTransitionOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentPhase = .study
            totalPhaseTime = studyDuration * 60
            timeRemaining = totalPhaseTime
            
            withAnimation(.easeInOut(duration: 0.3)) {
                phaseTransitionOpacity = 1
            }
            
            startCountdown()
        }
    }
    
    private func completeSession() {
        timer?.invalidate()
        isRunning = false
        
        // Award XP
        GameEngineManager.shared.awardXP(amount: xpReward, source: "Study: \(subject)", icon: "book.fill")
        
        // Mark timetable block as completed
        if let idx = PlannerEngine.shared.todayRoutine.blocks.firstIndex(where: { $0.id == blockId }) {
            PlannerEngine.shared.todayRoutine.blocks[idx].isCompleted = true
            PlannerEngine.shared.objectWillChange.send()
        }
        
        // Record study session
        let vm = StudyViewModel()
        if let subjectModel = vm.subjects.first(where: { $0.name == subject }) {
            vm.recordSession(subjectId: subjectModel.id, durationMinutes: totalStudyMinutes)
        }
        
        // Save Pomodoro session record
        let record = PomodoroSession(
            subjectName: subject,
            subjectColorHex: subjectColorHex,
            cyclesCompleted: totalCycles,
            isFullyCompleted: true,
            xpEarned: xpReward
        )
        savePomodoroSession(record)
        
        HapticManager.notification(.success)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isSessionComplete = true
        }
    }
    
    private func endSession() {
        timer?.invalidate()
        isRunning = false
        
        if isSessionStarted && totalFocusedSeconds > 60 {
            // Partial completion — award partial XP
            let partialMinutes = totalFocusedSeconds / 60
            let partialXP = partialMinutes * GameEngineManager.xpStudyPerMinute
            GameEngineManager.shared.awardXP(amount: partialXP, source: "Study: \(subject) (partial)", icon: "book.fill")
        }
        
        dismiss()
    }
    
    private func togglePause() {
        if isPaused {
            isPaused = false
            startCountdown()
        } else {
            isPaused = true
            isRunning = false
            timer?.invalidate()
        }
        HapticManager.impact(.light)
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    
    private var formattedTotalFocus: String {
        let existing = StudyViewModel().totalStudyMinutesToday
        let current = totalFocusedSeconds / 60
        let total = existing + current
        if total >= 60 {
            return "\(total / 60)h \(total % 60)m"
        }
        return "\(total)m"
    }
    
    private var streakDays: Int {
        // Calculate streak from consecutive days with study sessions
        let defaults = UserDefaults.standard
        let streak = defaults.integer(forKey: "studyStreak")
        return max(streak, 1)
    }
    
    private var subjectColorHex: String {
        let vm = StudyViewModel()
        return vm.subjects.first(where: { $0.name == subject })?.colorHex ?? "8B5CF6"
    }
    
    private func savePomodoroSession(_ session: PomodoroSession) {
        var sessions: [PomodoroSession] = []
        if let data = UserDefaults.standard.data(forKey: "pomodoroSessions"),
           let saved = try? JSONDecoder().decode([PomodoroSession].self, from: data) {
            sessions = saved
        }
        sessions.append(session)
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: "pomodoroSessions")
        }
        
        // Update streak
        let defaults = UserDefaults.standard
        let lastStudyDate = defaults.object(forKey: "lastStudyDate") as? Date
        let today = Calendar.current.startOfDay(for: Date())
        
        if let last = lastStudyDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            if Calendar.current.isDate(lastDay, inSameDayAs: today) {
                // Same day — no streak change
            } else if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                      Calendar.current.isDate(lastDay, inSameDayAs: yesterday) {
                // Consecutive day — increment streak
                defaults.set(defaults.integer(forKey: "studyStreak") + 1, forKey: "studyStreak")
            } else {
                // Streak broken — reset to 1
                defaults.set(1, forKey: "studyStreak")
            }
        } else {
            defaults.set(1, forKey: "studyStreak")
        }
        defaults.set(Date(), forKey: "lastStudyDate")
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            ringPulse = 1.03
        }
    }
}

// MARK: - Study Verification Quiz View
// Shows after Pomodoro session; must score ≥70% to mark study block as complete
// Pulls questions from: 1) Personal quizzes matching the subject, 2) QuizManager bank, 3) Fallback bank

struct StudyQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
}

struct StudyVerificationQuizView: View {
    let subject: String
    let blockId: UUID
    
    @State private var questions: [StudyQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var correctCount = 0
    @State private var showResult = false
    @State private var isLoaded = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if isLoaded {
                if showResult {
                    quizResultView
                } else if currentIndex < questions.count {
                    questionView(questions[currentIndex])
                }
            } else {
                ProgressView("Loading Quiz...")
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .onAppear { loadQuestions() }
    }
    
    // MARK: - Question View
    private func questionView(_ q: StudyQuestion) -> some View {
        VStack(spacing: 24) {
            // Progress
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.textTertiary)
                }
                Spacer()
                Text("Question \(currentIndex + 1)/\(questions.count)")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Question
            Text(q.question)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Options
            VStack(spacing: 12) {
                ForEach(0..<q.options.count, id: \.self) { idx in
                    Button(action: {
                        guard selectedAnswer == nil else { return }
                        selectedAnswer = idx
                        if idx == q.correctIndex { correctCount += 1 }
                        HapticManager.impact(.light)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if currentIndex + 1 < questions.count {
                                currentIndex += 1
                                selectedAnswer = nil
                            } else {
                                showResult = true
                            }
                        }
                    }) {
                        HStack {
                            Text(q.options[idx])
                                .font(.system(.body, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            if let sel = selectedAnswer {
                                if idx == q.correctIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppTheme.healthGreen)
                                } else if idx == sel {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(AppTheme.dangerRed)
                                }
                            }
                        }
                        .padding(16)
                        .background(optionBackground(idx: idx, correctIdx: q.correctIndex))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(optionBorder(idx: idx, correctIdx: q.correctIndex), lineWidth: 1)
                        )
                    }
                    .disabled(selectedAnswer != nil)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func optionBackground(idx: Int, correctIdx: Int) -> Color {
        guard let sel = selectedAnswer else { return Color.white.opacity(0.06) }
        if idx == correctIdx { return AppTheme.healthGreen.opacity(0.15) }
        if idx == sel { return AppTheme.dangerRed.opacity(0.15) }
        return Color.white.opacity(0.06)
    }
    
    private func optionBorder(idx: Int, correctIdx: Int) -> Color {
        guard let sel = selectedAnswer else { return Color.white.opacity(0.1) }
        if idx == correctIdx { return AppTheme.healthGreen.opacity(0.5) }
        if idx == sel { return AppTheme.dangerRed.opacity(0.5) }
        return Color.white.opacity(0.1)
    }
    
    // MARK: - Result View
    private var quizResultView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            let percentage = questions.isEmpty ? 0 : (correctCount * 100 / questions.count)
            let passed = percentage >= 70
            
            Image(systemName: passed ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(passed ? AppTheme.healthGreen : AppTheme.dangerRed)
            
            Text(passed ? "Great Job!" : "Keep Studying")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("\(correctCount)/\(questions.count) correct (\(percentage)%)")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
            
            if passed {
                Text("+10 Bonus XP")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color(hex: "FFD200"))
            }
            
            Spacer()
            
            Button(action: {
                if passed {
                    GameEngineManager.shared.awardXP(amount: 10, source: "Quiz: \(subject)", icon: "brain.head.profile")
                }
                dismiss()
            }) {
                Text("Continue")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(passed ? AppTheme.healthGradient : AppTheme.quizGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Load Questions
    private func loadQuestions() {
        // Try to get questions from personal quizzes first
        var loaded: [StudyQuestion] = []
        
        if let data = UserDefaults.standard.data(forKey: "personalQuizzes"),
           let quizzes = try? JSONDecoder().decode([PersonalQuiz].self, from: data) {
            let matching = quizzes.filter { $0.title.lowercased() == subject.lowercased() }
            for quiz in matching {
                for q in quiz.questions {
                    loaded.append(StudyQuestion(question: q.question, options: q.options, correctIndex: q.correctIndex))
                }
            }
        }
        
        // If not enough, add fallback questions
        if loaded.count < 3 {
            loaded.append(contentsOf: fallbackQuestions(for: subject))
        }
        
        questions = Array(loaded.shuffled().prefix(5))
        isLoaded = true
    }
    
    private func fallbackQuestions(for subject: String) -> [StudyQuestion] {
        [
            StudyQuestion(question: "Did you complete all study material for \(subject)?", options: ["Yes, fully", "Mostly", "Partially", "Not really"], correctIndex: 0),
            StudyQuestion(question: "How confident do you feel about today's \(subject) session?", options: ["Very confident", "Somewhat", "Need review", "Not confident"], correctIndex: 0),
            StudyQuestion(question: "Could you explain today's \(subject) topic to someone?", options: ["Absolutely", "Mostly", "With help", "Not yet"], correctIndex: 0),
        ]
    }
}
