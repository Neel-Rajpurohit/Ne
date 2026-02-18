import SwiftUI

class HealthViewModel: ObservableObject {
    @Published var wellnessActivities: [WellnessActivity] = []
    
    func logActivity(_ activity: WellnessActivity) {
        // Logic to log health activity
    }
}
