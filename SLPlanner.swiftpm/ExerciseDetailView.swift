import SwiftUI

// MARK: - Exercise Detail View
struct ExerciseDetailView: View {
    let exercise: ExerciseModel
    @StateObject private var timer = TimerManager()
    @State private var currentSet = 0
    @State private var isWorkingOut = false
    @State private var completed = false
    @State private var appeared = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Hero Header
                ZStack {
                    Circle()
                        .fill(exercise.category.color.opacity(0.15))
                        .frame(width: 130, height: 130)
                    Image(systemName: exercise.icon)
                        .font(.system(size: 55))
                        .foregroundStyle(
                            LinearGradient(colors: [exercise.category.color, exercise.category.color.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
                .opacity(appeared ? 1 : 0).scaleEffect(appeared ? 1 : 0.8)
                
                // Name + Meta
                VStack(spacing: 6) {
                    Text(exercise.name)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(exercise.muscleGroup)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                    HStack(spacing: 4) {
                        ForEach(0..<exercise.difficulty.dots, id: \.self) { _ in
                            Circle().fill(exercise.difficulty.color).frame(width: 8, height: 8)
                        }
                        Text(exercise.difficulty.rawValue)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(exercise.difficulty.color)
                        Text("•")
                            .foregroundStyle(AppTheme.textTertiary)
                        Text(exercise.category.rawValue)
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundStyle(exercise.category.color)
                    }
                }
                
                // Stats
                HStack(spacing: 20) {
                    statBubble(icon: "clock.fill", value: "\(exercise.duration)s", label: "Duration")
                    statBubble(icon: "flame.fill", value: "\(exercise.calories)", label: "Calories")
                    statBubble(icon: "arrow.counterclockwise", value: "\(exercise.sets)x\(exercise.reps)", label: "Sets×Reps")
                }
                .opacity(appeared ? 1 : 0)
                
                // ─── ✅ Correct Form ───
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.healthGreen)
                        Text("Correct Form").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                    }
                    ForEach(exercise.correctForm, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•").foregroundStyle(AppTheme.healthGreen).font(.subheadline)
                            Text(tip).font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // ─── ⚠️ Common Mistakes ───
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(AppTheme.warmOrange)
                        Text("Common Mistakes").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                    }
                    ForEach(exercise.commonMistakes, id: \.self) { mistake in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•").foregroundStyle(AppTheme.warmOrange).font(.subheadline)
                            Text(mistake).font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // ─── 💨 Breathing ───
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(AppTheme.breathingCyan.opacity(0.15)).frame(width: 44, height: 44)
                        Image(systemName: "wind").foregroundStyle(AppTheme.breathingCyan)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Breathing").font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                        Text(exercise.breathingTip).font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding(16).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Workout Area
                if isWorkingOut && !completed {
                    workoutView
                } else if completed {
                    completedView
                } else {
                    Button(action: startWorkout) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text("Start Exercise").font(.system(.headline, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(.white).frame(maxWidth: .infinity).padding(18)
                        .background(AppTheme.fitnessGradient).clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppTheme.warmOrange.opacity(0.4), radius: 10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20).padding(.top, 10)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
    }
    
    private func statBubble(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(AppTheme.fitnessGradient)
            Text(value).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16).glassBackground(cornerRadius: 16)
    }
    
    private var workoutView: some View {
        VStack(spacing: 20) {
            Text("Set \(currentSet + 1) of \(exercise.sets)")
                .font(.system(.title2, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            
            // Posture reminder during workout
            HStack(spacing: 8) {
                Image(systemName: "figure.stand").foregroundStyle(AppTheme.healthGreen)
                Text(exercise.correctForm.first ?? "Keep good form!")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.healthGreen)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(AppTheme.healthGreen.opacity(0.1))
            .clipShape(Capsule())
            
            CircularProgressView(progress: timer.progress, lineWidth: 14, size: 160, gradient: AppTheme.fitnessGradient, label: timer.formattedTime, sublabel: "\(exercise.reps) reps")
            
            HStack(spacing: 20) {
                Button(action: { timer.isPaused ? timer.resume() : timer.pause(); HapticManager.impact(.medium) }) {
                    Image(systemName: timer.isPaused ? "play.fill" : "pause.fill").font(.title2).foregroundStyle(.white)
                        .frame(width: 60, height: 60).background(AppTheme.fitnessGradient).clipShape(Circle())
                }
                Button(action: nextSet) {
                    Text("Next Set →").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(.white)
                        .padding(.horizontal, 24).padding(.vertical, 14).background(AppTheme.healthGreen).clipShape(Capsule())
                }
            }
        }
        .padding(20).glassBackground()
        .onChange(of: timer.isCompleted) { _ in if timer.isCompleted { nextSet() } }
    }
    
    private var completedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 60)).foregroundStyle(AppTheme.healthGreen)
            Text("Exercise Complete!").font(.system(.title2, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text("+\(GameEngineManager.xpExerciseComplete) XP").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.warmOrange)
        }
        .padding(30).glassBackground()
    }
    
    private func startWorkout() {
        isWorkingOut = true
        currentSet = 0
        timer.start(duration: exercise.duration)
        HapticManager.impact(.heavy)
    }
    
    private func nextSet() {
        if currentSet + 1 < exercise.sets {
            currentSet += 1
            timer.start(duration: exercise.duration)
            HapticManager.impact(.medium)
        } else {
            completed = true
            timer.stop()
            GameEngineManager.shared.awardXP(amount: GameEngineManager.xpExerciseComplete, source: exercise.name, icon: "figure.strengthtraining.traditional")
            TaskCompletionManager.shared.completeExercise()
            HapticManager.notification(.success)
        }
    }
}
