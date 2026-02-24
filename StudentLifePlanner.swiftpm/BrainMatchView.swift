import SwiftUI

// MARK: - Brain Match Game
// Match-3 grid game with colored shapes — swap adjacent to match 3+
// 2-minute gameplay, tracks pattern recognition / speed score

struct BrainMatchView: View {
    @State private var grid: [[MatchCell]] = []
    @State private var selectedCell: (Int, Int)?
    @State private var score = 0
    @State private var timeLeft = 120
    @State private var isActive = false
    @State private var isComplete = false
    @State private var timer: Timer?
    @State private var comboCount = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let gridSize = 6
    private let shapes = ["circle.fill", "diamond.fill", "star.fill", "triangle.fill", "heart.fill", "square.fill"]
    private let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink]
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(hex: "1A0A2E") : Color(hex: "F8F0FF"))
                .ignoresSafeArea()
            
            if isComplete {
                resultView
            } else if isActive {
                gameView
            } else {
                startView
            }
        }
    }
    
    // MARK: - Start
    private var startView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(AppTheme.quizPink.opacity(0.15))
                    .frame(width: 140, height: 140)
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.quizPink)
            }
            Text("Brain Match")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Match 3 or more shapes\n2 minutes of pattern training")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: startGame) {
                Text("▶ Start Matching")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(16)
                    .background(AppTheme.quizPink).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 40)
            
            Spacer()
            Button("Close") { dismiss() }
                .foregroundStyle(AppTheme.textTertiary).padding(.bottom, 30)
        }
    }
    
    // MARK: - Game
    private var gameView: some View {
        VStack(spacing: 16) {
            // HUD
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(timeLeft <= 15 ? AppTheme.dangerRed : AppTheme.quizPink)
                    Text("\(timeLeft)s")
                        .font(.system(.headline, design: .monospaced, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(10).glassBackground()
                
                Spacer()
                
                if comboCount > 1 {
                    Text("Combo x\(comboCount)!")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.warmOrange)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(AppTheme.warmOrange)
                    Text("\(score)")
                        .font(.system(.headline, design: .monospaced, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(10).glassBackground()
            }
            .padding(.horizontal, 20).padding(.top, 10)
            
            Spacer()
            
            // Grid
            VStack(spacing: 4) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            cellView(row: row, col: col)
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.8))
                    .shadow(color: AppTheme.quizPink.opacity(0.1), radius: 20)
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func cellView(row: Int, col: Int) -> some View {
        let cell = grid.indices.contains(row) && grid[row].indices.contains(col) ? grid[row][col] : MatchCell(shapeIndex: 0)
        let isSelected = selectedCell?.0 == row && selectedCell?.1 == col
        let cellSize: CGFloat = (UIScreen.main.bounds.width - 80) / CGFloat(gridSize)
        
        return Button(action: {
            handleTap(row: row, col: col)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected
                        ? colors[cell.shapeIndex % colors.count].opacity(0.3)
                        : (colorScheme == .dark ? Color.white.opacity(0.08) : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? colors[cell.shapeIndex % colors.count] : Color.clear, lineWidth: 2)
                    )
                
                Image(systemName: shapes[cell.shapeIndex % shapes.count])
                    .font(.system(size: cellSize * 0.4))
                    .foregroundStyle(colors[cell.shapeIndex % colors.count])
                    .opacity(cell.isMatched ? 0 : 1)
                    .scaleEffect(cell.isMatched ? 0.3 : 1)
            }
            .frame(width: cellSize, height: cellSize)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: cell.isMatched)
    }
    
    // MARK: - Result
    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.quizPink)
            
            Text("Match Complete!")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("Score: \(score)")
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                .foregroundStyle(AppTheme.quizPink)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Speed Points").foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text("+\(min(score, 100))").foregroundStyle(AppTheme.quizPink).fontWeight(.bold)
                }
                HStack {
                    Text("XP Earned").foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text("+\(score / 2)").foregroundStyle(AppTheme.warmOrange).fontWeight(.bold)
                }
            }
            .font(.system(.subheadline, design: .rounded))
            .padding(20).glassBackground().padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(16)
                    .background(AppTheme.quizPink).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 30).padding(.bottom, 40)
        }
    }
    
    // MARK: - Logic
    private func startGame() {
        score = 0; timeLeft = 120; isActive = true; isComplete = false; comboCount = 0
        generateGrid()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if self.timeLeft > 0 {
                    self.timeLeft -= 1
                } else {
                    self.endGame()
                }
            }
        }
    }
    
    private func generateGrid() {
        grid = (0..<gridSize).map { _ in
            (0..<gridSize).map { _ in
                MatchCell(shapeIndex: Int.random(in: 0..<shapes.count))
            }
        }
        // Remove any initial matches
        resolveInitialMatches()
    }
    
    private func resolveInitialMatches() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                while hasMatchAt(row: row, col: col) {
                    grid[row][col] = MatchCell(shapeIndex: Int.random(in: 0..<shapes.count))
                }
            }
        }
    }
    
    private func hasMatchAt(row: Int, col: Int) -> Bool {
        let shape = grid[row][col].shapeIndex
        
        // Horizontal
        if col >= 2 && grid[row][col-1].shapeIndex == shape && grid[row][col-2].shapeIndex == shape {
            return true
        }
        // Vertical
        if row >= 2 && grid[row-1][col].shapeIndex == shape && grid[row-2][col].shapeIndex == shape {
            return true
        }
        return false
    }
    
    private func handleTap(row: Int, col: Int) {
        guard isActive else { return }
        
        if let selected = selectedCell {
            // Check if adjacent
            let dr = abs(selected.0 - row)
            let dc = abs(selected.1 - col)
            
            if (dr == 1 && dc == 0) || (dr == 0 && dc == 1) {
                // Swap
                let temp = grid[selected.0][selected.1]
                grid[selected.0][selected.1] = grid[row][col]
                grid[row][col] = temp
                
                // Check for matches after swap
                let matches = findAllMatches()
                if matches.isEmpty {
                    // Swap back
                    let temp2 = grid[selected.0][selected.1]
                    grid[selected.0][selected.1] = grid[row][col]
                    grid[row][col] = temp2
                    HapticManager.notification(.error)
                } else {
                    comboCount = 0
                    clearMatches(matches)
                }
                selectedCell = nil
            } else {
                selectedCell = (row, col)
                HapticManager.impact(.light)
            }
        } else {
            selectedCell = (row, col)
            HapticManager.impact(.light)
        }
    }
    
    private func findAllMatches() -> Set<String> {
        var matched = Set<String>()
        
        // Horizontal matches
        for row in 0..<gridSize {
            for col in 0..<(gridSize - 2) {
                if grid[row][col].shapeIndex == grid[row][col+1].shapeIndex &&
                   grid[row][col].shapeIndex == grid[row][col+2].shapeIndex {
                    matched.insert("\(row),\(col)")
                    matched.insert("\(row),\(col+1)")
                    matched.insert("\(row),\(col+2)")
                }
            }
        }
        
        // Vertical matches
        for row in 0..<(gridSize - 2) {
            for col in 0..<gridSize {
                if grid[row][col].shapeIndex == grid[row+1][col].shapeIndex &&
                   grid[row][col].shapeIndex == grid[row+2][col].shapeIndex {
                    matched.insert("\(row),\(col)")
                    matched.insert("\(row+1),\(col)")
                    matched.insert("\(row+2),\(col)")
                }
            }
        }
        
        return matched
    }
    
    private func clearMatches(_ matches: Set<String>) {
        comboCount += 1
        score += matches.count * 10 * comboCount
        HapticManager.notification(.success)
        
        // Mark matched cells
        for key in matches {
            let parts = key.split(separator: ",").compactMap { Int($0) }
            if parts.count == 2 {
                grid[parts[0]][parts[1]].isMatched = true
            }
        }
        
        // Drop new shapes after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dropAndRefill()
            
            // Check for cascading matches
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let newMatches = findAllMatches()
                if !newMatches.isEmpty {
                    clearMatches(newMatches) // cascade
                }
            }
        }
    }
    
    private func dropAndRefill() {
        for col in 0..<gridSize {
            // Remove matched cells and drop
            var column = (0..<gridSize).map { grid[$0][col] }
            column.removeAll { $0.isMatched }
            
            // Fill from top
            while column.count < gridSize {
                column.insert(MatchCell(shapeIndex: Int.random(in: 0..<shapes.count)), at: 0)
            }
            
            for row in 0..<gridSize {
                grid[row][col] = column[row]
            }
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        timer = nil
        isActive = false
        isComplete = true
        
        BrainScoreManager.shared.addSpeedPoints(min(score, 100))
        GameEngineManager.shared.awardXP(amount: score / 2, source: "Brain Match", icon: "square.grid.3x3.fill")
    }
}

// MARK: - Match Cell Model
struct MatchCell: Identifiable {
    let id = UUID()
    var shapeIndex: Int
    var isMatched = false
}
