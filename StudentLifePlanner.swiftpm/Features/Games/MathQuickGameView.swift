import SwiftUI

struct MathQuickGameView: View {
    @StateObject private var engine = GameEngineService.shared
    @State private var problem = GameEngineService.shared.generateMathProblem()
    @State private var score = 0
    @State private var timeLeft = 60
    @State private var isGameOver = false
    @Environment(\.dismiss) var dismiss
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 40) {
                // Header
                HStack {
                    Button("Quit") { dismiss() }
                        .foregroundColor(AppColors.textPrimary)
                        .font(.headline)
                    Spacer()
                    Text("Math Quick")
                        .font(.headline.bold())
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                }
                .padding()
                
                // Timer
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 10)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timeLeft) / 60.0)
                        .stroke(timeLeft < 10 ? Color.red : Color.green, lineWidth: 10)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(timeLeft)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Problem
                VStack(spacing: 20) {
                    Text(problem.question)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Select the correct answer")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Options
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(problem.options, id: \.self) { option in
                        Button(action: { checkAnswer(option) }) {
                            Text("\(option)")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            if isGameOver {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Time's Up!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    VStack(spacing: 10) {
                        Text("Final Score")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(score)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { finishGame() }) {
                        Text("Collect Bonus & Exit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(AppColors.primary)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                isGameOver = true
            }
        }
    }
    
    private func checkAnswer(_ option: Int) {
        if option == problem.answer {
            score += 10
            problem = engine.generateMathProblem()
            // Haptic feedback could go here
        } else {
            score -= 5
            problem = engine.generateMathProblem()
        }
    }
    
    private func finishGame() {
        engine.awardBonusPoint()
        dismiss()
    }
}
