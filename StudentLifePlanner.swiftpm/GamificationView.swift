import SwiftUI

// MARK: - Gamification View (Profile / RPG Status)
struct GamificationView: View {
    @StateObject private var gameEngine = GameEngineManager.shared
    @StateObject private var storage = StorageManager.shared
    @State private var appeared = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Player Card
                    playerCard
                    
                    // Quick Stats
                    statsGrid
                    
                    // Achievements
                    achievementsSection
                    
                    // Recent XP
                    recentXPSection
                    
                    // Analytics Link
                    NavigationLink(destination: AnalyticsView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "chart.line.uptrend.xyaxis").font(.title3).foregroundStyle(AppTheme.neonCyan)
                            Text("View Analytics").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(AppTheme.textTertiary)
                        }
                        .padding(16).glassBackground()
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Settings Link
                    NavigationLink(destination: SettingsView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "gearshape.fill").font(.title3).foregroundStyle(AppTheme.textSecondary)
                            Text("Settings").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
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
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
        }
    }
    
    // MARK: - Player Card
    private var playerCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                LevelBadge(level: gameEngine.profile.level, title: gameEngine.profile.title)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(gameEngine.profile.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Level \(gameEngine.profile.level)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("Total XP: \(gameEngine.profile.totalXP)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppTheme.warmOrange)
                }
                Spacer()
            }
            
            XPProgressBar(profile: gameEngine.profile)
        }
        .padding(20).glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCell(icon: "flame.fill", value: "\(storage.streakData.currentStreak)", label: "Streak", color: AppTheme.warmOrange)
            statCell(icon: "trophy.fill", value: "\(storage.achievements.filter(\.isUnlocked).count)", label: "Badges", color: AppTheme.warmOrange)
            statCell(icon: "brain.head.profile", value: "\(QuizManager.shared.totalQuizzesTaken)", label: "Quizzes", color: AppTheme.quizPink)
        }
        .opacity(appeared ? 1 : 0)
    }
    
    private func statCell(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16).glassBackground(cornerRadius: 16)
    }
    
    // MARK: - Achievements
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                Spacer()
                let count = storage.achievements.filter(\.isUnlocked).count
                Text("\(count)/\(storage.achievements.count)").font(.system(.caption, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.warmOrange)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(storage.achievements) { ach in
                        AchievementBadge(achievement: ach)
                    }
                }
            }
        }
        .padding(20).glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    // MARK: - Recent XP
    private var recentXPSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent XP").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
            
            if gameEngine.recentXP.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "star.leadinghalf.filled").font(.title).foregroundStyle(AppTheme.textTertiary)
                        Text("Complete activities to earn XP").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                    }.padding(.vertical, 16)
                    Spacer()
                }
            } else {
                ForEach(gameEngine.recentXP.prefix(8)) { event in
                    HStack(spacing: 12) {
                        Image(systemName: event.icon).foregroundStyle(AppTheme.warmOrange)
                        Text(event.source).font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text("+\(event.amount) XP").font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.warmOrange)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(20).glassBackground()
        .opacity(appeared ? 1 : 0)
    }
}
