import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published var selectedGame: GameType?
    @Published var isGameOver: Bool = false
    @Published var score: Int = 0
    
    enum GameType: String, CaseIterable, Identifiable {
        case candyMatch = "Candy Match"
        case memoryPairs = "Memory Pairs"
        case mathQuick = "Math Quick"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .candyMatch: return "circle.grid.3x3.fill"
            case .memoryPairs: return "square.grid.2x2"
            case .mathQuick: return "divide.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .candyMatch: return .pink
            case .memoryPairs: return .purple
            case .mathQuick: return .orange
            }
        }
    }
    
    func startGame(_ type: GameType) {
        selectedGame = type
        isGameOver = false
        score = 0
    }
}
