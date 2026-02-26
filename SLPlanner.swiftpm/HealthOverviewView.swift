import SwiftUI

// MARK: - Health Overview View (Wellness Redesign)
struct HealthOverviewView: View {
    @StateObject private var wellness = WellnessDataStore.shared
    @StateObject private var storage = StorageManager.shared
    @State private var appeared = false
    @State private var showBreathing = false
    @State private var showYoga = false

    private var profile: UserProfile { ProfileManager.shared.profile }
    private var name: String { profile.name.isEmpty ? "Student" : profile.name }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                // ─── 1. Greeting ─────────────────────
                greetingCard

                // ─── 2. Daily Wellness % ─────────────
                wellnessCard

                // ─── 3. Water ─────────────────────────
                waterCard

                // ─── 4. Running ───────────────────────
                runningCard

                // ─── 5. Yoga ──────────────────────────
                yogaCard

                // ─── 6. Breathing ─────────────────────
                breathingCard

                // ─── 7. Weekly Summary ────────────────
                weeklySummaryCard

            }
            .padding(.horizontal, 20).padding(.top, 10)
        }
        .background(Color.clear)
        .onAppear {
            withAnimation(.spring(response: 0.6)) { appeared = true }
            wellness.checkDayReset()
            wellness.syncWater(storage.todayWater.totalML)
            NotificationManager.shared.setupHealthNotifications()
        }
        .fullScreenCover(isPresented: $showBreathing) {
            BreathingView()
        }
        .fullScreenCover(isPresented: $showYoga) {
            YogaListView()
        }
    }

    // MARK: - 1. Greeting Card
    private var greetingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(GreetingHelper.greeting())
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text("Hey \(name)! 👋")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            Text("Small habits create strong futures.")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.neonCyan)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppTheme.healthGreen.opacity(0.3),
                                    AppTheme.neonCyan.opacity(0.1),
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ), lineWidth: 1
                        )
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    // MARK: - 2. Daily Wellness Card
    private var wellnessCard: some View {
        let isRunComplete =
            wellness.today.runComplete
            || (wellness.today.runKM + HealthKitManager.shared.todayDistance)
                >= wellness.today.runGoal
        let completed = [
            wellness.today.waterComplete, isRunComplete, wellness.today.yogaComplete,
            wellness.today.breathingComplete,
        ].filter { $0 }.count
        let pct = completed * 25

        return VStack(spacing: 16) {
            Text("Daily Wellness")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)

            Text("\(pct)%")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(
                    pct >= 100 ? AppTheme.healthGreen : pct >= 50 ? AppTheme.warmOrange : .white
                )

            Text("\(completed) of 4 goals completed")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            // 4 mini indicators
            HStack(spacing: 12) {
                wellnessIndicator(
                    icon: "drop.fill", done: wellness.today.waterComplete,
                    color: AppColors.waterColor)
                wellnessIndicator(
                    icon: "figure.run", done: isRunComplete,
                    color: AppTheme.healthGreen)
                wellnessIndicator(
                    icon: "figure.yoga", done: wellness.today.yogaComplete, color: AppTheme.yogaTeal
                )
                wellnessIndicator(
                    icon: "wind", done: wellness.today.breathingComplete,
                    color: AppTheme.breathingCyan)
            }

            // Progress bar
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
                        .frame(width: geo.size.width * min(Double(pct) / 100.0, 1.0), height: 8)
                        .shadow(color: AppTheme.neonCyan.opacity(0.5), radius: 4)
                }
            }
            .frame(height: 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
    }

    private func wellnessIndicator(icon: String, done: Bool, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(done ? color.opacity(0.2) : Color.white.opacity(0.06))
                .frame(width: 44, height: 44)
            Image(systemName: done ? "checkmark.circle.fill" : icon)
                .font(.title3)
                .foregroundStyle(done ? color : AppTheme.textTertiary)
        }
    }

    // MARK: - 3. Water Card
    private var waterCard: some View {
        let progress = wellness.today.waterProgress
        let goal = wellness.today.waterGoal
        let current = wellness.today.waterML

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "drop.fill").foregroundStyle(AppColors.waterGradient)
                Text("Daily Water Intake")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                if wellness.today.waterComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.healthGreen)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", current / 1000))
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text("/ \(String(format: "%.1f", goal / 1000)) L")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            progressBar(progress: progress, gradient: AppColors.waterGradient)

            // Quick add buttons
            HStack(spacing: 10) {
                quickAddButton(label: "+250 ml", color: AppColors.waterColor) {
                    storage.addWater(250)
                    wellness.syncWater(storage.todayWater.totalML)
                    HapticManager.impact(.light)
                }
                quickAddButton(label: "+500 ml", color: AppColors.waterColor) {
                    storage.addWater(500)
                    wellness.syncWater(storage.todayWater.totalML)
                    HapticManager.impact(.light)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
    }

    private var runningCard: some View {
        let goal = wellness.today.runGoal
        let current = wellness.today.runKM + HealthKitManager.shared.todayDistance
        let progress = goal > 0 ? min(current / goal, 1.0) : 0
        let isComplete = current >= goal

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "figure.run").foregroundStyle(AppTheme.healthGradient)
                Text("Daily Run Goal")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.healthGreen)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", current))
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text("/ \(String(format: "%.1f", goal)) KM")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            progressBar(progress: progress, gradient: AppTheme.healthGradient)

            HStack(spacing: 10) {
                quickAddButton(label: "+0.5 KM", color: AppTheme.healthGreen) {
                    wellness.addRun(0.5)
                    HapticManager.impact(.light)
                }
                quickAddButton(label: "+1 KM", color: AppTheme.healthGreen) {
                    wellness.addRun(1.0)
                    HapticManager.impact(.light)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - 5. Yoga Card
    private var yogaCard: some View {
        let progress = wellness.today.yogaProgress
        let goal = wellness.today.yogaGoal
        let current = wellness.today.yogaMin

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "figure.yoga").foregroundStyle(AppTheme.yogaGradient)
                Text("Daily Yoga")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                if wellness.today.yogaComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.healthGreen)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(exactTimeFormatter(minutes: current))
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text("/ \(Int(goal)) min")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            progressBar(progress: progress, gradient: AppTheme.yogaGradient)

            HStack(spacing: 10) {
                Button(action: { showYoga = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "list.bullet")
                        Text("Poses")
                    }
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.yogaTeal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.yogaTeal.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - 6. Breathing Card
    private var breathingCard: some View {
        let progress = wellness.today.breathingProgress
        let goal = wellness.today.breathingGoal
        let current = wellness.today.breathingMin

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "wind").foregroundStyle(AppTheme.breathingGradient)
                Text("Daily Breathing")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                if wellness.today.breathingComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.healthGreen)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(exactTimeFormatter(minutes: current))
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text("/ \(Int(goal)) min")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            progressBar(progress: progress, gradient: AppTheme.breathingGradient)

            HStack(spacing: 10) {
                Button(action: { showBreathing = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lungs.fill")
                        Text("Start Session")
                    }
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.breathingCyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.breathingCyan.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - 7. Weekly Summary
    private var weeklySummaryCard: some View {
        let data = wellness.weeklyWellness
        let labels = weekdayLabels()

        return VStack(alignment: .leading, spacing: 14) {
            Text("Weekly Wellness")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data.indices, id: \.self) { idx in
                    VStack(spacing: 6) {
                        Text("\(data[idx])%")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(
                                data[idx] >= 100 ? AppTheme.healthGreen : AppTheme.textSecondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                data[idx] >= 100
                                    ? AnyShapeStyle(AppTheme.healthGradient)
                                    : data[idx] > 0
                                        ? AnyShapeStyle(AppTheme.neonCyan.opacity(0.4))
                                        : AnyShapeStyle(Color.white.opacity(0.08))
                            )
                            .frame(height: max(6, CGFloat(data[idx]) * 1.2))

                        Text(idx < labels.count ? labels[idx] : "")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)

            // Average
            let avg = data.isEmpty ? 0 : data.reduce(0, +) / max(data.count, 1)
            HStack {
                Text("Weekly Average")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Text("\(avg)%")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.neonCyan)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - Helpers
    private func progressBar(progress: Double, gradient: LinearGradient) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 5)
                    .fill(gradient)
                    .frame(width: geo.size.width * min(progress, 1.0), height: 6)
                    .shadow(color: Color.white.opacity(0.2), radius: 4)
            }
        }
        .frame(height: 6)
    }

    private func quickAddButton(label: String, color: Color, action: @escaping () -> Void)
        -> some View
    {
        Button(action: action) {
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func weekdayLabels() -> [String] {
        let cal = Calendar.current
        return (0..<7).reversed().map { offset in
            guard let date = cal.date(byAdding: .day, value: -offset, to: Date()) else { return "" }
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return String(formatter.string(from: date).prefix(1))
        }
    }

    private func exactTimeFormatter(minutes: Double) -> String {
        let totalSeconds = Int(minutes * 60)
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        if m == 0 {
            return "\(s) sec"
        } else if s == 0 {
            return "\(m) min"
        } else {
            return "\(m) min \(s) sec"
        }
    }
}
