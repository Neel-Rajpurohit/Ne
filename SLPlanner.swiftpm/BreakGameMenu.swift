import SwiftUI

// MARK: - Break Game Menu
// Shows during Pomodoro breaks — offers 2 brain games
struct BreakGameMenu: View {
    @State private var showMatch = false
    @State private var showCards = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("🎮").font(.system(size: 60))
                Text("Refresh Your Brain!")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Pick a quick brain game")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                
                VStack(spacing: 14) {
                    
                    // Brain Match
                    Button(action: { showMatch = true }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.quizPink.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "square.grid.3x3.fill")
                                    .font(.title2)
                                    .foregroundStyle(AppTheme.quizPink)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Brain Match")
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Match 3 shapes • 2min")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundStyle(AppTheme.quizPink)
                        }
                        .padding(16).glassBackground()
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Memory Cards
                    Button(action: { showCards = true }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.primaryPurple.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "rectangle.on.rectangle.angled")
                                    .font(.title2)
                                    .foregroundStyle(AppTheme.primaryPurple)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Memory Cards")
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Find matching pairs")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundStyle(AppTheme.primaryPurple)
                        }
                        .padding(16).glassBackground()
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Just Rest
                    Button(action: { dismiss() }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.healthGreen.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "leaf.fill")
                                    .font(.title2)
                                    .foregroundStyle(AppTheme.healthGreen)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Just Rest")
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Take a breather ☕️")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(16).glassBackground()
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 30)
            .background(AppTheme.mainGradient.ignoresSafeArea())

            .fullScreenCover(isPresented: $showMatch) { BrainMatchView() }
            .fullScreenCover(isPresented: $showCards) { CardFlipView() }
        }
    }
}
