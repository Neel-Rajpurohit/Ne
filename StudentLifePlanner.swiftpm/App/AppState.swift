import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var currentDailyPlan: DailyPlan?
    @Published var points: Points = Points()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    static let shared = AppState()
    
    private init() {}
    
    func loadInitialData() {
        // Shared logic to load data from LocalStorageService
    }
}
