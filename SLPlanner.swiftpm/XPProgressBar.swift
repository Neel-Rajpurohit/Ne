import SwiftUI

// MARK: - XP Progress Bar Component
struct XPProgressBar: View {
    let profile: PlayerProfile
    @State private var animatedProgress: Double = 0
    @State private var showXPPopup = false
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Lv.\(profile.level)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.warmOrange)
                Spacer()
                Text("\(profile.currentXP) / \(profile.xpForNextLevel) XP")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppTheme.xpGradient)
                        .frame(width: max(0, geo.size.width * animatedProgress), height: 10)
                        .shadow(color: AppTheme.warmOrange.opacity(0.4), radius: 4)
                }
            }
            .frame(height: 10)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                animatedProgress = profile.levelProgress.clamped01
            }
        }
        .onChange(of: profile.currentXP) { _ in
            withAnimation(.spring(response: 0.5)) {
                animatedProgress = profile.levelProgress.clamped01
            }
        }
    }
}

// MARK: - Level Badge Component
struct LevelBadge: View {
    let level: Int
    let title: String
    @State private var isGlowing = false
    
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(RadialGradient(colors: [AppTheme.warmOrange.opacity(0.3), .clear], center: .center, startRadius: 5, endRadius: 40))
                .frame(width: 80, height: 80)
                .scaleEffect(isGlowing ? 1.2 : 0.9)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isGlowing)
            
            // Badge
            Circle()
                .fill(AppTheme.levelGradient(for: level))
                .frame(width: 60, height: 60)
                .overlay(
                    VStack(spacing: 0) {
                        Text("\(level)").font(.system(.title3, design: .rounded, weight: .black)).foregroundStyle(.white)
                    }
                )
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                .shadow(color: AppTheme.warmOrange.opacity(0.3), radius: 6)
        }
        .onAppear { isGlowing = true }
    }
}
