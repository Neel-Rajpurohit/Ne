import SwiftUI

// MARK: - Health Overview View
struct HealthOverviewView: View {
    @State private var selectedTab = 0
    @State private var appeared = false
    
    let tabs = ["Overview", "Steps", "Water", "Sleep", "Mind"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tabs.indices, id: \.self) { idx in
                            Button(action: { withAnimation(.spring(response: 0.3)) { selectedTab = idx }; HapticManager.selection() }) {
                                Text(tabs[idx])
                                    .font(.system(.caption, design: .rounded, weight: .semibold))
                                    .foregroundStyle(selectedTab == idx ? .white : AppTheme.textSecondary)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(selectedTab == idx ? AnyShapeStyle(AppTheme.healthGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 20).padding(.vertical, 10)
                }
                
                // Tab Content (conditional to avoid nested NavigationStack)
                Group {
                    switch selectedTab {
                    case 0: healthOverview
                    case 1: stepsContent
                    case 2: waterContent
                    case 3: SleepView()
                    case 4: MentalHealthView()
                    default: healthOverview
                    }
                }
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Health")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.6)) { appeared = true }
            }
        }
    }
    
    // MARK: - Overview Tab
    private var healthOverview: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                let healthKit = HealthKitManager.shared
                let storage = StorageManager.shared
                
                // Quick Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    overviewCard(icon: "figure.walk", label: "Steps", value: healthKit.todaySteps.withCommas, gradient: AppColors.stepsGradient)
                    overviewCard(icon: "drop.fill", label: "Water", value: storage.todayWater.totalML.asLiters, gradient: AppColors.waterGradient)
                    overviewCard(icon: "bed.double.fill", label: "Sleep", value: "7.5h", gradient: AppTheme.sleepGradient)
                    overviewCard(icon: "heart.fill", label: "Mood", value: "😊", gradient: AppTheme.mentalGradient)
                }
                
                // Fitness Quick Access
                NavigationLink(destination: FitnessHomeView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "dumbbell.fill").font(.title2).foregroundStyle(AppTheme.fitnessGradient)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Fitness").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                            Text("Exercise • Yoga • Breathing").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(16).glassBackground()
                }
                .buttonStyle(ScaleButtonStyle())
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20).padding(.top, 10)
        }
    }
    
    // MARK: - Steps (inline, no NavigationStack)
    private var stepsContent: some View {
        StepsContentView()
    }
    
    // MARK: - Water (inline, no NavigationStack)
    private var waterContent: some View {
        WaterContentView()
    }
    
    private func overviewCard(icon: String, label: String, value: String, gradient: LinearGradient) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.title2).foregroundStyle(gradient)
            Text(value).font(.system(.title3, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20).glassBackground(cornerRadius: 16)
    }
}

// MARK: - Steps Content (no NavigationStack wrapper)
struct StepsContentView: View {
    @StateObject private var viewModel = StepsViewModel()
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                CircularProgressView(
                    progress: viewModel.progress,
                    lineWidth: 18, size: 200,
                    gradient: AppColors.stepsGradient,
                    icon: "figure.walk",
                    label: viewModel.healthKit.todaySteps.formattedSteps,
                    sublabel: "of \(viewModel.storage.userGoals.dailyStepGoal.withCommas)"
                )
                .padding(.top, 10)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)
                
                // Today's stats
                HStack(spacing: 16) {
                    stepStat(icon: "location.fill", label: "Distance", value: viewModel.healthKit.todayDistance.asKilometers)
                    stepStat(icon: "flame.fill", label: "Calories", value: "\(Int(Double(viewModel.healthKit.todaySteps) * 0.04))")
                    stepStat(icon: "clock.fill", label: "Active", value: "\(viewModel.healthKit.todaySteps / 100)m")
                }
                .opacity(appeared ? 1 : 0)
                
                // Insight
                HStack(spacing: 10) {
                    Image(systemName: "sparkle").foregroundStyle(AppColors.stepsGradient)
                    Text(viewModel.todayInsight).font(.system(.subheadline, design: .rounded)).foregroundStyle(AppColors.secondaryText)
                    Spacer()
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Weekly Chart
                WeeklyChartView(
                    data: viewModel.weeklyChartData,
                    goal: Double(viewModel.storage.userGoals.dailyStepGoal),
                    accentColor: AppColors.stepsColor,
                    gradient: AppColors.stepsGradient,
                    title: "Weekly Steps",
                    unit: "steps"
                )
                .opacity(appeared ? 1 : 0)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .onAppear { withAnimation(.spring(response: 0.7)) { appeared = true } }
    }
    
    private func stepStat(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(AppColors.stepsGradient)
            Text(value).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppColors.primaryText)
            Text(label).font(.system(.caption2, design: .rounded)).foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16).glassBackground(cornerRadius: 16)
    }
}

// MARK: - Water Content (no NavigationStack wrapper)
struct WaterContentView: View {
    @StateObject private var viewModel = WaterViewModel()
    @State private var manualInput: String = ""
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                CircularProgressView(
                    progress: viewModel.progress,
                    lineWidth: 18, size: 200,
                    gradient: AppColors.waterGradient,
                    icon: "drop.fill",
                    label: viewModel.storage.todayWater.totalML.asLiters,
                    sublabel: "of \(viewModel.storage.userGoals.dailyWaterGoal.asLiters)"
                )
                .padding(.top, 10)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)
                
                // Quick Add
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Add").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppColors.primaryText)
                    HStack(spacing: 10) {
                        ForEach([150, 250, 500, 750], id: \.self) { ml in
                            Button(action: { viewModel.addWater(Double(ml)); HapticManager.impact(.light) }) {
                                Text("\(ml)ml")
                                    .font(.system(.caption, design: .rounded, weight: .bold))
                                    .foregroundStyle(AppColors.waterColor)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(AppColors.waterColor.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Hydration Level Indicator
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hydration Level").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppColors.primaryText)
                    
                    let pct = viewModel.progress
                    let hydrationColor: Color = pct >= 1.0 ? AppTheme.healthGreen : pct >= 0.6 ? AppTheme.warmOrange : AppTheme.dangerRed
                    let hydrationEmoji = pct >= 1.0 ? "🟢" : pct >= 0.6 ? "🟡" : "🔴"
                    let hydrationLabel = pct >= 1.0 ? "Perfect! Stay hydrated" : pct >= 0.6 ? "Mild dehydration risk" : "Drink water now!"
                    
                    HStack(spacing: 12) {
                        Text(hydrationEmoji).font(.title)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(Int(pct * 100))%").font(.system(.title2, design: .rounded, weight: .bold)).foregroundStyle(hydrationColor)
                            Text(hydrationLabel).font(.system(.caption, design: .rounded)).foregroundStyle(AppColors.secondaryText)
                        }
                        Spacer()
                    }
                    
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.1)).frame(height: 10)
                            RoundedRectangle(cornerRadius: 6).fill(hydrationColor).frame(width: geo.size.width * min(pct, 1.0), height: 10)
                        }
                    }
                    .frame(height: 10)
                    
                    // Warning for low hydration
                    if pct < 0.4 {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(AppTheme.dangerRed)
                            Text("Drink 300–500ml extra water today!").font(.system(.caption, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.dangerRed)
                        }
                        .padding(10).background(AppTheme.dangerRed.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Hydration Insight
                HStack(spacing: 10) {
                    Image(systemName: "drop.fill").foregroundStyle(AppColors.waterGradient).font(.caption)
                    Text(viewModel.hydrationInsight).font(.system(.subheadline, design: .rounded)).foregroundStyle(AppColors.secondaryText)
                    Spacer()
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Weekly Chart
                WeeklyChartView(
                    data: viewModel.weeklyChartData,
                    goal: viewModel.storage.userGoals.dailyWaterGoal,
                    accentColor: AppColors.waterColor,
                    gradient: AppColors.waterGradient,
                    title: "Weekly Water",
                    unit: "ml"
                )
                .opacity(appeared ? 1 : 0)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .onAppear { withAnimation(.spring(response: 0.7)) { appeared = true } }
    }
}
