import Foundation
import HealthKit

// MARK: - HealthKit Manager
// Real HealthKit integration with mock fallback for Simulator/Preview
@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    // MARK: - Published Properties
    @Published var todaySteps: Int = 0
    @Published var todayDistance: Double = 0.0    // km
    @Published var todayCalories: Int = 0         // active kcal
    @Published var yesterdaySteps: Int = 0
    @Published var weeklySteps: [StepsData] = []
    @Published var isAuthorized: Bool = false
    @Published var authorizationDenied: Bool = false
    @Published var isUsingMockData: Bool = false
    
    private var healthStore: HKHealthStore?
    private var observerQuery: HKObserverQuery?
    
    // MARK: - Init
    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            isUsingMockData = false
        } else {
            // Simulator / Preview — use mock data
            isUsingMockData = true
            generateMockData()
        }
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        guard let healthStore = healthStore else {
            isUsingMockData = true
            generateMockData()
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned)
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            Task { @MainActor in
                guard let self = self else { return }
                if success {
                    self.isAuthorized = true
                    self.authorizationDenied = false
                    self.fetchAllData()
                    self.startObserving()
                } else {
                    self.authorizationDenied = true
                    self.isUsingMockData = true
                    self.generateMockData()
                }
            }
        }
    }
    
    // MARK: - Fetch All Data
    func fetchAllData() {
        guard healthStore != nil, !isUsingMockData else {
            generateMockData()
            return
        }
        fetchTodaySteps()
        fetchTodayDistance()
        fetchTodayCalories()
        fetchYesterdaySteps()
        fetchWeeklyData()
    }
    
    // MARK: - Today's Steps
    func fetchTodaySteps() {
        guard let healthStore = healthStore else { return }
        
        let stepsType = HKQuantityType(.stepCount)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            Task { @MainActor in
                guard let self = self else { return }
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                self.todaySteps = Int(steps)
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Today's Distance
    func fetchTodayDistance() {
        guard let healthStore = healthStore else { return }
        
        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            Task { @MainActor in
                guard let self = self else { return }
                let meters = result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                self.todayDistance = meters / 1000.0 // Convert to km
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Today's Calories
    func fetchTodayCalories() {
        guard let healthStore = healthStore else { return }
        
        let caloriesType = HKQuantityType(.activeEnergyBurned)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            Task { @MainActor in
                guard let self = self else { return }
                let kcal = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                self.todayCalories = Int(kcal)
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Yesterday's Steps (for comparison)
    func fetchYesterdaySteps() {
        guard let healthStore = healthStore else { return }
        
        let stepsType = HKQuantityType(.stepCount)
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())
        let startOfYesterday = cal.date(byAdding: .day, value: -1, to: startOfToday)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: startOfToday, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            Task { @MainActor in
                guard let self = self else { return }
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                self.yesterdaySteps = Int(steps)
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Weekly Data (last 7 days)
    func fetchWeeklyData() {
        guard let healthStore = healthStore else { return }
        
        let stepsType = HKQuantityType(.stepCount)
        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let cal = Calendar.current
        let endDate = Date()
        let startDate = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: endDate))!
        
        let interval = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Fetch steps per day
        let stepsQuery = HKStatisticsCollectionQuery(
            quantityType: stepsType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: cal.startOfDay(for: endDate),
            intervalComponents: interval
        )
        
        stepsQuery.initialResultsHandler = { [weak self] _, results, _ in
            Task { @MainActor in
                guard let self = self, let results = results else { return }
                
                var weekData: [StepsData] = []
                results.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
                    let steps = Int(stats.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    let distance = Double(steps) * 0.0007 // Approximate
                    weekData.append(StepsData(date: stats.startDate, steps: steps, distance: distance))
                }
                self.weeklySteps = weekData
            }
        }
        healthStore.execute(stepsQuery)
    }
    
    // MARK: - Real-Time Observer
    private func startObserving() {
        guard let healthStore = healthStore else { return }
        
        let stepsType = HKQuantityType(.stepCount)
        
        // Remove old observer
        if let old = observerQuery {
            healthStore.stop(old)
        }
        
        let query = HKObserverQuery(sampleType: stepsType, predicate: nil) { [weak self] _, _, _ in
            Task { @MainActor in
                self?.fetchTodaySteps()
                self?.fetchTodayDistance()
                self?.fetchTodayCalories()
            }
        }
        
        observerQuery = query
        healthStore.execute(query)
    }
    
    // MARK: - Refresh (pull-to-refresh or manual)
    func refresh() {
        if isUsingMockData {
            generateMockData()
        } else {
            fetchAllData()
        }
    }
    
    // MARK: - Mock Data (Simulator / Preview / No Permission)
    private func generateMockData() {
        let hour = Calendar.current.component(.hour, from: Date())
        let baseSteps = Int(Double(hour) / 24.0 * Double(AppConstants.defaultStepGoal) * 1.2)
        let variation = Int.random(in: -500...500)
        todaySteps = max(0, baseSteps + variation)
        todayDistance = Double(todaySteps) * 0.0007
        todayCalories = Int(Double(todaySteps) * 0.04)
        yesterdaySteps = Int.random(in: 4000...9000)
        isAuthorized = true
        
        weeklySteps = Date.lastSevenDays.map { date in
            if Calendar.current.isDateInToday(date) {
                return StepsData(date: date, steps: todaySteps, distance: todayDistance)
            } else {
                let steps = Int.random(in: 3000...12000)
                return StepsData(date: date, steps: steps, distance: Double(steps) * 0.0007)
            }
        }
    }
    
    // MARK: - Computed Properties
    var weeklyAverage: Int {
        guard !weeklySteps.isEmpty else { return 0 }
        return weeklySteps.reduce(0) { $0 + $1.steps } / weeklySteps.count
    }
    
    var weeklyTotal: Int {
        weeklySteps.reduce(0) { $0 + $1.steps }
    }
    
    var bestDay: StepsData? {
        weeklySteps.max(by: { $0.steps < $1.steps })
    }
    
    var worstDay: StepsData? {
        weeklySteps.filter { $0.steps > 0 }.min(by: { $0.steps < $1.steps })
    }
    
    var totalWeeklyDistance: Double {
        weeklySteps.reduce(0) { $0 + $1.distance }
    }
    
    /// Percentage change from yesterday
    var yesterdayComparison: Int {
        guard yesterdaySteps > 0 else { return 0 }
        return Int(Double(todaySteps - yesterdaySteps) / Double(yesterdaySteps) * 100)
    }
    
    /// Habit score: days in the week where step goal was met (0–100)
    var habitScore: Int {
        guard !weeklySteps.isEmpty else { return 0 }
        let goalMet = weeklySteps.filter { $0.steps >= AppConstants.defaultStepGoal }.count
        return (goalMet * 100) / 7
    }
}
