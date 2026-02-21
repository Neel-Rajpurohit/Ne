import SwiftUI

// MARK: - Break Game Menu
struct BreakGameMenu: View {
    @State private var showMathGame = false
    @State private var showGKQuiz = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("🎮").font(.system(size: 60))
                Text("Break Time!").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                Text("Relax or play a quick game").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                
                VStack(spacing: 14) {
                    // Mind Math
                    Button(action: { showMathGame = true }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12).fill(AppTheme.warmOrange.opacity(0.15)).frame(width: 50, height: 50)
                                Image(systemName: "brain.head.profile").font(.title2).foregroundStyle(AppTheme.warmOrange)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Mind Math").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                                Text("Speed math challenge • 30s").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "play.circle.fill").font(.title2).foregroundStyle(AppTheme.warmOrange)
                        }
                        .padding(16).glassBackground()
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // GK Quiz
                    Button(action: { showGKQuiz = true }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12).fill(AppTheme.quizPink.opacity(0.15)).frame(width: 50, height: 50)
                                Image(systemName: "questionmark.circle.fill").font(.title2).foregroundStyle(AppTheme.quizPink)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("GK Quiz").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                                Text("Test your knowledge").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "play.circle.fill").font(.title2).foregroundStyle(AppTheme.quizPink)
                        }
                        .padding(16).glassBackground()
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Just Rest
                    Button(action: { dismiss() }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12).fill(AppTheme.healthGreen.opacity(0.15)).frame(width: 50, height: 50)
                                Image(systemName: "leaf.fill").font(.title2).foregroundStyle(AppTheme.healthGreen)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Just Rest").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                                Text("Take a breather ☕️").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
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
            .fullScreenCover(isPresented: $showMathGame) { MindMathGame() }
            .fullScreenCover(isPresented: $showGKQuiz) { QuizPlayView(category: nil) }
        }
    }
}
