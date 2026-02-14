import SwiftUI

struct BreathingView: View {
    @StateObject var viewModel = HealthViewModel()
    
    var body: some View {
        ZStack {
            AppBackground(style: .health)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.breathingExercises) { exercise in
                        NavigationLink(destination: BreathingExerciseView(exercise: exercise)) {
                            BreathingExerciseCard(exercise: exercise)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Breathing Exercises")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BreathingExerciseCard: View {
    let exercise: BreathingExercise
    
    var body: some View {
        InfoCard {
            HStack(spacing: 15) {
                Image(systemName: exercise.iconName)
                    .font(.title)
                    .foregroundColor(.healthBreathing)
                    .frame(width: 50, height: 50)
                    .background(Color.healthBreathing.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.appHeadline)
                        .foregroundColor(.appText)
                    
                    Text("\(exercise.totalCycles) cycles")
                        .font(.appCaption)
                        .foregroundColor(.healthBreathing)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
    }
}

struct BreathingExerciseView: View {
    let exercise: BreathingExercise
    
    @State private var currentPhase: BreathPhase = .inhale
    @State private var phaseTimeRemaining = 0
    @State private var currentCycle = 0
    @State private var isActive = false
    @State private var timer: Timer?
    @State private var circleScale: CGFloat = 0.6
    
    var body: some View {
        ZStack {
            AppBackground(style: .health)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Info
                InfoCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.description)
                            .font(.appBody)
                            .foregroundColor(.appText)
                        
                        Divider()
                        
                        Text("Benefits: " + exercise.benefits)
                            .font(.appCaption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .padding(.horizontal)
                
                // Breathing circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.healthBreathing.opacity(0.3), .healthBreathing],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(circleScale)
                        .animation(.easeInOut(duration: 1), value: circleScale)
                    
                    VStack(spacing: 8) {
                        Text(currentPhase.displayName)
                            .font(.appTitle)
                            .foregroundColor(.white)
                        
                        if isActive {
                            Text("\(phaseTimeRemaining)")
                                .font(.appTimer)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Cycle counter
                Text("Cycle \(currentCycle) / \(exercise.totalCycles)")
                    .font(.appHeadline)
                    .foregroundColor(.appTextSecondary)
                
                Spacer()
                
                // Controls
                Button(action: {
                    if isActive {
                        stopBreathing()
                    } else {
                        startBreathing()
                    }
                }) {
                    Text(isActive ? "Stop" : "Start")
                        .font(.appHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isActive ? Color.appError : Color.healthBreathing)
                        .cornerRadius(Constants.buttonCornerRadius)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopBreathing()
        }
    }
    
    private func startBreathing() {
        isActive = true
        currentCycle = 0
        currentPhase = .inhale
        phaseTimeRemaining = exercise.pattern.inhale
        circleScale = 0.6
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            Task { @MainActor in
                self.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func stopBreathing() {
        isActive = false
        timer?.invalidate()
        timer = nil
        circleScale = 0.6
        currentCycle = 0
    }
    
    private func tick() {
        phaseTimeRemaining -= 1
        
        if phaseTimeRemaining <= 0 {
            nextPhase()
        }
        
        // Animate circle
        updateCircleScale()
    }
    
    private func nextPhase() {
        switch currentPhase {
        case .inhale:
            currentPhase = .hold
            phaseTimeRemaining = exercise.pattern.hold
        case .hold:
            currentPhase = .exhale
            phaseTimeRemaining = exercise.pattern.exhale
        case .exhale:
            if exercise.pattern.holdAfterExhale > 0 {
                currentPhase = .holdAfterExhale
                phaseTimeRemaining = exercise.pattern.holdAfterExhale
            } else {
                completeCycle()
            }
        case .holdAfterExhale:
            completeCycle()
        }
    }
    
    private func completeCycle() {
        currentCycle += 1
        
        if currentCycle >= exercise.totalCycles {
            stopBreathing()
        } else {
            currentPhase = .inhale
            phaseTimeRemaining = exercise.pattern.inhale
        }
    }
    
    private func updateCircleScale() {
        switch currentPhase {
        case .inhale:
            circleScale = 1.0
        case .hold:
            circleScale = 1.0
        case .exhale:
            circleScale = 0.6
        case .holdAfterExhale:
            circleScale = 0.6
        }
    }
}

enum BreathPhase {
    case inhale
    case hold
    case exhale
    case holdAfterExhale
    
    var displayName: String {
        switch self {
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        case .holdAfterExhale: return "Hold"
        }
    }
}
