import Foundation
import HealthKit
import Combine

// MARK: - HealthKit Manager
// Real HealthKit integration with mock fallback for Simulator/Preview
@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    // MARK: - Published Properties
    @Published var todaySteps: Int = 0
    @Published var todayDistance: Double = 0.0    // km
    @Published var todayCalories: Int = 0         // active kcal
    @Published var todaySleepHours: Double = 0.0  // hours slept last night
    @Published var todayActiveMinutes: Int = 0    // exercise minutes
    @Published var yesterdaySteps: Int = 0
    @Published var weeklySteps: [StepsData] = []
    @Published var isAuthorized: Bool = false
    @Published var authorizationDenied: Bool = false
    @Published var isUsingMockData: Bool = false
    
    private var healthStore: HKHealthStore?
    private var observerQueries: [HKObserverQuery] = []
    
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
        // Guard: skip real HealthKit in Preview or if plist key is missing
        guard let healthStore = healthStore else {
            isUsingMockData = true
            generateMockData()
            return
        }
        
        // Check that the required privacy description exists in Info.plist
        // Without it, HealthKit will throw an NSInvalidArgumentException
        guard Bundle.main.object(forInfoDictionaryKey: "NSHealthShareUsageDescription") != nil else {
            isUsingMockData = true
            generateMockData()
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.appleExerciseTime),
            HKCategoryType(.sleepAnalysis)
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
        fetchTodaySleep()
        fetchTodayActiveMinutes()
        fetchYesterdaySteps()
        fetchWeeklyData()
    }
    
    // MARK: - Today's Steps
    func fetchTodaySteps() {
        guard let healthStore = healthStore else { return }
        
        let stepsType = HKQuantityType(.stepCount)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let restartDate = UserDefaults.standard.object(forKey: "appRestartDate") as? Date ?? startOfDay
        let queryStart = restartDate > startOfDay ? restartDate : startOfDay
        let predicate = HKQuery.predicateForSamples(withStart: queryStart, end: Date(), options: .strictStartDate)
        
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
        let restartDate = UserDefaults.standard.object(forKey: "appRestartDate") as? Date ?? startOfDay
        let queryStart = restartDate > startOfDay ? restartDate : startOfDay
        let predicate = HKQuery.predicateForSamples(withStart: queryStart, end: Date(), options: .strictStartDate)
        
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
    
    // MARK: - Today's Sleep Hours
    func fetchTodaySleep() {
        guard let healthStore = healthStore else { return }
        
        let sleepType = HKCategoryType(.sleepAnalysis)
        let cal = Calendar.current
        // Look at sleep from last night (yesterday 6 PM to today noon)
        let startOfToday = cal.startOfDay(for: Date())
        let sleepWindowStart = cal.date(byAdding: .hour, value: -6, to: startOfToday)! // yesterday 6 PM
        let sleepWindowEnd = cal.date(byAdding: .hour, value: 12, to: startOfToday)!   // today noon
        let predicate = HKQuery.predicateForSamples(withStart: sleepWindowStart, end: sleepWindowEnd, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, _ in
            Task { @MainActor in
                guard let self = self else { return }
                var totalSeconds: Double = 0
                if let categorySamples = samples as? [HKCategorySample] {
                    for sample in categorySamples {
                        // Count asleep states (inBed, asleepCore, asleepDeep, asleepREM, asleepUnspecified)
                        let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)
                        if value != .inBed {
                            totalSeconds += sample.endDate.timeIntervalSince(sample.startDate)
                        }
                    }
                }
                self.todaySleepHours = totalSeconds / 3600.0
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Today's Active Minutes
    func fetchTodayActiveMinutes() {
        guard let healthStore = healthStore else { return }
        
        let exerciseType = HKQuantityType(.appleExerciseTime)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            Task { @MainActor in
                guard let self = self else { return }
                let minutes = result?.sumQuantity()?.doubleValue(for: .minute()) ?? 0
                self.todayActiveMinutes = Int(minutes)
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Real-Time Observer
    private func startObserving() {
        guard let healthStore = healthStore else { return }
        
        // Stop any existing observers
        for query in observerQueries {
            healthStore.stop(query)
        }
        observerQueries.removeAll()
        
        // Types to observe: steps, calories, exercise time, sleep
        let typesToObserve: [HKSampleType] = [
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.appleExerciseTime),
            HKCategoryType(.sleepAnalysis)
        ]
        
        for sampleType in typesToObserve {
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] _, _, _ in
                Task { @MainActor in
                    self?.fetchAllData()
                    // Notify task system to re-check health goals
                    TaskCompletionManager.shared.checkHealthTasks()
                }
            }
            observerQueries.append(query)
            healthStore.execute(query)
        }
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
        todaySleepHours = Double.random(in: 5.5...9.0)
        todayActiveMinutes = Int.random(in: 10...60)
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
