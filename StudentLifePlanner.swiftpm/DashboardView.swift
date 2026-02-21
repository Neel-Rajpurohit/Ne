import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @StateObject private var game = GameEngineManager.shared
    @ObservedObject private var profileManager = ProfileManager.shared
    @StateObject private var planner = PlannerEngine.shared
    @StateObject private var healthKit = HealthKitManager.shared
    @StateObject private var storage = StorageManager.shared
    @StateObject private var brainScore = BrainScoreManager.shared
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Greeting
                    VStack(alignment: .leading, spacing: 6) {
                        Text(GreetingHelper.greeting())
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Hey \(profileManager.profile.name.isEmpty ? "Student" : profileManager.profile.name)! 👋")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(Date().formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(appeared ? 1 : 0)
                    
                    // XP & Level
                    HStack(spacing: 14) {
                        LevelBadge(level: game.profile.level, title: game.profile.title)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Level \(game.profile.level) — \(game.profile.title)")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            XPProgressBar(profile: game.profile)
                        }
                    }
                    .padding(16).glassBackground()
                    .opacity(appeared ? 1 : 0)
                    
                    // Study Progress Ring
                    CircularProgressView(
                        progress: studyProgress,
                        lineWidth: 14, size: 140,
                        gradient: AppTheme.studyGradient,
                        icon: "book.fill",
                        label: "\(planner.todayRoutine.totalStudyMinutes)",
                        sublabel: "min study"
                    )
                    .opacity(appeared ? 1 : 0)
                    
                    // 4-Card Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        quickCard(icon: "book.fill", label: "Study", value: "\(planner.todayRoutine.studyBlocks.count) sessions", color: AppTheme.studyBlue, gradient: AppTheme.studyGradient)
                        quickCard(icon: "drop.fill", label: "Water", value: storage.todayWater.totalML.asLiters, color: AppColors.waterColor, gradient: AppColors.waterGradient)
                        quickCard(icon: "figure.walk", label: "Steps", value: healthKit.todaySteps.withCommas, color: AppColors.stepsColor, gradient: AppColors.stepsGradient)
                        quickCard(icon: "brain.head.profile", label: "Quiz", value: "\(QuizManager.shared.totalQuizzesTaken) done", color: AppTheme.quizPink, gradient: AppTheme.quizGradient)
                    }
                    .opacity(appeared ? 1 : 0)
                    
                    // Today's Schedule Preview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Today's Schedule").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            NavigationLink(destination: TimetableView()) {
                                Text("See All").font(.system(.caption, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.neonCyan)
                            }
                        }
                        
                        ForEach(planner.todayRoutine.blocks.prefix(5)) { block in
                            HStack(spacing: 12) {
                                if block.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.healthGreen)
                                        .frame(width: 4)
                                } else {
                                    RoundedRectangle(cornerRadius: 2).fill(block.type.lightColor).frame(width: 4, height: 30)
                                }
                                Image(systemName: block.isCompleted ? "checkmark.circle.fill" : block.type.icon)
                                    .font(.caption)
                                    .foregroundStyle(block.isCompleted ? AppTheme.healthGreen : block.type.lightColor)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(block.displayTitle)
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundStyle(block.isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary)
                                        .strikethrough(block.isCompleted, color: AppTheme.textTertiary)
                                    Text("\(block.startTime) — \(block.endTime)")
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundStyle(AppTheme.textTertiary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(20).glassBackground()
                    .opacity(appeared ? 1 : 0)
                    
                    // Brain Performance
                    if brainScore.todayScore.gamesPlayed > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "brain.head.profile").foregroundStyle(AppTheme.primaryPurple)
                                Text("Brain Performance Today")
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Spacer()
                                Text("\(brainScore.todayScore.performancePercent)%")
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                    .foregroundStyle(AppTheme.primaryPurple)
                            }
                            
                            HStack(spacing: 8) {
                                brainStatPill(icon: "rectangle.on.rectangle.angled", label: "Memory", value: brainScore.todayScore.memoryPoints, color: AppTheme.primaryPurple)
                                brainStatPill(icon: "square.grid.3x3.fill", label: "Speed", value: brainScore.todayScore.speedPoints, color: AppTheme.quizPink)
                            }
                        }
                        .padding(20).glassBackground()
                        .opacity(appeared ? 1 : 0)
                    }
                    
                    // Motivation
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles").foregroundStyle(AppTheme.warmOrange)
                        Text(GreetingHelper.motivationalMessage(
                            stepsProgress: Double(healthKit.todaySteps) / Double(profileManager.profile.stepGoal),
                            waterProgress: storage.todayWater.totalML / profileManager.profile.waterGoal
                        ))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(16).glassBackground()
                    .opacity(appeared ? 1 : 0)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20).padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill").foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            .onAppear {
                planner.generateToday()
                healthKit.requestAuthorization()
                withAnimation(.spring(response: 0.6)) { appeared = true }
            }
        }
    }
    
    private var studyProgress: Double {
        let total = planner.todayRoutine.totalStudyMinutes
        guard total > 0 else { return 0 }
        return min(1.0, Double(game.recentXP.filter { Calendar.current.isDateInToday($0.timestamp) }.count) / Double(planner.todayRoutine.studyBlocks.count))
    }
    
    private func quickCard(icon: String, label: String, value: String, color: Color, gradient: LinearGradient) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(gradient)
            Text(value).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 18).glassBackground(cornerRadius: 16)
    }
    
    private func brainStatPill(icon: String, label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.caption).foregroundStyle(color)
            Text("\(value)").font(.system(.subheadline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12).glassBackground(cornerRadius: 12)
    }
}
