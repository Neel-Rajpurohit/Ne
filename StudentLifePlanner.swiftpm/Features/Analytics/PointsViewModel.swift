import SwiftUI

@MainActor
class PointsViewModel: ObservableObject {
    @Published var points: Points = Points()
    
    func addPoints(_ amount: Int) {
        points.totalPoints += amount
        points.balance += amount
    }
}
