import SwiftUI

// MARK: - Yes/No Quiz View
struct YesNoQuizView: View {
    let questions: [PersonalQuestion]
    
    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var showResult = false
    @State private var answered = false
    @State private var isCorrect = false
    @State private var flashColor: Color = .clear
    @Environment(\.dismiss) private var dismiss
    
    // Convert MCQ to Yes/No by picking the correct answer as statement
    private var currentStatement: String {
        guard currentIndex < questions.count else { return "" }
        let q = questions[currentIndex]
        return q.question.replacingOccurrences(of: "______", with: q.options[q.correctIndex])
    }
    
    // 50% chance the statement is true
    @State private var statementIsTrue = true
    @State private var altStatement = ""
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            // Flash overlay
            flashColor.ignoresSafeArea().opacity(answered ? 0.3 : 0)
                .animation(.easeOut(duration: 0.5), value: answered)
            
            if showResult {
                resultView
            } else {
                questionView
            }
        }
        .onAppear { prepareQuestion() }
    }
    
    // MARK: - Question
    private var questionView: some View {
        VStack(spacing: 30) {
            // Top
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(AppTheme.textTertiary)
                }
                Spacer()
                Text("\(currentIndex + 1)/\(questions.count)")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(.horizontal, 20).padding(.top, 20)
            
            Spacer()
            
            // Statement
            VStack(spacing: 16) {
                Image(systemName: "quote.opening").font(.title).foregroundStyle(AppTheme.quizPink.opacity(0.5))
                Text(statementIsTrue ? currentStatement : altStatement)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Text("True or False?")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            Spacer()
            
            // YES / NO Buttons
            if !answered {
                HStack(spacing: 20) {
                    Button(action: { answer(userSaidTrue: true) }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("TRUE").font(.system(.title3, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 24)
                        .background(AppTheme.healthGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: AppTheme.healthGreen.opacity(0.4), radius: 10)
                    }
                    
                    Button(action: { answer(userSaidTrue: false) }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                            Text("FALSE").font(.system(.title3, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 24)
                        .background(AppTheme.dangerRed)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: AppTheme.dangerRed.opacity(0.4), radius: 10)
                    }
                }
                .padding(.horizontal, 20)
            } else {
                VStack(spacing: 12) {
                    Text(isCorrect ? "✅ Correct!" : "❌ Wrong!")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(isCorrect ? AppTheme.healthGreen : AppTheme.dangerRed)
                    
                    Button(action: nextQuestion) {
                        Text(currentIndex + 1 < questions.count ? "Next →" : "See Results")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white).frame(maxWidth: .infinity).padding(16)
                            .background(AppTheme.quizGradient).clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 20)
                }
            }
            
            Spacer(minLength: 30)
        }
    }
    
    // MARK: - Result
    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "trophy.fill").font(.system(size: 60)).foregroundStyle(AppTheme.warmOrange)
            Text("\(correctCount)/\(questions.count) Correct")
                .font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            
            let xp = correctCount * GameEngineManager.xpQuizCorrect
            HStack(spacing: 8) {
                Image(systemName: "star.fill").foregroundStyle(AppTheme.warmOrange)
                Text("+\(xp) XP").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.warmOrange)
            }
            .padding(16).glassBackground()
            
            Spacer()
            Button(action: { dismiss() }) {
                Text("Done").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(16).background(AppTheme.quizGradient).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20).padding(.bottom, 40)
        }
    }
    
    // MARK: - Logic
    private func prepareQuestion() {
        guard currentIndex < questions.count else { return }
        statementIsTrue = Bool.random()
        if !statementIsTrue {
            let q = questions[currentIndex]
            let wrongIdx = q.options.indices.filter { $0 != q.correctIndex }.randomElement() ?? 0
            altStatement = q.question.replacingOccurrences(of: "______", with: q.options[wrongIdx])
        }
    }
    
    private func answer(userSaidTrue: Bool) {
        isCorrect = (userSaidTrue == statementIsTrue)
        if isCorrect { correctCount += 1 }
        flashColor = isCorrect ? AppTheme.healthGreen : AppTheme.dangerRed
        answered = true
        isCorrect ? HapticManager.notification(.success) : HapticManager.notification(.error)
    }
    
    private func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            answered = false; flashColor = .clear
            prepareQuestion()
            HapticManager.selection()
        } else {
            let xp = correctCount * GameEngineManager.xpQuizCorrect
            GameEngineManager.shared.awardXP(amount: xp, source: "Yes/No Quiz", icon: "checkmark.circle")
            showResult = true
        }
    }
}
