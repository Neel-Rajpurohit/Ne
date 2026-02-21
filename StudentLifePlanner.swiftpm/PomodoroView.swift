import SwiftUI

// MARK: - Pomodoro View (25-5 System)
struct PomodoroView: View {
    let subject: String
    let durationMinutes: Int
    let blockId: UUID
    
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
    @State private var showQuiz = false
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
            
            Text("Take a quick quiz to verify your learning!")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            Button(action: { showQuiz = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                    Text("Take Quiz")
                }
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white).frame(maxWidth: .infinity).padding(16)
                .background(AppTheme.studyGradient).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 30)
            
            Button(action: { dismiss() }) {
                Text("Skip").font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(.bottom, 40)
        }
        .fullScreenCover(isPresented: $showQuiz) {
            StudyVerificationQuizView(subject: subject, blockId: blockId)
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

// MARK: - Study Verification Quiz View
// Shows after Pomodoro session; must score ≥70% to mark study block as complete
// Pulls questions from: 1) Personal quizzes matching the subject, 2) QuizManager bank, 3) Fallback bank

struct StudyVerificationQuizView: View {
    let subject: String
    let blockId: UUID
    
    @State private var questions: [StudyQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var correctCount = 0
    @State private var answered = false
    @State private var showResult = false
    @State private var quizSource = ""
    @Environment(\.dismiss) private var dismiss
    
    var totalQuestions: Int { questions.count }
    
    var passed: Bool {
        guard totalQuestions > 0 else { return false }
        return Double(correctCount) / Double(totalQuestions) >= 0.7
    }
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if showResult {
                resultView
            } else if !questions.isEmpty {
                questionView
            } else {
                ProgressView("Loading Quiz...")
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .onAppear { loadQuestions() }
    }
    
    // MARK: - Question View
    private var questionView: some View {
        VStack(spacing: 24) {
            HStack {
                Text("📝 Study Quiz").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("\(currentIndex + 1)/\(totalQuestions)")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 20).padding(.top, 20)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(AppTheme.studyGradient)
                        .frame(width: geo.size.width * (Double(currentIndex + 1) / Double(totalQuestions)), height: 6)
                }
            }
            .frame(height: 6).padding(.horizontal, 20)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(subject).font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 6).background(AppTheme.studyBlue).clipShape(Capsule())
                if !quizSource.isEmpty {
                    Text(quizSource).font(.system(.caption2, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.quizPink)
                        .padding(.horizontal, 10).padding(.vertical, 5).background(AppTheme.quizPink.opacity(0.15)).clipShape(Capsule())
                }
            }
            
            let q = questions[currentIndex]
            Text(q.question).font(.system(.title3, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center).padding(.horizontal, 24)
            
            Spacer()
            
            VStack(spacing: 12) {
                ForEach(0..<q.options.count, id: \.self) { idx in
                    Button(action: { selectAnswer(idx) }) {
                        HStack(spacing: 12) {
                            Text(["A", "B", "C", "D"][idx]).font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(optionLetterColor(idx)).frame(width: 32, height: 32)
                                .background(optionLetterBg(idx)).clipShape(Circle())
                            Text(q.options[idx]).font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            if answered {
                                if idx == q.correctIndex {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.healthGreen)
                                } else if idx == selectedAnswer {
                                    Image(systemName: "xmark.circle.fill").foregroundStyle(AppTheme.dangerRed)
                                }
                            }
                        }
                        .padding(14).background(optionBackground(idx)).clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(optionBorder(idx), lineWidth: 2))
                    }
                    .disabled(answered)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            if answered {
                Button(action: nextQuestion) {
                    Text(currentIndex + 1 < totalQuestions ? "Next Question →" : "See Results")
                        .font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(16).background(AppTheme.studyGradient).clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20).padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: passed ? "checkmark.seal.fill" : "arrow.counterclockwise.circle.fill")
                .font(.system(size: 70)).foregroundStyle(passed ? AppTheme.healthGreen : AppTheme.warmOrange)
            Text(passed ? "Quiz Passed! 🎉" : "Keep Studying! 📚")
                .font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text("\(correctCount)/\(totalQuestions) correct (\(Int(Double(correctCount) / Double(totalQuestions) * 100))%)")
                .font(.system(.headline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
            if passed {
                Text("Study task marked complete! ✅").font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.healthGreen).padding(12).background(AppTheme.healthGreen.opacity(0.15)).clipShape(Capsule())
            } else {
                Text("You need 70% to complete this task.\nReview and try again!")
                    .font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary).multilineTextAlignment(.center)
            }
            Spacer()
            Button(action: { dismiss() }) {
                Text("Done").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(16).background(passed ? AppTheme.healthGradient : AppTheme.studyGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(ScaleButtonStyle()).padding(.horizontal, 30).padding(.bottom, 40)
        }
    }
    
    // MARK: - Logic
    private func selectAnswer(_ idx: Int) {
        guard !answered else { return }
        selectedAnswer = idx; answered = true
        if idx == questions[currentIndex].correctIndex { correctCount += 1; HapticManager.notification(.success) }
        else { HapticManager.notification(.error) }
    }
    
    private func nextQuestion() {
        if currentIndex + 1 < totalQuestions {
            currentIndex += 1; selectedAnswer = nil; answered = false
        } else {
            withAnimation { showResult = true }
            if passed {
                TaskCompletionManager.shared.completeStudy(blockId: blockId)
                GameEngineManager.shared.awardXP(amount: 30, source: "\(subject) Quiz", icon: "checkmark.seal.fill")
            }
        }
    }
    
    // MARK: - Load Questions (Personal Quiz → QuizManager → Fallback)
    private func loadQuestions() {
        let key = subject.lowercased().trimmingCharacters(in: .whitespaces)
        
        // 1. Try personal quizzes first
        let personalQuizzes = PersonalQuizManager.shared.quizzes
        if let match = personalQuizzes.first(where: { $0.title.lowercased().contains(key) && !$0.questions.isEmpty }) {
            quizSource = "Your Quiz"
            questions = match.questions.shuffled().prefix(5).map { StudyQuestion(question: $0.question, options: $0.options, correctIndex: $0.correctIndex) }
            if !questions.isEmpty { return }
        }
        
        // 2. Try QuizManager's built-in bank
        if let category = matchCategory(for: key) {
            let gkQ = QuizManager.shared.getQuestions(category: category, count: 5)
            if !gkQ.isEmpty {
                quizSource = "\(category.rawValue) Bank"
                questions = gkQ.map { StudyQuestion(question: $0.question, options: $0.options, correctIndex: $0.correctAnswerIndex) }
                return
            }
        }
        
        // 3. Fallback
        quizSource = "Study Bank"
        questions = StudyQuestionBank.questions(for: subject)
    }
    
    private func matchCategory(for key: String) -> QuizCategory? {
        switch key {
        case "science", "physics", "chemistry", "biology": return .science
        case "history", "social studies", "sst": return .history
        case "geography", "geo": return .geography
        case "computer", "computers", "it", "technology": return .technology
        default: return .general
        }
    }
    
    // MARK: - Styling
    private func optionLetterColor(_ idx: Int) -> Color {
        if !answered { return selectedAnswer == idx ? .white : AppTheme.studyBlue }
        if idx == questions[currentIndex].correctIndex { return .white }
        if idx == selectedAnswer { return .white }
        return AppTheme.textTertiary
    }
    private func optionLetterBg(_ idx: Int) -> Color {
        if !answered { return selectedAnswer == idx ? AppTheme.studyBlue : AppTheme.studyBlue.opacity(0.15) }
        if idx == questions[currentIndex].correctIndex { return AppTheme.healthGreen }
        if idx == selectedAnswer { return AppTheme.dangerRed }
        return Color.white.opacity(0.08)
    }
    private func optionBackground(_ idx: Int) -> Color {
        if !answered { return Color.white.opacity(0.06) }
        if idx == questions[currentIndex].correctIndex { return AppTheme.healthGreen.opacity(0.1) }
        if idx == selectedAnswer { return AppTheme.dangerRed.opacity(0.1) }
        return Color.white.opacity(0.04)
    }
    private func optionBorder(_ idx: Int) -> Color {
        if !answered { return selectedAnswer == idx ? AppTheme.studyBlue : .clear }
        if idx == questions[currentIndex].correctIndex { return AppTheme.healthGreen }
        if idx == selectedAnswer { return AppTheme.dangerRed }
        return .clear
    }
}

// MARK: - Study Question Model
struct StudyQuestion: Sendable {
    let question: String
    let options: [String]
    let correctIndex: Int
}

// MARK: - Fallback Question Bank
struct StudyQuestionBank: Sendable {
    static func questions(for subject: String) -> [StudyQuestion] {
        let key = subject.lowercased().trimmingCharacters(in: .whitespaces)
        let bank = questionBanks[key] ?? generalQuestions
        return Array(bank.shuffled().prefix(5))
    }
    
    private static let questionBanks: [String: [StudyQuestion]] = [
        "math": mathQuestions, "maths": mathQuestions, "mathematics": mathQuestions,
        "science": scienceQuestions, "english": englishQuestions, "hindi": hindiQuestions,
        "history": historyQuestions, "geography": geographyQuestions,
    ]
    
    private static let mathQuestions: [StudyQuestion] = [
        StudyQuestion(question: "What is 15 x 12?", options: ["160", "180", "170", "190"], correctIndex: 1),
        StudyQuestion(question: "Solve: 2x + 6 = 14. What is x?", options: ["3", "4", "5", "6"], correctIndex: 1),
        StudyQuestion(question: "What is the square root of 144?", options: ["11", "12", "13", "14"], correctIndex: 1),
        StudyQuestion(question: "What is 25% of 200?", options: ["40", "50", "60", "45"], correctIndex: 1),
        StudyQuestion(question: "How many degrees in a triangle?", options: ["90", "180", "360", "270"], correctIndex: 1),
        StudyQuestion(question: "What is the LCM of 4 and 6?", options: ["12", "24", "6", "8"], correctIndex: 0),
    ]
    
    private static let scienceQuestions: [StudyQuestion] = [
        StudyQuestion(question: "What is the chemical symbol for water?", options: ["H2O", "CO2", "NaCl", "O2"], correctIndex: 0),
        StudyQuestion(question: "What planet is the Red Planet?", options: ["Venus", "Mars", "Jupiter", "Saturn"], correctIndex: 1),
        StudyQuestion(question: "What is the powerhouse of the cell?", options: ["Nucleus", "Ribosome", "Mitochondria", "Golgi body"], correctIndex: 2),
        StudyQuestion(question: "What gas do plants absorb?", options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"], correctIndex: 2),
        StudyQuestion(question: "What is the boiling point of water?", options: ["90C", "100C", "110C", "80C"], correctIndex: 1),
        StudyQuestion(question: "How many bones in an adult body?", options: ["196", "206", "216", "186"], correctIndex: 1),
    ]
    
    private static let englishQuestions: [StudyQuestion] = [
        StudyQuestion(question: "What is a synonym of 'happy'?", options: ["Sad", "Joyful", "Angry", "Tired"], correctIndex: 1),
        StudyQuestion(question: "Past tense of 'run'?", options: ["Runned", "Running", "Ran", "Runs"], correctIndex: 2),
        StudyQuestion(question: "Which is a noun?", options: ["Quickly", "Beautiful", "Happiness", "Run"], correctIndex: 2),
        StudyQuestion(question: "What is an antonym of 'brave'?", options: ["Bold", "Cowardly", "Strong", "Fierce"], correctIndex: 1),
        StudyQuestion(question: "What is a verb?", options: ["A naming word", "An action word", "A describing word", "A joining word"], correctIndex: 1),
    ]
    
    private static let hindiQuestions: [StudyQuestion] = [
        StudyQuestion(question: "Hindi has how many vowels (swar)?", options: ["10", "11", "13", "14"], correctIndex: 2),
        StudyQuestion(question: "How many consonants (vyanjan)?", options: ["33", "36", "39", "41"], correctIndex: 0),
        StudyQuestion(question: "Opposite of 'bada' (big)?", options: ["Lamba", "Chhota", "Uncha", "Mota"], correctIndex: 1),
        StudyQuestion(question: "How many types of Sangya (noun)?", options: ["3", "4", "5", "6"], correctIndex: 2),
    ]
    
    private static let historyQuestions: [StudyQuestion] = [
        StudyQuestion(question: "First President of India?", options: ["Nehru", "Rajendra Prasad", "Gandhi", "Ambedkar"], correctIndex: 1),
        StudyQuestion(question: "India gained independence in?", options: ["1945", "1947", "1950", "1942"], correctIndex: 1),
        StudyQuestion(question: "Who built the Taj Mahal?", options: ["Akbar", "Shah Jahan", "Aurangzeb", "Babur"], correctIndex: 1),
        StudyQuestion(question: "Father of the Nation?", options: ["Nehru", "Patel", "Gandhi", "Bose"], correctIndex: 2),
    ]
    
    private static let geographyQuestions: [StudyQuestion] = [
        StudyQuestion(question: "Largest continent?", options: ["Africa", "Europe", "Asia", "America"], correctIndex: 2),
        StudyQuestion(question: "Longest river in the world?", options: ["Amazon", "Nile", "Ganges", "Yangtze"], correctIndex: 1),
        StudyQuestion(question: "Mount Everest is in which range?", options: ["Alps", "Andes", "Himalayas", "Rockies"], correctIndex: 2),
        StudyQuestion(question: "Capital of Australia?", options: ["Sydney", "Melbourne", "Canberra", "Perth"], correctIndex: 2),
    ]
    
    private static let generalQuestions: [StudyQuestion] = [
        StudyQuestion(question: "Days in a leap year?", options: ["365", "366", "364", "367"], correctIndex: 1),
        StudyQuestion(question: "Largest organ in the human body?", options: ["Heart", "Brain", "Skin", "Liver"], correctIndex: 2),
        StudyQuestion(question: "What does CPU stand for?", options: ["Central Process Unit", "Central Processing Unit", "Computer Process Unit", "Central Power Unit"], correctIndex: 1),
        StudyQuestion(question: "Seconds in one hour?", options: ["3600", "3000", "6000", "1800"], correctIndex: 0),
    ]
}
