import SwiftUI

// MARK: - Card Flip Memory Game
// Classic card matching — 4x4 grid with 8 pairs
// Find all pairs to complete the game

struct CardFlipView: View {
    @State private var cards: [MemoryCard] = []
    @State private var firstFlipped: Int?
    @State private var secondFlipped: Int?
    @State private var matchedPairs = 0
    @State private var moves = 0
    @State private var timeElapsed = 0
    @State private var isActive = false
    @State private var isComplete = false
    @State private var isChecking = false
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let gridSize = 4
    private let totalPairs = 8
    private let cardIcons = ["star.fill", "heart.fill", "moon.fill", "sun.max.fill",
                             "bolt.fill", "flame.fill", "leaf.fill", "drop.fill"]
    private let cardColors: [Color] = [.red, .pink, .indigo, .orange,
                                        .yellow, .red, .green, .cyan]
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(hex: "1A1A2E") : Color(hex: "F0F4FF"))
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
                    .fill(AppTheme.primaryPurple.opacity(0.15))
                    .frame(width: 140, height: 140)
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.system(size: 50))
                    .foregroundStyle(AppTheme.primaryPurple)
            }
            Text("Memory Cards")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Find all 8 matching pairs\nTest your memory!")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: startGame) {
                Text("▶ Start Flipping")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(16)
                    .background(AppTheme.primaryPurple).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 40)
            
            Spacer()
            Button("Close") { dismiss() }
                .foregroundStyle(AppTheme.textTertiary).padding(.bottom, 30)
        }
    }
    
    // MARK: - Game View
    private var gameView: some View {
        VStack(spacing: 16) {
            // HUD
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill").foregroundStyle(AppTheme.neonCyan)
                    Text("\(timeElapsed)s")
                        .font(.system(.headline, design: .monospaced, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(10).glassBackground()
                
                Spacer()
                
                Text("\(matchedPairs)/\(totalPairs) pairs")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryPurple)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill").foregroundStyle(AppTheme.warmOrange)
                    Text("\(moves)")
                        .font(.system(.headline, design: .monospaced, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(10).glassBackground()
            }
            .padding(.horizontal, 20).padding(.top, 10)
            
            Spacer()
            
            // Card Grid 4x4
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize), spacing: 8) {
                ForEach(cards.indices, id: \.self) { idx in
                    cardView(index: idx)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func cardView(index: Int) -> some View {
        let card = cards[index]
        let isFlipped = card.isMatched || index == firstFlipped || index == secondFlipped
        let cellSize = (UIScreen.main.bounds.width - 72) / CGFloat(gridSize)
        
        return Button(action: {
            flipCard(index: index)
        }) {
            ZStack {
                // Back of card
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        colorScheme == .dark
                        ? LinearGradient(colors: [Color(hex: "6C3CE0"), Color(hex: "4A1D96")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color(hex: "818CF8"), Color(hex: "6366F1")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        Image(systemName: "questionmark")
                            .font(.system(size: cellSize * 0.3, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                    )
                    .opacity(isFlipped ? 0 : 1)
                    .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                
                // Front of card
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        colorScheme == .dark
                        ? Color.white.opacity(0.1)
                        : Color.white
                    )
                    .shadow(color: cardColors[card.pairIndex].opacity(0.3), radius: 8)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: cardIcons[card.pairIndex])
                                .font(.system(size: cellSize * 0.35))
                                .foregroundStyle(cardColors[card.pairIndex])
                        }
                    )
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(height: cellSize)
            .animation(.spring(response: 0.4), value: isFlipped)
        }
        .buttonStyle(.plain)
        .disabled(isChecking || card.isMatched || index == firstFlipped)
    }
    
    // MARK: - Result
    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "rectangle.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.primaryPurple)
            
            Text("All Matched!")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("\(timeElapsed)s • \(moves) moves")
                .font(.system(.title2, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.primaryPurple)
            
            let memoryScore = max(10, 100 - timeElapsed - moves)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Memory Points").foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text("+\(min(memoryScore, 100))").foregroundStyle(AppTheme.primaryPurple).fontWeight(.bold)
                }
                HStack {
                    Text("XP Earned").foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text("+\(memoryScore / 2)").foregroundStyle(AppTheme.warmOrange).fontWeight(.bold)
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
                    .background(AppTheme.primaryPurple).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 30).padding(.bottom, 40)
        }
    }
    
    // MARK: - Logic
    private func startGame() {
        // Create 8 pairs
        var deck: [MemoryCard] = []
        for i in 0..<totalPairs {
            deck.append(MemoryCard(pairIndex: i))
            deck.append(MemoryCard(pairIndex: i))
        }
        cards = deck.shuffled()
        matchedPairs = 0; moves = 0; timeElapsed = 0
        isActive = true; isComplete = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if self.isActive {
                    self.timeElapsed += 1
                }
            }
        }
    }
    
    private func flipCard(index: Int) {
        guard !isChecking else { return }
        
        if firstFlipped == nil {
            firstFlipped = index
            HapticManager.impact(.light)
        } else if secondFlipped == nil && index != firstFlipped {
            secondFlipped = index
            moves += 1
            isChecking = true
            HapticManager.impact(.light)
            
            // Check match after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                checkMatch()
            }
        }
    }
    
    private func checkMatch() {
        guard let first = firstFlipped, let second = secondFlipped else {
            isChecking = false
            return
        }
        
        if cards[first].pairIndex == cards[second].pairIndex {
            // Match!
            cards[first].isMatched = true
            cards[second].isMatched = true
            matchedPairs += 1
            HapticManager.notification(.success)
            
            if matchedPairs == totalPairs {
                endGame()
            }
        } else {
            HapticManager.notification(.error)
        }
        
        firstFlipped = nil
        secondFlipped = nil
        isChecking = false
    }
    
    private func endGame() {
        timer?.invalidate()
        timer = nil
        isActive = false
        isComplete = true
        
        let memoryScore = max(10, 100 - timeElapsed - moves)
        BrainScoreManager.shared.addMemoryPoints(min(memoryScore, 100))
        GameEngineManager.shared.awardXP(amount: memoryScore / 2, source: "Memory Cards", icon: "rectangle.on.rectangle.angled")
    }
}

// MARK: - Memory Card Model
struct MemoryCard: Identifiable {
    let id = UUID()
    let pairIndex: Int
    var isMatched = false
}
