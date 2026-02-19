import SwiftUI

struct CandyStyleGameView: View {
    @StateObject private var engine = GameEngineService.shared
    @State private var grid: [[GameTile]] = []
    @State private var score = 0
    @State private var moves = 20
    @State private var isGameOver = false
    @Environment(\.dismiss) var dismiss
    
    struct GameTile: Identifiable, Equatable {
        let id = UUID()
        var color: Color
        var type: TileType
        
        enum TileType: Int, CaseIterable {
            case circle, square, triangle, diamond
            
            var icon: String {
                switch self {
                case .circle: return "circle.fill"
                case .square: return "square.fill"
                case .triangle: return "triangle.fill"
                case .diamond: return "diamond.fill"
                }
            }
        }
    }
    
    let colors: [Color] = [.pink, .cyan, .yellow, .green, .purple]
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button("Exit") { dismiss() }
                        .foregroundColor(AppColors.textPrimary)
                        .font(.headline)
                    Spacer()
                    VStack {
                        Text("Candy Match")
                            .font(.headline.bold())
                        Text("\(moves) Moves Left")
                            .font(.caption.bold())
                    }
                    .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                }
                .padding()
                
                // Game Board
                VStack(spacing: 8) {
                    ForEach(0..<grid.count, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(0..<grid[row].count, id: \.self) { col in
                                TileItemView(tile: grid[row][col])
                                    .onTapGesture {
                                        handleTap(row: row, col: col)
                                    }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .padding()
                
                Text("Tap tiles to match colors & clear the board!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
            }
            
            if isGameOver {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Out of Moves!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    VStack(spacing: 10) {
                        Text("Final Score")
                            .font(.headline)
                        Text("\(score)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    
                    Button(action: { finishGame() }) {
                        Text("Collect Bonus & Exit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(AppColors.primary)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .onAppear { setupGrid() }
    }
    
    private func setupGrid() {
        grid = (0..<6).map { _ in
            (0..<6).map { _ in
                let type = GameTile.TileType.allCases.randomElement()!
                return GameTile(color: colors.randomElement()!, type: type)
            }
        }
    }
    
    private func handleTap(row: Int, col: Int) {
        guard moves > 0 else { return }
        
        let color = grid[row][col].color
        var matches: [(Int, Int)] = []
        findMatches(row: row, col: col, color: color, found: &matches)
        
        if matches.count >= 2 {
            withAnimation {
                for (r, c) in matches {
                    grid[r][c].color = colors.randomElement()!
                    grid[r][c].type = GameTile.TileType.allCases.randomElement()!
                }
                score += matches.count * 10
                moves -= 1
                if moves == 0 {
                    isGameOver = true
                }
            }
        }
    }
    
    private func findMatches(row: Int, col: Int, color: Color, found: inout [(Int, Int)]) {
        guard row >= 0 && row < 6 && col >= 0 && col < 6 else { return }
        guard grid[row][col].color == color && !found.contains(where: { $0.0 == row && $0.1 == col }) else { return }
        
        found.append((row, col))
        
        findMatches(row: row - 1, col: col, color: color, found: &found)
        findMatches(row: row + 1, col: col, color: color, found: &found)
        findMatches(row: row, col: col - 1, color: color, found: &found)
        findMatches(row: row, col: col + 1, color: color, found: &found)
    }
    
    private func finishGame() {
        engine.awardBonusPoint()
        dismiss()
    }
}

struct TileItemView: View {
    let tile: CandyStyleGameView.GameTile
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tile.color.opacity(0.8))
            
            Image(systemName: tile.type.icon)
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 20))
        }
        .frame(width: 45, height: 45)
    }
}
