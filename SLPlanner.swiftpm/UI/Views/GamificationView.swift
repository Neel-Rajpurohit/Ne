import SwiftUI

// MARK: - Gamification View (Profile / RPG Status)
struct GamificationView: View {
    @StateObject private var gameEngine = GameEngineManager.shared
    @StateObject private var storage = StorageManager.shared
    @StateObject private var wellness = WellnessDataStore.shared
    @State private var appeared = false
    
    private var profile: UserProfile { ProfileManager.shared.profile }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // 1. Identity Card
                    identityCard
                    
                    // 2. Health Stats
                    healthStatsSection
                    
                    // 3. Achievements Grid
                    achievementsGrid
                    
                    // 4. Recent XP
                    recentXPSection
                    
                    // Analytics Link
                    NavigationLink(destination: AnalyticsView()) {
                        linkRow(icon: "chart.line.uptrend.xyaxis", label: "View Analytics", color: AppTheme.neonCyan)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Settings Link
                    NavigationLink(destination: SettingsView()) {
                        linkRow(icon: "gearshape.fill", label: "Settings", color: AppTheme.textSecondary)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20).padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
        }
    }
    
    // MARK: - 1. Identity Card
    private var identityCard: some View {
        VStack(spacing: 18) {
            HStack(spacing: 20) {
                // Profile Avatar
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppTheme.warmOrange.opacity(0.3), .clear],
                                center: .center, startRadius: 5, endRadius: 45
                            )
                        )
                        .frame(width: 90, height: 90)
                    
                    Circle()
                        .fill(AppTheme.levelGradient(for: gameEngine.profile.level))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Group {
                                if let data = profile.profileImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                } else {
                                    Text(profile.selectedCharacter)
                                        .font(.system(size: 44))
                                }
                            }
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: AppTheme.warmOrange.opacity(0.3), radius: 8)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.name.isEmpty ? "Neel Raj" : profile.name)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Level \(gameEngine.profile.level) – \(gameEngine.profile.title)")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(AppTheme.warmOrange)
                    
                    Text("Total XP: \(gameEngine.profile.totalXP)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                Spacer()
            }
            
            // XP Progress bar
            XPProgressBar(profile: gameEngine.profile)
        }
        .padding(20)
        .glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    // MARK: - 2. Health Stats
    private var healthStatsSection: some View {
        HStack(spacing: 12) {
            healthStatCard(
                icon: "figure.run",
                value: String(format: "%.1f", wellness.lifetime.totalRunKM),
                unit: "KM",
                label: "Total Run",
                color: AppTheme.healthGreen,
                gradient: AppTheme.healthGradient
            )
            
            healthStatCard(
                icon: "figure.yoga",
                value: "\(Int(wellness.lifetime.totalYogaMin))",
                unit: "Min",
                label: "Total Yoga",
                color: AppTheme.yogaTeal,
                gradient: AppTheme.yogaGradient
            )
            
            healthStatCard(
                icon: "wind",
                value: "\(wellness.lifetime.totalBreathingSessions)",
                unit: "Sessions",
                label: "Breathing",
                color: AppTheme.breathingCyan,
                gradient: AppTheme.breathingGradient
            )
        }
        .opacity(appeared ? 1 : 0)
    }
    
    private func healthStatCard(icon: String, value: String, unit: String, label: String, color: Color, gradient: LinearGradient) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(gradient)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassBackground(cornerRadius: 16)
    }
    
    // MARK: - 3. Achievements Grid
    private var achievementsGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Achievements")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                let count = storage.achievements.filter(\.isUnlocked).count
                Text("\(count)/\(storage.achievements.count)")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.warmOrange)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(storage.achievements) { achievement in
                    achievementCard(achievement)
                }
            }
        }
        .padding(20)
        .glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    private func achievementCard(_ achievement: Achievement) -> some View {
        let currentProgress = progressForAchievement(achievement)
        let progressRatio = achievement.goalValue > 0 ? min(currentProgress / achievement.goalValue, 1.0) : 0
        
        return VStack(spacing: 10) {
            ZStack {
                if achievement.isUnlocked {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.3), .clear],
                                center: .center, startRadius: 5, endRadius: 30
                            )
                        )
                        .frame(width: 56, height: 56)
                }
                
                Circle()
                    .fill(achievement.isUnlocked
                          ? AnyShapeStyle(AppColors.streakGradient)
                          : AnyShapeStyle(Color.white.opacity(0.06)))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: achievement.icon)
                            .font(.title3)
                            .foregroundStyle(achievement.isUnlocked ? .white : AppTheme.textTertiary)
                    )
                
                if !achievement.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(AppTheme.textTertiary)
                        .offset(x: 16, y: 16)
                }
            }
            
            Text(achievement.title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(achievement.isUnlocked ? .white : AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            Text(achievement.subtitle)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Progress indicator
            if !achievement.isUnlocked && achievement.goalValue > 0 {
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppTheme.warmOrange)
                                .frame(width: geo.size.width * progressRatio, height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(Int(currentProgress))/\(Int(achievement.goalValue))")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(AppTheme.warmOrange.opacity(0.8))
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(achievement.isUnlocked ? 0.06 : 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            achievement.isUnlocked ? AppColors.streakColor.opacity(0.3) : Color.white.opacity(0.06),
                            lineWidth: 1
                        )
                )
        )
        .opacity(achievement.isUnlocked ? 1 : 0.6)
    }
    
    private func progressForAchievement(_ achievement: Achievement) -> Double {
        switch achievement.category {
        case .streak:
            return Double(storage.streakData.currentStreak)
        case .running:
            return wellness.lifetime.totalRunKM
        case .yoga:
            return wellness.lifetime.totalYogaMin
        case .breathing:
            return Double(wellness.lifetime.totalBreathingSessions)
        case .master:
            if achievement.id == "master10days" {
                return Double(wellness.lifetime.totalDaysCompleted)
            } else if achievement.id == "level5" || achievement.id == "level10" {
                return Double(gameEngine.profile.level)
            }
            return 0
        case .general:
            return achievement.isUnlocked ? achievement.goalValue : 0
        }
    }
    
    // MARK: - Recent XP
    private var recentXPSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent XP")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
            
            if gameEngine.recentXP.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "star.leadinghalf.filled")
                            .font(.title)
                            .foregroundStyle(AppTheme.textTertiary)
                        Text("Complete activities to earn XP")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                ForEach(gameEngine.recentXP.prefix(8)) { event in
                    HStack(spacing: 12) {
                        Image(systemName: event.icon)
                            .foregroundStyle(AppTheme.warmOrange)
                        Text(event.source)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("+\(event.amount) XP")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(AppTheme.warmOrange)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(20)
        .glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    // MARK: - Link Row
    private func linkRow(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(label)
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(AppTheme.textTertiary)
        }
        .padding(16)
        .glassBackground()
    }
}
