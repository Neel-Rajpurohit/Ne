import SwiftUI

// MARK: - Fitness Home View
struct FitnessHomeView: View {
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Banner
                HStack(spacing: 16) {
                    Image(systemName: "dumbbell.fill").font(.system(size: 40)).foregroundStyle(AppTheme.fitnessGradient)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fitness Studio").font(.system(.title2, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        Text("Exercise • Yoga • Breathing").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Categories
                NavigationLink(destination: ExerciseListView()) {
                    fitnessCard(icon: "figure.strengthtraining.traditional", title: "Exercises", subtitle: "\(ExerciseModel.exercises.count) workouts available", gradient: AppTheme.fitnessGradient, color: AppTheme.warmOrange)
                }
                .buttonStyle(ScaleButtonStyle())
                
                NavigationLink(destination: YogaListView()) {
                    fitnessCard(icon: "figure.yoga", title: "Yoga", subtitle: "\(YogaModel.poses.count) poses to explore", gradient: AppTheme.yogaGradient, color: AppTheme.yogaTeal)
                }
                .buttonStyle(ScaleButtonStyle())
                
                NavigationLink(destination: BreathingView()) {
                    fitnessCard(icon: "wind", title: "Breathing", subtitle: "\(BreathingPreset.presets.count) exercises for calm", gradient: AppTheme.breathingGradient, color: AppTheme.breathingCyan)
                }
                .buttonStyle(ScaleButtonStyle())
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20).padding(.top, 10)
        }
        .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
    }
    
    private func fitnessCard(icon: String, title: String, subtitle: String, gradient: LinearGradient, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 56, height: 56)
                Image(systemName: icon).font(.title2).foregroundStyle(gradient)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                Text(subtitle).font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(AppTheme.textTertiary)
        }
        .padding(20).glassBackground()
        .opacity(appeared ? 1 : 0)
    }
}
