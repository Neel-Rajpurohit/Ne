import SwiftUI

struct GameMenuView: View {
    @StateObject private var viewModel = GameViewModel()
    @Environment(\.dismiss) var dismiss
    var showBackButton: Bool = true
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    if showBackButton {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.top, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mind Games")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Pick a 5-minute challenge to refresh.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.primary.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    if !showBackButton {
                        // Show daily points if in tab mode
                        DailyGamePointsView()
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Game Tiles
                        VStack(spacing: 16) {
                            ForEach(GameViewModel.GameType.allCases) { gameType in
                                Button(action: { viewModel.startGame(gameType) }) {
                                    GameTileView(type: gameType)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Points Info
                        InfoCard {
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accent.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppColors.accent)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Discipline Bonus")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text("Earn +1 bonus point per game")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
        }
        .fullScreenCover(item: $viewModel.selectedGame) { gameType in
            destinationView(for: gameType)
        }
    }
    
    @ViewBuilder
    private func destinationView(for type: GameViewModel.GameType) -> some View {
        switch type {
        case .candyMatch:
            CandyStyleGameView()
        case .memoryPairs:
            MemoryGameView()
        case .mathQuick:
            MathQuickGameView()
        case .gkQuiz:
            GKQuizView()
        }
    }
}

struct DailyGamePointsView: View {
    @State private var dailyPoints = 0
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.fill")
                .foregroundColor(AppColors.accent)
            Text("\(dailyPoints)/3")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "1E293B"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.4))
                .overlay(Capsule().stroke(AppColors.accent.opacity(0.3), lineWidth: 1))
        )
        .onAppear {
            let score = GameEngineService.shared.loadGameScore()
            let today = Calendar.current.startOfDay(for: Date())
            if let lastDate = score.lastPlayedDate, Calendar.current.startOfDay(for: lastDate) == today {
                dailyPoints = score.pointsEarnedToday
            } else {
                dailyPoints = 0
            }
        }
    }
}

struct GameTileView: View {
    let type: GameViewModel.GameType
    
    var body: some View {
        InfoCard {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(type.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.title3.bold())
                        .foregroundColor(type.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Text("5 Minutes • Brain Training")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primary.opacity(0.8))
            }
        }
    }
}
