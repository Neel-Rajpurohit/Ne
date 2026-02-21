import SwiftUI

// MARK: - Steps View
struct StepsView: View {
    @StateObject private var viewModel = StepsViewModel()
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - Large Progress Ring
                    CircularProgressView(
                        progress: viewModel.progress,
                        lineWidth: 18,
                        size: 200,
                        gradient: AppColors.stepsGradient,
                        icon: "figure.walk",
                        label: viewModel.todaySteps.withCommas,
                        sublabel: "of \(viewModel.stepGoal.withCommas)"
                    )
                    .padding(.top, 10)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)
                    
                    // MARK: - Today Stats
                    HStack(spacing: 16) {
                        statCard(
                            icon: "figure.walk",
                            title: "Steps",
                            value: viewModel.todaySteps.withCommas,
                            color: AppColors.stepsColor
                        )
                        
                        statCard(
                            icon: "map.fill",
                            title: "Distance",
                            value: viewModel.todayDistance.asKilometers,
                            color: AppColors.waterColor
                        )
                        
                        statCard(
                            icon: "flame.fill",
                            title: "Progress",
                            value: min(viewModel.progress, 1.0).asPercent,
                            color: AppColors.streakColor
                        )
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    
                    // MARK: - Daily Insight
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(AppColors.streakGradient)
                        Text(viewModel.todayInsight)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(AppColors.primaryText)
                        Spacer()
                    }
                    .padding(16)
                    .glassBackground()
                    .opacity(appeared ? 1 : 0)
                    
                    // MARK: - Weekly Chart
                    WeeklyChartView(
                        data: viewModel.weeklyChartData,
                        goal: Double(viewModel.stepGoal),
                        accentColor: AppColors.stepsColor,
                        gradient: AppColors.stepsGradient,
                        title: "Weekly Steps",
                        unit: "steps"
                    )
                    .opacity(appeared ? 1 : 0)
                    
                    // MARK: - Weekly Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Summary")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppColors.primaryText)
                        
                        summaryRow(label: "Total Steps", value: viewModel.healthKit.weeklyTotal.withCommas)
                        summaryRow(label: "Daily Average", value: viewModel.healthKit.weeklyAverage.withCommas)
                        summaryRow(label: "Total Distance", value: viewModel.healthKit.totalWeeklyDistance.asKilometers)
                        if let best = viewModel.healthKit.bestDay {
                            summaryRow(label: "Best Day", value: "\(best.steps.withCommas) (\(best.date.shortDayName))")
                        }
                    }
                    .padding(20)
                    .glassBackground()
                    .opacity(appeared ? 1 : 0)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Steps")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    appeared = true
                }
                viewModel.refresh()
            }
            .refreshable {
                viewModel.refresh()
            }
        }
    }
    
    // MARK: - Stat Card
    private func statCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(AppColors.primaryText)
            
            Text(title)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassBackground(cornerRadius: 16)
    }
    
    // MARK: - Summary Row
    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppColors.secondaryText)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)
        }
    }
}
