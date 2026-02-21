import Foundation

// MARK: - HealthKit Manager (Mock for Playground)
@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    @Published var todaySteps: Int = 0
    @Published var todayDistance: Double = 0.0 // km
    @Published var weeklySteps: [StepsData] = []
    @Published var isAuthorized: Bool = false
    
    private init() {
        generateMockData()
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        // In a real app, this would request HealthKit authorization
        // For Playground, we simulate it
        isAuthorized = true
        generateMockData()
    }
    
    // MARK: - Fetch Today's Data
    func fetchTodaySteps() {
        // Simulate fetching with slight randomization based on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        let baseSteps = Int(Double(hour) / 24.0 * Double(AppConstants.defaultStepGoal) * 1.2)
        let variation = Int.random(in: -500...500)
        todaySteps = max(0, baseSteps + variation)
        todayDistance = Double(todaySteps) * 0.0007 // ~0.7m per step
    }
    
    // MARK: - Fetch Weekly Data
    func fetchWeeklyData() {
        weeklySteps = Date.lastSevenDays.map { date in
            if Calendar.current.isDateInToday(date) {
                return StepsData(date: date, steps: todaySteps, distance: todayDistance)
            } else {
                let steps = Int.random(in: 3000...12000)
                let distance = Double(steps) * 0.0007
                return StepsData(date: date, steps: steps, distance: distance)
            }
        }
    }
    
    // MARK: - Generate Mock Data
    private func generateMockData() {
        fetchTodaySteps()
        fetchWeeklyData()
        isAuthorized = true
    }
    
    // MARK: - Refresh
    func refresh() {
        fetchTodaySteps()
        fetchWeeklyData()
    }
    
    // MARK: - Computed Properties
    var weeklyAverage: Int {
        guard !weeklySteps.isEmpty else { return 0 }
        let total = weeklySteps.reduce(0) { $0 + $1.steps }
        return total / weeklySteps.count
    }
    
    var weeklyTotal: Int {
        weeklySteps.reduce(0) { $0 + $1.steps }
    }
    
    var bestDay: StepsData? {
        weeklySteps.max(by: { $0.steps < $1.steps })
    }
    
    var totalWeeklyDistance: Double {
        weeklySteps.reduce(0) { $0 + $1.distance }
    }
}
