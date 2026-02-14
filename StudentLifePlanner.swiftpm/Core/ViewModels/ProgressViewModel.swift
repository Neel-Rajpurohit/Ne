import SwiftUI
import Foundation

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var totalPoints: Int = 0
    @Published var performanceLevel: String = ""
    @Published var progressPercentage: Double = 0.0
    
    init() {
        refreshProgress()
    }
    
    func refreshProgress() {
        self.totalPoints = PointsManager.shared.getTotalPoints()
        self.performanceLevel = PointsManager.shared.getPerformanceLevel()
        
        // Progress percentage relative to a goal, e.g., 500 points
        self.progressPercentage = Double(totalPoints) / 500.0
    }
}
