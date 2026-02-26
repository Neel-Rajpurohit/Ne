import Combine
import Foundation
import HealthKit

// MARK: - HealthKit Manager
// Real HealthKit integration with mock fallback for Simulator/Preview
@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    // MARK: - Published Properties
    @Published var todayDistance: Double = 0.0  // km
    @Published var todayCalories: Int = 0  // active kcal
    @Published var todaySleepHours: Double = 0.0  // hours slept last night
    @Published var todayActiveMinutes: Int = 0  // exercise minutes
    @Published var weeklyDistance: [RunData] = []
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

        // Info.plist should be configured in Package.swift. We will trust it is there.

        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.appleExerciseTime),
            HKCategoryType(.sleepAnalysis),
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) {
            [weak self] success, error in
            Task { @MainActor in
                guard let self = self else { return }
                if success {
                    self.isAuthorized = true
                    self.authorizationDenied = false
                    self.fetchAllData()
                    self.startObserving()
                } else {
                    print("HealthKit Auth Error: \(String(describing: error))")
                    self.authorizationDenied = true
                    self.isUsingMockData = false
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
        fetchTodayDistance()
        fetchTodayCalories()
        fetchTodaySleep()
        fetchTodayActiveMinutes()
        fetchWeeklyData()
    }

    // MARK: - Today's Distance
    func fetchTodayDistance() {
        guard let healthStore = healthStore else { return }

        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let restartDate =
            UserDefaults.standard.object(forKey: "appRestartDate") as? Date ?? startOfDay
        let queryStart = restartDate > startOfDay ? restartDate : startOfDay
        let predicate = HKQuery.predicateForSamples(
            withStart: queryStart, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum
        ) { [weak self] _, result, _ in
            Task { @MainActor in
                guard let self = self else { return }
                let meters = result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                self.todayDistance = meters / 1000.0  // Convert to km
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Today's Calories
    func fetchTodayCalories() {
        guard let healthStore = healthStore else { return }

        let caloriesType = HKQuantityType(.activeEnergyBurned)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum
        ) { [weak self] _, result, _ in
            Task { @MainActor in
                guard let self = self else { return }
                let kcal = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                self.todayCalories = Int(kcal)
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Weekly Data (last 7 days)
    func fetchWeeklyData() {
        guard let healthStore = healthStore else { return }

        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let cal = Calendar.current
        let endDate = Date()
        let startDate = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: endDate))!

        let interval = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate, end: endDate, options: .strictStartDate)

        let distanceQuery = HKStatisticsCollectionQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: cal.startOfDay(for: endDate),
            intervalComponents: interval
        )

        distanceQuery.initialResultsHandler = { [weak self] _, results, _ in
            Task { @MainActor in
                guard let self = self, let results = results else { return }

                var weekData: [RunData] = []
                results.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
                    let meters = stats.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                    let distance = meters / 1000.0
                    weekData.append(RunData(date: stats.startDate, distance: distance))
                }
                self.weeklyDistance = weekData
            }
        }
        healthStore.execute(distanceQuery)
    }

    // MARK: - Today's Sleep Hours
    func fetchTodaySleep() {
        guard let healthStore = healthStore else { return }

        let sleepType = HKCategoryType(.sleepAnalysis)
        let cal = Calendar.current
        // Look at sleep from last night (yesterday 6 PM to today noon)
        let startOfToday = cal.startOfDay(for: Date())
        let sleepWindowStart = cal.date(byAdding: .hour, value: -6, to: startOfToday)!  // yesterday 6 PM
        let sleepWindowEnd = cal.date(byAdding: .hour, value: 12, to: startOfToday)!  // today noon
        let predicate = HKQuery.predicateForSamples(
            withStart: sleepWindowStart, end: sleepWindowEnd, options: .strictStartDate)

        let query = HKSampleQuery(
            sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { [weak self] _, samples, _ in
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
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum
        ) { [weak self] _, result, _ in
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

        let typesToObserve: [HKSampleType] = [
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.appleExerciseTime),
            HKCategoryType(.sleepAnalysis),
        ]

        for sampleType in typesToObserve {
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) {
                [weak self] _, _, _ in
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
        let baseDistance = (Double(hour) / 24.0) * AppConstants.defaultRunGoal * 1.2
        let variation = Double.random(in: -0.5...0.5)
        todayDistance = max(0, baseDistance + variation)
        todayCalories = Int(todayDistance * 60)
        todaySleepHours = Double.random(in: 5.5...9.0)
        todayActiveMinutes = Int.random(in: 10...60)
        isAuthorized = true

        weeklyDistance = Date.lastSevenDays.map { date in
            if Calendar.current.isDateInToday(date) {
                return RunData(date: date, distance: todayDistance)
            } else {
                let dist = Double.random(in: 1.0...5.0)
                return RunData(date: date, distance: dist)
            }
        }
    }

    // MARK: - Computed Properties
    var weeklyAverage: Double {
        guard !weeklyDistance.isEmpty else { return 0 }
        return weeklyDistance.reduce(0) { $0 + $1.distance } / Double(weeklyDistance.count)
    }

    var totalWeeklyDistance: Double {
        weeklyDistance.reduce(0) { $0 + $1.distance }
    }

    var bestDay: RunData? {
        weeklyDistance.max(by: { $0.distance < $1.distance })
    }

    var worstDay: RunData? {
        weeklyDistance.filter { $0.distance > 0 }.min(by: { $0.distance < $1.distance })
    }

    /// Habit score: days in the week where run goal was met (0–100)
    var habitScore: Int {
        guard !weeklyDistance.isEmpty else { return 0 }
        let goalMet = weeklyDistance.filter { $0.distance >= AppConstants.defaultRunGoal }.count
        return (goalMet * 100) / 7
    }
}
