import SwiftUI

struct MemoryGameView: View {
    @StateObject private var engine = GameEngineService.shared
    @State private var cards: [MemoryCard] = []
    @State private var selectedCards: [Int] = []
    @State private var matches = 0
    @State private var isGameOver = false
    @Environment(\.dismiss) var dismiss
    
    struct MemoryCard: Identifiable {
        let id = UUID()
        let symbol: String
        let color: Color
        var isFaceUp = false
        var isMatched = false
    }
    
    let symbols = ["sun.max.fill", "moon.fill", "star.fill", "heart.fill", "bolt.fill", "flame.fill"]
    let colors: [Color] = [.orange, .purple, .yellow, .red, .blue, .red]
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Button("Exit") { dismiss() }
                        .foregroundColor(Color(hex: "1E293B"))
                        .font(.headline)
                    Spacer()
                    Text("Memory Pairs")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "1E293B"))
                    Spacer()
                    Text("Matches: \(matches)/6")
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                }
                .padding()
                
                Text("Match all pairs to refresh your focus!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                // Game Board
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index])
                            .onTapGesture {
                                flipCard(index)
                            }
                    }
                }
                .padding()
                
                Spacer()
            }
            
            if isGameOver {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Memory Sharp!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("You've matched all pairs in record time.")
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Button(action: { finishGame() }) {
                        Text("Finish & Get Point")
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
        .onAppear { setupGame() }
    }
    
    private func setupGame() {
        var newCards: [MemoryCard] = []
        for i in 0..<symbols.count {
            let card = MemoryCard(symbol: symbols[i], color: colors[i])
            newCards.append(card)
            newCards.append(card)
        }
        cards = newCards.shuffled()
    }
    
    private func flipCard(_ index: Int) {
        guard !cards[index].isFaceUp && !cards[index].isMatched && selectedCards.count < 2 else { return }
        
        withAnimation(.spring()) {
            cards[index].isFaceUp = true
        }
        selectedCards.append(index)
        
        if selectedCards.count == 2 {
            checkMatch()
        }
    }
    
    private func checkMatch() {
        let first = selectedCards[0]
        let second = selectedCards[1]
        
        if cards[first].symbol == cards[second].symbol {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    cards[first].isMatched = true
                    cards[second].isMatched = true
                    matches += 1
                    if matches == 6 {
                        isGameOver = true
                    }
                }
                selectedCards.removeAll()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    cards[first].isFaceUp = false
                    cards[second].isFaceUp = false
                }
                selectedCards.removeAll()
            }
        }
    }
    
    private func finishGame() {
        engine.awardBonusPoint()
        dismiss()
    }
}

struct CardView: View {
    let card: MemoryGameView.MemoryCard
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(card.isFaceUp || card.isMatched ? .white : Color.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            if card.isFaceUp || card.isMatched {
                Image(systemName: card.symbol)
                    .font(.largeTitle)
                    .foregroundColor(card.color)
            } else {
                Image(systemName: "questionmark")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .frame(height: 100)
        .opacity(card.isMatched ? 0.0 : 1.0)
    }
}
