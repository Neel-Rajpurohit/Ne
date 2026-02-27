import SwiftUI

// MARK: - Quiz Play View
struct QuizPlayView: View {
    let category: QuizCategory?
    
    @State private var questions: [GKQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int?
    @State private var correctCount = 0
    @State private var showResult = false
    @State private var timeElapsed = 0
    @State private var timer: Timer?
    @State private var answered = false
    @State private var appeared = false
    @Environment(\.dismiss) private var dismiss
    
    var currentQuestion: GKQuestion? { currentIndex < questions.count ? questions[currentIndex] : nil }
    var progress: Double { questions.isEmpty ? 0 : Double(currentIndex) / Double(questions.count) }
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if showResult {
                resultView
            } else if let question = currentQuestion {
                questionView(question)
            } else {
                ProgressView().tint(AppTheme.quizPink)
            }
        }
        .onAppear {
            questions = QuizManager.shared.getQuestions(category: category, count: 10)
            startTimer()
            withAnimation(.spring(response: 0.5)) { appeared = true }
        }
        .onDisappear { timer?.invalidate() }
    }
    
    // MARK: - Question View
    private func questionView(_ question: GKQuestion) -> some View {
        VStack(spacing: 20) {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(AppTheme.textTertiary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock").font(.caption).foregroundStyle(AppTheme.textTertiary)
                    Text("\(timeElapsed)s").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                }
            }
            .padding(.horizontal, 20).padding(.top, 20)
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(AppTheme.quizGradient).frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 6).padding(.horizontal, 20)
            
            Text("Question \(currentIndex + 1)/\(questions.count)")
                .font(.system(.caption, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
            
            Spacer()
            
            // Question
            Text(question.question)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // Category badge
            HStack(spacing: 6) {
                Image(systemName: question.category.icon).font(.caption2)
                Text(question.category.rawValue).font(.system(.caption2, design: .rounded))
            }
            .foregroundStyle(AppTheme.quizPink).padding(.horizontal, 12).padding(.vertical, 6)
            .background(AppTheme.quizPink.opacity(0.15)).clipShape(Capsule())
            
            Spacer()
            
            // Options
            VStack(spacing: 12) {
                ForEach(question.options.indices, id: \.self) { idx in
                    Button(action: { selectAnswer(idx, correct: question.correctAnswerIndex) }) {
                        HStack(spacing: 14) {
                            Text(["A", "B", "C", "D"][idx])
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .frame(width: 34, height: 34)
                                .background(optionLabelColor(idx, correct: question.correctAnswerIndex))
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                            
                            Text(question.options[idx])
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            if answered && idx == question.correctAnswerIndex {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.healthGreen)
                            } else if answered && idx == selectedAnswer && idx != question.correctAnswerIndex {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(AppTheme.dangerRed)
                            }
                        }
                        .padding(14)
                        .background(optionBGColor(idx, correct: question.correctAnswerIndex))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(optionBorderColor(idx, correct: question.correctAnswerIndex), lineWidth: 1.5)
                        )
                    }
                    .disabled(answered)
                }
            }
            .padding(.horizontal, 20)
            
            // Next Button
            if answered {
                Button(action: nextQuestion) {
                    Text(currentIndex + 1 < questions.count ? "Next Question →" : "See Results")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white).frame(maxWidth: .infinity).padding(16)
                        .background(AppTheme.quizGradient).clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)
            }
            
            Spacer(minLength: 20)
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            let accuracy = questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count)
            let xp = correctCount * GameEngineManager.xpQuizCorrect + (accuracy >= 1.0 ? GameEngineManager.xpQuizPerfect : 0)
            
            Image(systemName: accuracy >= 0.7 ? "trophy.fill" : "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(accuracy >= 0.7 ? AppTheme.warmOrange : AppTheme.quizPink)
            
            Text(accuracy >= 0.8 ? "Excellent!" : accuracy >= 0.5 ? "Good Try!" : "Keep Practicing!")
                .font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            
            // Score Card
            VStack(spacing: 16) {
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("\(correctCount)/\(questions.count)").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        Text("Score").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                    }
                    VStack(spacing: 4) {
                        Text("\(Int(accuracy * 100))%").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(accuracy >= 0.7 ? AppTheme.healthGreen : AppTheme.warmOrange)
                        Text("Accuracy").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                    }
                    VStack(spacing: 4) {
                        Text("\(timeElapsed)s").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.neonCyan)
                        Text("Time").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                    }
                }
                
                Divider().overlay(AppTheme.cardBorder)
                
                HStack(spacing: 8) {
                    Image(systemName: "star.fill").foregroundStyle(AppTheme.warmOrange)
                    Text("+\(xp) XP Earned").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.warmOrange)
                }
            }
            .padding(24).glassBackground()
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Done").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(16).background(AppTheme.quizGradient).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20)
            
            Spacer(minLength: 30)
        }
    }
    
    // MARK: - Logic
    private func selectAnswer(_ idx: Int, correct: Int) {
        selectedAnswer = idx
        answered = true
        if idx == correct {
            correctCount += 1
            HapticManager.notification(.success)
        } else {
            HapticManager.notification(.error)
        }
    }
    
    private func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
            answered = false
            HapticManager.selection()
        } else {
            finishQuiz()
        }
    }
    
    private func finishQuiz() {
        timer?.invalidate()
        let accuracy = questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count)
        let xp = correctCount * GameEngineManager.xpQuizCorrect + (accuracy >= 1.0 ? GameEngineManager.xpQuizPerfect : 0)
        
        let result = QuizResult(category: category ?? .general, totalQuestions: questions.count, correctAnswers: correctCount, timeTaken: timeElapsed, xpEarned: xp)
        QuizManager.shared.saveResult(result)
        GameEngineManager.shared.awardXP(amount: xp, source: "Quiz \(correctCount)/\(questions.count)", icon: "brain.head.profile")
        
        showResult = true
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in timeElapsed += 1 }
        }
    }
    
    // MARK: - Option Colors
    private func optionLabelColor(_ idx: Int, correct: Int) -> Color {
        guard answered else { return selectedAnswer == idx ? AppTheme.quizPink : Color.white.opacity(0.2) }
        if idx == correct { return AppTheme.healthGreen }
        if idx == selectedAnswer { return AppTheme.dangerRed }
        return Color.white.opacity(0.2)
    }
    
    private func optionBGColor(_ idx: Int, correct: Int) -> Color {
        guard answered else { return Color.white.opacity(0.05) }
        if idx == correct { return AppTheme.healthGreen.opacity(0.1) }
        if idx == selectedAnswer { return AppTheme.dangerRed.opacity(0.1) }
        return Color.white.opacity(0.05)
    }
    
    private func optionBorderColor(_ idx: Int, correct: Int) -> Color {
        guard answered else { return AppTheme.cardBorder }
        if idx == correct { return AppTheme.healthGreen.opacity(0.5) }
        if idx == selectedAnswer { return AppTheme.dangerRed.opacity(0.5) }
        return AppTheme.cardBorder
    }
}
