import SwiftUI

// MARK: - Personal Quiz Play View
struct PersonalQuizPlayView: View {
    let quiz: PersonalQuiz
    
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int?
    @State private var correctCount = 0
    @State private var showResult = false
    @State private var answered = false
    @Environment(\.dismiss) private var dismiss
    
    var currentQuestion: PersonalQuestion? { currentIndex < quiz.questions.count ? quiz.questions[currentIndex] : nil }
    var progress: Double { quiz.questions.isEmpty ? 0 : Double(currentIndex) / Double(quiz.questions.count) }
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if showResult {
                resultView
            } else if let question = currentQuestion {
                questionView(question)
            }
        }
    }
    
    // MARK: - Question View
    private func questionView(_ question: PersonalQuestion) -> some View {
        VStack(spacing: 20) {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(AppTheme.textTertiary)
                }
                Spacer()
                Text("\(currentIndex + 1)/\(quiz.questions.count)").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
            }
            .padding(.horizontal, 20).padding(.top, 20)
            
            // Progress
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(AppTheme.quizGradient).frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 6).padding(.horizontal, 20)
            
            Spacer()
            
            // Question
            Text(question.question)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // Quiz Title badge
            Text(quiz.title).font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.quizPink).padding(.horizontal, 12).padding(.vertical, 6)
                .background(AppTheme.quizPink.opacity(0.15)).clipShape(Capsule())
            
            Spacer()
            
            // Options
            VStack(spacing: 12) {
                ForEach(question.options.indices, id: \.self) { idx in
                    Button(action: { selectAnswer(idx, correct: question.correctIndex) }) {
                        HStack(spacing: 14) {
                            Text(["A", "B", "C", "D"][idx])
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .frame(width: 34, height: 34)
                                .background(optionColor(idx, correct: question.correctIndex))
                                .foregroundStyle(.white).clipShape(Circle())
                            
                            Text(question.options[idx])
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            if answered && idx == question.correctIndex {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.healthGreen)
                            } else if answered && idx == selectedAnswer && idx != question.correctIndex {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(AppTheme.dangerRed)
                            }
                        }
                        .padding(14)
                        .background(optionBG(idx, correct: question.correctIndex))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(optionBorder(idx, correct: question.correctIndex), lineWidth: 1.5))
                    }
                    .disabled(answered)
                }
            }
            .padding(.horizontal, 20)
            
            if answered {
                Button(action: nextQuestion) {
                    Text(currentIndex + 1 < quiz.questions.count ? "Next →" : "See Results")
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
            let accuracy = quiz.questions.isEmpty ? 0 : Double(correctCount) / Double(quiz.questions.count)
            let xp = correctCount * GameEngineManager.xpQuizCorrect
            
            Image(systemName: accuracy >= 0.7 ? "trophy.fill" : "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(accuracy >= 0.7 ? AppTheme.warmOrange : AppTheme.quizPink)
            
            Text(accuracy >= 0.8 ? "Excellent!" : accuracy >= 0.5 ? "Good Try!" : "Keep Studying!")
                .font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            
            VStack(spacing: 16) {
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("\(correctCount)/\(quiz.questions.count)").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        Text("Score").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                    }
                    VStack(spacing: 4) {
                        Text("\(Int(accuracy * 100))%").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(accuracy >= 0.7 ? AppTheme.healthGreen : AppTheme.warmOrange)
                        Text("Accuracy").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                    }
                }
                Divider().overlay(AppTheme.cardBorder)
                HStack(spacing: 8) {
                    Image(systemName: "star.fill").foregroundStyle(AppTheme.warmOrange)
                    Text("+\(xp) XP").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.warmOrange)
                }
            }
            .padding(24).glassBackground().padding(.horizontal, 20)
            
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
        selectedAnswer = idx; answered = true
        if idx == correct { correctCount += 1; HapticManager.notification(.success) } else { HapticManager.notification(.error) }
    }
    
    private func nextQuestion() {
        if currentIndex + 1 < quiz.questions.count {
            currentIndex += 1; selectedAnswer = nil; answered = false; HapticManager.selection()
        } else {
            let xp = correctCount * GameEngineManager.xpQuizCorrect
            GameEngineManager.shared.awardXP(amount: xp, source: "Custom: \(quiz.title)", icon: "doc.text.fill")
            showResult = true
        }
    }
    
    // MARK: - Colors
    private func optionColor(_ idx: Int, correct: Int) -> Color {
        guard answered else { return Color.white.opacity(0.2) }
        if idx == correct { return AppTheme.healthGreen }
        if idx == selectedAnswer { return AppTheme.dangerRed }
        return Color.white.opacity(0.2)
    }
    private func optionBG(_ idx: Int, correct: Int) -> Color {
        guard answered else { return Color.white.opacity(0.05) }
        if idx == correct { return AppTheme.healthGreen.opacity(0.1) }
        if idx == selectedAnswer { return AppTheme.dangerRed.opacity(0.1) }
        return Color.white.opacity(0.05)
    }
    private func optionBorder(_ idx: Int, correct: Int) -> Color {
        guard answered else { return AppTheme.cardBorder }
        if idx == correct { return AppTheme.healthGreen.opacity(0.5) }
        if idx == selectedAnswer { return AppTheme.dangerRed.opacity(0.5) }
        return AppTheme.cardBorder
    }
}
