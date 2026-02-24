import SwiftUI

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let achievement: Achievement
    
    @State private var isGlowing = false
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Glow effect for unlocked
                if achievement.isUnlocked {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 5,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(isGlowing ? 1.2 : 0.9)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isGlowing)
                }
                
                // Badge Circle
                Circle()
                    .fill(achievement.isUnlocked
                          ? AnyShapeStyle(AppColors.streakGradient)
                          : AnyShapeStyle(Color.white.opacity(0.1)))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: achievement.icon)
                            .font(.title2)
                            .foregroundStyle(
                                achievement.isUnlocked
                                ? .white
                                : AppColors.tertiaryText
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                achievement.isUnlocked
                                ? AppColors.streakColor.opacity(0.5)
                                : Color.white.opacity(0.1),
                                lineWidth: 2
                            )
                    )
                
                // Lock icon
                if !achievement.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(AppColors.tertiaryText)
                        .offset(x: 22, y: 22)
                }
            }
            
            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? AppColors.primaryText : AppColors.tertiaryText)
                    .multilineTextAlignment(.center)
                
                Text(achievement.subtitle)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(AppColors.tertiaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 100)
        .onAppear {
            if achievement.isUnlocked {
                isGlowing = true
            }
        }
    }
}
