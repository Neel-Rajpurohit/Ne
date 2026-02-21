import SwiftUI
import Charts

// MARK: - Analytics ViewModel
@MainActor
class AnalyticsViewModel: ObservableObject {
    let healthKit = HealthKitManager.shared
    let storage = StorageManager.shared
    let quizManager = QuizManager.shared
    let gameEngine = GameEngineManager.shared
    
    var stepsChartData: [ChartDataPoint] {
        healthKit.weeklySteps.map { ChartDataPoint(label: $0.date.singleLetterDay, value: Double($0.steps), date: $0.date) }
    }
    
    var waterChartData: [ChartDataPoint] {
        storage.weeklyWater.map { ChartDataPoint(label: $0.date.singleLetterDay, value: $0.totalML, date: $0.date) }
    }
    
    var quizAccuracy: Double { quizManager.averageAccuracy }
    var totalXP: Int { gameEngine.profile.totalXP }
    var currentLevel: Int { gameEngine.profile.level }
}

// MARK: - Analytics View
struct AnalyticsView: View {
    @StateObject private var vm = AnalyticsViewModel()
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Summary Cards
                HStack(spacing: 12) {
                    summaryCard(icon: "star.fill", value: "\(vm.totalXP)", label: "Total XP", color: AppTheme.warmOrange)
                    summaryCard(icon: "arrow.up.circle.fill", value: "Lv.\(vm.currentLevel)", label: "Level", color: AppTheme.primaryPurple)
                    summaryCard(icon: "target", value: vm.quizAccuracy > 0 ? "\(Int(vm.quizAccuracy * 100))%" : "—", label: "Quiz Acc", color: AppTheme.quizPink)
                }
                .opacity(appeared ? 1 : 0)
                
                // Steps Chart
                WeeklyChartView(
                    data: vm.stepsChartData,
                    goal: Double(vm.storage.userGoals.dailyStepGoal),
                    accentColor: AppColors.stepsColor,
                    gradient: AppColors.stepsGradient,
                    title: "Weekly Steps",
                    unit: "steps"
                )
                .opacity(appeared ? 1 : 0)
                
                // Water Chart
                WeeklyChartView(
                    data: vm.waterChartData,
                    goal: vm.storage.userGoals.dailyWaterGoal,
                    accentColor: AppColors.waterColor,
                    gradient: AppColors.waterGradient,
                    title: "Weekly Water",
                    unit: "ml"
                )
                .opacity(appeared ? 1 : 0)
                
                // Insights
                VStack(alignment: .leading, spacing: 12) {
                    Text("Insights").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                    
                    insightRow(icon: "figure.walk", text: "Weekly avg: \(vm.healthKit.weeklyAverage.withCommas) steps/day", color: AppColors.stepsColor)
                    insightRow(icon: "drop.fill", text: "Stay hydrated! Track your water daily.", color: AppColors.waterColor)
                    
                    if vm.quizManager.totalQuizzesTaken > 0 {
                        insightRow(icon: "brain.head.profile", text: "\(vm.quizManager.totalQuizzesTaken) quizzes completed", color: AppTheme.quizPink)
                    }
                    
                    insightRow(icon: "flame.fill", text: "Current streak: \(vm.storage.streakData.currentStreak) days", color: AppTheme.warmOrange)
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20).padding(.top, 10)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationTitle("Analytics")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
    }
    
    private func summaryCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16).glassBackground(cornerRadius: 16)
    }
    
    private func insightRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(color)
            Text(text).font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
            Spacer()
        }
    }
}
