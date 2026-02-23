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
                
                // Tab Content
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
    
    // MARK: - Overview Tab (Premium Redesign)
    private var healthOverview: some View {
        let healthKit = HealthKitManager.shared
        let storage = StorageManager.shared
        let profile = ProfileManager.shared.profile
        
        let stepGoal = Double(storage.userGoals.dailyStepGoal)
        let stepsProgress = stepGoal > 0 ? Double(healthKit.todaySteps) / stepGoal : 0
        let calGoal: Double = 500
        let calProgress = calGoal > 0 ? Double(healthKit.todayCalories) / calGoal : 0
        let activeGoal: Double = 30
        let activeProgress = activeGoal > 0 ? Double(healthKit.todayActiveMinutes) / activeGoal : 0
        let overallProgress = min(1.0, (stepsProgress + calProgress + activeProgress) / 3.0)
        
        return ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                
                // ─── A. Personal Greeting ─────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    Text(GreetingHelper.greeting())
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Hey \(profile.name.isEmpty ? "Student" : profile.name)! 👋")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    HStack(spacing: 8) {
                        Text("You're \(Int(overallProgress * 100))% closer to your daily goal!")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(AppTheme.neonCyan)
                        Spacer()
                    }
                    
                    // Animated progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.healthGreen, AppTheme.neonCyan],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * min(overallProgress, 1.0), height: 8)
                                .shadow(color: AppTheme.neonCyan.opacity(0.5), radius: 4)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [AppTheme.healthGreen.opacity(0.3), AppTheme.neonCyan.opacity(0.1)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                // ─── B. Multi-Layer Activity Rings ────────────
                VStack(spacing: 14) {
                    Text("Today's Activity")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 30) {
                        // Multi-ring
                        MultiRingView(
                            rings: [
                                RingData(progress: stepsProgress, gradient: [Color(hex: "10B981"), Color(hex: "06B6D4")], lineWidth: 14),
                                RingData(progress: calProgress, gradient: [Color(hex: "F59E0B"), Color(hex: "EF4444")], lineWidth: 11),
                                RingData(progress: activeProgress, gradient: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")], lineWidth: 8)
                            ],
                            size: 160
                        )
                        
                        // Ring Legend
                        VStack(alignment: .leading, spacing: 14) {
                            ringLegendItem(
                                color: AppTheme.healthGreen,
                                label: "Steps",
                                value: healthKit.todaySteps.withCommas,
                                percent: Int(min(stepsProgress, 1.0) * 100)
                            )
                            ringLegendItem(
                                color: AppTheme.warmOrange,
                                label: "Calories",
                                value: "\(healthKit.todayCalories) kcal",
                                percent: Int(min(calProgress, 1.0) * 100)
                            )
                            ringLegendItem(
                                color: AppTheme.studyBlue,
                                label: "Active",
                                value: "\(healthKit.todayActiveMinutes) min",
                                percent: Int(min(activeProgress, 1.0) * 100)
                            )
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
                
                // ─── C. Stat Cards with Hierarchy ─────────────
                // Big Steps Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        // Accent strip
                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppTheme.healthGradient)
                            .frame(width: 5, height: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Steps")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                            Text(healthKit.todaySteps.withCommas)
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Image(systemName: "figure.walk")
                                .font(.title2)
                                .foregroundStyle(AppTheme.healthGradient)
                            Text(healthKit.todayDistance.asKilometers)
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    
                    // Steps progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 5)
                                .fill(AppTheme.healthGradient)
                                .frame(width: geo.size.width * min(stepsProgress, 1.0), height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    HStack {
                        Text("Goal: \(storage.userGoals.dailyStepGoal.withCommas)")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(AppTheme.textTertiary)
                        Spacer()
                        Text("\(Int(min(stepsProgress, 1.0) * 100))%")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(stepsProgress >= 1.0 ? AppTheme.healthGreen : AppTheme.neonCyan)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .opacity(appeared ? 1 : 0)
                
                // Two small cards side-by-side
                HStack(spacing: 12) {
                    smallStatCard(
                        icon: "flame.fill",
                        label: "Calories",
                        value: "\(healthKit.todayCalories)",
                        unit: "kcal",
                        progress: calProgress,
                        gradient: AppTheme.fitnessGradient,
                        accentColor: AppTheme.warmOrange
                    )
                    
                    smallStatCard(
                        icon: "bolt.fill",
                        label: "Active",
                        value: "\(healthKit.todayActiveMinutes)",
                        unit: "min",
                        progress: activeProgress,
                        gradient: AppTheme.studyGradient,
                        accentColor: AppTheme.studyBlue
                    )
                }
                .opacity(appeared ? 1 : 0)
                
                // ─── D. Smart Insight Card ────────────────────
                smartInsightCard(healthKit: healthKit, stepsProgress: stepsProgress, storage: storage)
                    .opacity(appeared ? 1 : 0)
                
                // ─── E. Fitness Quick Access ──────────────────
                NavigationLink(destination: FitnessHomeView()) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.fitnessGradient.opacity(0.2))
                                .frame(width: 44, height: 44)
                            Image(systemName: "dumbbell.fill")
                                .font(.title3)
                                .foregroundStyle(AppTheme.fitnessGradient)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Fitness")
                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("Exercise • Yoga • Breathing")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                            .padding(8)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Circle())
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .opacity(appeared ? 1 : 0)
                
                // Health Summary Row
                HStack(spacing: 12) {
                    healthQuickStat(icon: "bed.double.fill", value: String(format: "%.1fh", healthKit.todaySleepHours), label: "Sleep", gradient: AppTheme.sleepGradient)
                    healthQuickStat(icon: "drop.fill", value: storage.todayWater.totalML.asLiters, label: "Water", gradient: AppColors.waterGradient)
                    healthQuickStat(icon: "heart.fill", value: "😊", label: "Mood", gradient: AppTheme.mentalGradient)
                }
                .opacity(appeared ? 1 : 0)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20).padding(.top, 10)
        }
    }
    
    // MARK: - Steps (inline)
    private var stepsContent: some View {
        StepsContentView()
    }
    
    // MARK: - Water (inline)
    private var waterContent: some View {
        WaterContentView()
    }
    
    // MARK: - Helper Views
    
    private func ringLegendItem(color: Color, label: String, value: String, percent: Int) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
                HStack(spacing: 4) {
                    Text(value)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                    Text("(\(percent)%)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(color)
                }
            }
        }
    }
    
    private func smallStatCard(icon: String, label: String, value: String, unit: String, progress: Double, gradient: LinearGradient, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(gradient)
                Spacer()
                Text("\(Int(min(progress, 1.0) * 100))%")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(accentColor)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
            
            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(gradient)
                        .frame(width: geo.size.width * min(progress, 1.0), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func smartInsightCard(healthKit: HealthKitManager, stepsProgress: Double, storage: StorageManager) -> some View {
        let insight = generateInsight(healthKit: healthKit, stepsProgress: stepsProgress, storage: storage)
        
        return HStack(spacing: 12) {
            Text(insight.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text(insight.subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: insight.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).opacity(0.25)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: insight.colors.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private func generateInsight(healthKit: HealthKitManager, stepsProgress: Double, storage: StorageManager) -> InsightData {
        let stepsLeft = max(0, storage.userGoals.dailyStepGoal - healthKit.todaySteps)
        let yesterdaySteps = healthKit.yesterdaySteps
        
        if stepsProgress >= 1.0 {
            return InsightData(
                emoji: "🏆",
                title: "Step goal smashed!",
                subtitle: "You've crushed your step goal today. Keep the momentum going!",
                colors: [Color(hex: "10B981"), Color(hex: "06B6D4")]
            )
        } else if yesterdaySteps > 0 {
            let diff = healthKit.todaySteps - yesterdaySteps
            if diff > 0 {
                let pctMore = (diff * 100) / max(1, yesterdaySteps)
                return InsightData(
                    emoji: "🔥",
                    title: "You walked \(pctMore)% more than yesterday!",
                    subtitle: "\(stepsLeft.withCommas) steps left to hit your daily goal.",
                    colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")]
                )
            } else {
                return InsightData(
                    emoji: "🚀",
                    title: "\(stepsLeft.withCommas) steps to your goal",
                    subtitle: "A short walk can help you catch up. You've got this!",
                    colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")]
                )
            }
        } else if healthKit.todayCalories > 200 {
            return InsightData(
                emoji: "💪",
                title: "Already burned \(healthKit.todayCalories) kcal!",
                subtitle: "Great energy today. Keep moving!",
                colors: [Color(hex: "F59E0B"), Color(hex: "EC4899")]
            )
        } else {
            return InsightData(
                emoji: "✨",
                title: "Ready to start your day",
                subtitle: "Every step counts. Start with a short walk!",
                colors: [Color(hex: "7C3AED"), Color(hex: "A78BFA")]
            )
        }
    }
    
    private func healthQuickStat(icon: String, value: String, label: String, gradient: LinearGradient) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(gradient)
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Insight Data Model
private struct InsightData {
    let emoji: String
    let title: String
    let subtitle: String
    let colors: [Color]
}

// MARK: - Multi Ring View
struct MultiRingView: View {
    let rings: [RingData]
    let size: CGFloat
    
    @State private var animatedProgresses: [Double] = []
    
    var body: some View {
        ZStack {
            ForEach(rings.indices, id: \.self) { index in
                let ring = rings[index]
                let ringSize = size - CGFloat(index) * (ring.lineWidth + 14)
                let progress = index < animatedProgresses.count ? animatedProgresses[index] : 0
                
                ZStack {
                    // Background track
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: ring.lineWidth)
                        .frame(width: ringSize, height: ringSize)
                    
                    // Progress arc
                    Circle()
                        .trim(from: 0, to: min(progress, 1.0))
                        .stroke(
                            LinearGradient(
                                colors: ring.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: ring.lineWidth, lineCap: .round)
                        )
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: ring.gradient.first?.opacity(progress >= 1.0 ? 0.6 : 0.3) ?? .clear, radius: progress >= 1.0 ? 8 : 4)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgresses = rings.map { _ in 0.0 }
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.3)) {
                animatedProgresses = rings.map { $0.progress }
            }
        }
    }
}

// MARK: - Ring Data
struct RingData {
    let progress: Double
    let gradient: [Color]
    let lineWidth: CGFloat
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
                    stepStat(icon: "flame.fill", label: "Calories", value: "\(viewModel.todayCalories)")
                    stepStat(icon: "clock.fill", label: "Active", value: "\(viewModel.estimatedActiveMinutes)m")
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
