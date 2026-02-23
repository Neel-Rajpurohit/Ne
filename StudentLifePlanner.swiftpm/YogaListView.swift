import SwiftUI

// MARK: - Yoga List View
struct YogaListView: View {
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(YogaModel.poses) { pose in
                    NavigationLink(destination: YogaDetailView(yoga: pose)) {
                        YogaCard(yoga: pose)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20).padding(.top, 10)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationTitle("Yoga Poses")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
    }
}

// MARK: - Yoga Detail View
struct YogaDetailView: View {
    let yoga: YogaModel
    @StateObject private var timer = TimerManager()
    @State private var isHolding = false
    @State private var completed = false
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Pose Icon
                ZStack {
                    Circle().fill(AppTheme.yogaTeal.opacity(0.15)).frame(width: 120, height: 120)
                    Image(systemName: yoga.icon).font(.system(size: 50)).foregroundStyle(AppTheme.yogaGradient)
                }
                .opacity(appeared ? 1 : 0).scaleEffect(appeared ? 1 : 0.8)
                
                VStack(spacing: 6) {
                    Text(yoga.name).font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                    HStack(spacing: 2) {
                        ForEach(0..<yoga.difficulty.dots, id: \.self) { _ in
                            Circle().fill(yoga.difficulty.color).frame(width: 8, height: 8)
                        }
                        Text(yoga.difficulty.rawValue).font(.system(.caption2, design: .rounded)).foregroundStyle(yoga.difficulty.color)
                    }
                }
                
                // Benefits
                HStack(spacing: 8) {
                    ForEach(yoga.benefits, id: \.self) { benefit in
                        Text(benefit).font(.system(.caption, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.yogaTeal)
                            .padding(.horizontal, 12).padding(.vertical, 6).background(AppTheme.yogaTeal.opacity(0.15)).clipShape(Capsule())
                    }
                }
                .opacity(appeared ? 1 : 0)
                
                // Instructions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Instructions").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                    Text(yoga.instructions).font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                }
                .padding(20).glassBackground()
                
                // Timer / Action
                if isHolding && !completed {
                    VStack(spacing: 16) {
                        Text("Hold the pose").font(.system(.headline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                        CircularProgressView(progress: timer.progress, lineWidth: 14, size: 160, gradient: AppTheme.yogaGradient, label: timer.formattedTime, sublabel: "remaining")
                    }
                    .padding(20).glassBackground()
                    .onChange(of: timer.isCompleted) { _ in
                        if timer.isCompleted {
                            completed = true
                            GameEngineManager.shared.awardXP(amount: GameEngineManager.xpYogaComplete, source: yoga.name, icon: "figure.yoga")
                            TaskCompletionManager.shared.completeExercise()
                        }
                    }
                } else if completed {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles").font(.system(size: 50)).foregroundStyle(AppTheme.yogaGradient)
                        Text("Pose Complete!").font(.system(.title3, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        Text("+\(GameEngineManager.xpYogaComplete) XP").font(.system(.headline, design: .rounded)).foregroundStyle(AppTheme.warmOrange)
                    }
                    .padding(30).glassBackground()
                } else {
                    Button(action: { isHolding = true; timer.start(duration: yoga.holdTime); HapticManager.impact(.medium) }) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text("Start Hold (\(yoga.holdTime)s)").font(.system(.headline, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(.white).frame(maxWidth: .infinity).padding(18)
                        .background(AppTheme.yogaGradient).clipShape(RoundedRectangle(cornerRadius: 16))
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
}
