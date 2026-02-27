import SwiftUI

// MARK: - Mind Math Game
struct MindMathGame: View {
    @State private var num1 = 0
    @State private var num2 = 0
    @State private var operation = "+"
    @State private var answer = ""
    @State private var correctAnswer = 0
    @State private var score = 0
    @State private var timeLeft = 30
    @State private var isActive = false
    @State private var isComplete = false
    @State private var flashCorrect = false
    @State private var flashWrong = false
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if flashCorrect {
                AppTheme.healthGreen.opacity(0.2).ignoresSafeArea().animation(.easeOut(duration: 0.3), value: flashCorrect)
            }
            if flashWrong {
                AppTheme.dangerRed.opacity(0.2).ignoresSafeArea().animation(.easeOut(duration: 0.3), value: flashWrong)
            }
            
            if isComplete {
                resultView
            } else if isActive {
                gameView
            } else {
                startView
            }
        }
    }
    
    // MARK: - Start
    private var startView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(AppTheme.warmOrange.opacity(0.15)).frame(width: 140, height: 140)
                Image(systemName: "brain.head.profile").font(.system(size: 60)).foregroundStyle(AppTheme.warmOrange)
            }
            Text("Mind Math").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text("Solve as many as you can in 30 seconds!")
                .font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 40)
            
            Button(action: startGame) {
                Text("Start!").font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white).frame(width: 200).padding(16)
                    .background(AppTheme.fitnessGradient).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            Spacer()
            
            Button("Close") { dismiss() }.foregroundStyle(AppTheme.textTertiary)
                .padding(.bottom, 30)
        }
    }
    
    // MARK: - Game
    private var gameView: some View {
        VStack(spacing: 24) {
            // Timer + Score
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill").foregroundStyle(timeLeft <= 10 ? AppTheme.dangerRed : AppTheme.neonCyan)
                    Text("\(timeLeft)s")
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                        .foregroundStyle(timeLeft <= 10 ? AppTheme.dangerRed : AppTheme.textPrimary)
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(AppTheme.warmOrange)
                    Text("\(score)")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
            .padding(.horizontal, 30).padding(.top, 30)
            
            Spacer()
            
            // Problem
            Text("\(num1) \(operation) \(num2) = ?")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            
            // Answer Input
            HStack(spacing: 0) {
                TextField("?", text: $answer)
                    .font(.system(.title, design: .monospaced, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(width: 120)
                    .padding(16)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            // Submit
            Button(action: checkAnswer) {
                Text("Submit").font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white).frame(width: 200).padding(16)
                    .background(AppTheme.studyGradient).clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Number pad (quick answer)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                ForEach(1...9, id: \.self) { n in
                    Button(action: { answer += "\(n)" }) {
                        Text("\(n)").font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                Button(action: { answer += "0" }) {
                    Text("0").font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 30)
            
            Spacer(minLength: 30)
        }
    }
    
    // MARK: - Result
    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "brain.head.profile").font(.system(size: 60)).foregroundStyle(AppTheme.warmOrange)
            Text("Time's Up!").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text("You solved \(score) problems!").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
            
            HStack(spacing: 8) {
                Image(systemName: "star.fill").foregroundStyle(AppTheme.warmOrange)
                Text("+\(score * 5) XP").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.warmOrange)
            }
            .padding(16).glassBackground()
            
            Spacer()
            Button(action: { dismiss() }) {
                Text("Done").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(16).background(AppTheme.studyGradient).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle()).padding(.horizontal, 30).padding(.bottom, 40)
        }
    }
    
    // MARK: - Logic
    private func startGame() {
        score = 0; timeLeft = 30; isActive = true
        generateProblem()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if timeLeft > 0 { timeLeft -= 1 } else {
                    timer?.invalidate()
                    isActive = false; isComplete = true
                    GameEngineManager.shared.awardXP(amount: score * 5, source: "Mind Math", icon: "brain.head.profile")
                    HapticManager.notification(.success)
                }
            }
        }
    }
    
    private func generateProblem() {
        let ops = ["+", "-", "×"]
        operation = ops.randomElement()!
        num1 = Int.random(in: 2...20)
        num2 = Int.random(in: 2...15)
        switch operation {
        case "+": correctAnswer = num1 + num2
        case "-":
            if num2 > num1 { swap(&num1, &num2) }
            correctAnswer = num1 - num2
        case "×": correctAnswer = num1 * num2
        default: correctAnswer = num1 + num2
        }
        answer = ""
    }
    
    private func checkAnswer() {
        if let val = Int(answer), val == correctAnswer {
            score += 1
            flashCorrect = true
            HapticManager.notification(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashCorrect = false }
        } else {
            flashWrong = true
            HapticManager.notification(.error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashWrong = false }
        }
        generateProblem()
    }
}
