import SwiftUI

// MARK: - Task Completion Manager
// Centralized manager for daily tasks, health auto-checks, manual completion, XP, streaks, and resets

@MainActor
class TaskCompletionManager: ObservableObject {
    static let shared = TaskCompletionManager()
    
    // MARK: - Published Properties
    @Published var dailyTaskSet: DailyTaskSet = .empty(for: Date())
    @Published var showConfetti: Bool = false
    @Published var lastCompletedTask: DailyTask?
    @Published var stepReminderMessage: String?
    @Published var showMorningGreeting = false
    @Published var greetingDismissed = false
    
    // Routine block completion (existing)
    private let sleepCompletedKey = "lastSleepCompletedDate"
    private let wakeCompletedKey = "lastWakeCompletedDate"
    private let dailyTasksKey = "dailyTasks"
    private let lastTaskDateKey = "lastTaskDate"
    
    private init() {
        // Reset greeting dismissed if it's a new day
        let today = Calendar.current.startOfDay(for: Date())
        if let lastWake = UserDefaults.standard.object(forKey: wakeCompletedKey) as? Date,
           Calendar.current.startOfDay(for: lastWake) == today {
            greetingDismissed = true
        }
        
        // Load or generate daily tasks
        loadOrGenerateDailyTasks()
    }
    
    // MARK: - Daily Task Generation
    func loadOrGenerateDailyTasks() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if we have tasks for today
        if let lastDate = UserDefaults.standard.object(forKey: lastTaskDateKey) as? Date,
           Calendar.current.isDate(lastDate, inSameDayAs: today),
           let data = UserDefaults.standard.data(forKey: dailyTasksKey),
           let saved = try? JSONDecoder().decode(DailyTaskSet.self, from: data) {
            dailyTaskSet = saved
        } else {
            // New day — generate fresh tasks
            generateDefaultTasks()
        }
    }
    
    func generateDefaultTasks() {
        let profile = ProfileManager.shared.profile
        var tasks: [DailyTask] = []
        
        // === AUTOMATIC (Health) TASKS ===
        tasks.append(.create(title: "Step Goal", category: .steps, goalValue: Double(profile.stepGoal)))
        tasks.append(.create(title: "Water Goal", category: .water, goalValue: profile.waterGoal))
        tasks.append(.create(title: "Sleep Goal", category: .sleep, goalValue: 8.0))
        tasks.append(.create(title: "Active Minutes", category: .activeMinutes, goalValue: 30.0))
        
        // === MANUAL TASKS ===
        tasks.append(.create(title: "Study Session", category: .study, goalValue: Double(profile.recommendedStudyMinutes)))
        tasks.append(.create(title: "Homework Complete", category: .homework, goalValue: 1.0))
        
        dailyTaskSet = DailyTaskSet(date: Date(), tasks: tasks)
        saveDailyTasks()
    }
    
    // MARK: - Health Task Auto-Check
    /// Called by HealthKit observer and periodic timer. Reads current health data and auto-completes tasks.
    func checkHealthTasks() {
        let health = HealthKitManager.shared
        let storage = StorageManager.shared
        var changed = false
        
        for i in dailyTaskSet.tasks.indices {
            guard dailyTaskSet.tasks[i].type == .auto && !dailyTaskSet.tasks[i].isCompleted else { continue }
            
            switch dailyTaskSet.tasks[i].category {
            case .steps:
                let steps = Double(health.todaySteps)
                if dailyTaskSet.tasks[i].currentValue != steps {
                    dailyTaskSet.tasks[i].currentValue = steps
                    changed = true
                }
                if steps >= dailyTaskSet.tasks[i].goalValue {
                    markTaskCompleted(at: i)
                    changed = true
                }
                
            case .water:
                let water = storage.todayWater.totalML
                if dailyTaskSet.tasks[i].currentValue != water {
                    dailyTaskSet.tasks[i].currentValue = water
                    changed = true
                }
                if water >= dailyTaskSet.tasks[i].goalValue {
                    markTaskCompleted(at: i)
                    changed = true
                }
                
            case .sleep:
                let sleep = health.todaySleepHours
                if dailyTaskSet.tasks[i].currentValue != sleep {
                    dailyTaskSet.tasks[i].currentValue = sleep
                    changed = true
                }
                if sleep >= dailyTaskSet.tasks[i].goalValue {
                    markTaskCompleted(at: i)
                    changed = true
                }
                
            case .activeMinutes:
                let minutes = Double(health.todayActiveMinutes)
                if dailyTaskSet.tasks[i].currentValue != minutes {
                    dailyTaskSet.tasks[i].currentValue = minutes
                    changed = true
                }
                if minutes >= dailyTaskSet.tasks[i].goalValue {
                    markTaskCompleted(at: i)
                    changed = true
                }
                
            case .running:
                let distance = health.todayDistance
                if dailyTaskSet.tasks[i].currentValue != distance {
                    dailyTaskSet.tasks[i].currentValue = distance
                    changed = true
                }
                if distance >= dailyTaskSet.tasks[i].goalValue {
                    markTaskCompleted(at: i)
                    changed = true
                }
                
            default:
                break
            }
        }
        
        if changed {
            saveDailyTasks()
        }
        
        // Smart Step Reminder (after 5 PM)
        updateStepReminder()
    }
    
    private func updateStepReminder() {
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour >= 17 else {
            stepReminderMessage = nil
            return
        }
        
        if let stepTask = dailyTaskSet.tasks.first(where: { $0.category == .steps && !$0.isCompleted }) {
            let remaining = Int(stepTask.goalValue - stepTask.currentValue)
            if remaining > 0 {
                stepReminderMessage = "\(remaining.formatted()) steps left to reach your goal! 🏃"
            } else {
                stepReminderMessage = nil
            }
        } else {
            stepReminderMessage = nil
        }
    }
    
    // MARK: - Manual Task Completion
    /// User taps "Mark Complete" — only allowed for manual, non-timer tasks
    func completeManualTask(id: UUID) {
        guard let idx = dailyTaskSet.tasks.firstIndex(where: { $0.id == id }) else { return }
        let task = dailyTaskSet.tasks[idx]
        
        // Anti-cheat: only manual tasks can be manually completed
        guard task.type == .manual && !task.isCompleted else { return }
        
        dailyTaskSet.tasks[idx].currentValue = dailyTaskSet.tasks[idx].goalValue
        markTaskCompleted(at: idx)
        saveDailyTasks()
    }
    
    // MARK: - Timer Task Completion
    /// For study/meditation/gym tasks that require a timer to run for the full duration
    func completeTimerTask(id: UUID, elapsedMinutes: Double) {
        guard let idx = dailyTaskSet.tasks.firstIndex(where: { $0.id == id }) else { return }
        let task = dailyTaskSet.tasks[idx]
        
        guard task.type == .manual && task.needsTimer && !task.isCompleted else { return }
        
        dailyTaskSet.tasks[idx].currentValue = elapsedMinutes
        
        if elapsedMinutes >= task.goalValue {
            markTaskCompleted(at: idx)
        }
        
        saveDailyTasks()
    }
    
    // MARK: - Add Custom Task
    func addCustomTask(title: String, category: TaskCategory, goalValue: Double) {
        let task = DailyTask.create(title: title, category: category, goalValue: goalValue)
        dailyTaskSet.tasks.append(task)
        saveDailyTasks()
    }
    
    // MARK: - Remove Custom Task
    func removeTask(id: UUID) {
        dailyTaskSet.tasks.removeAll { $0.id == id }
        saveDailyTasks()
    }
    
    // MARK: - Core Completion Logic
    private func markTaskCompleted(at index: Int) {
        guard !dailyTaskSet.tasks[index].isCompleted else { return }
        
        dailyTaskSet.tasks[index].status = .completed
        dailyTaskSet.tasks[index].completedAt = Date()
        
        let task = dailyTaskSet.tasks[index]
        lastCompletedTask = task
        
        // Award XP
        GameEngineManager.shared.awardXP(
            amount: task.rewardXP,
            source: task.title,
            icon: task.category.icon
        )
        
        // Update streak if all tasks completed
        if dailyTaskSet.completedCount == dailyTaskSet.totalCount {
            StorageManager.shared.recordDailyGoalMet()
        }
        
        // Trigger confetti
        showConfetti = true
        HapticManager.notification(.success)
        
        // Auto-hide confetti
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            showConfetti = false
        }
        
        saveDailyTasks()
    }
    
    // MARK: - Daily Reset
    /// Check if day has changed and reset tasks
    func checkDailyReset() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastDate = UserDefaults.standard.object(forKey: lastTaskDateKey) as? Date,
           !Calendar.current.isDate(lastDate, inSameDayAs: today) {
            // New day detected — reset!
            generateDefaultTasks()
        }
    }
    
    // MARK: - Persistence
    private func saveDailyTasks() {
        if let data = try? JSONEncoder().encode(dailyTaskSet) {
            UserDefaults.standard.set(data, forKey: dailyTasksKey)
            UserDefaults.standard.set(Date(), forKey: lastTaskDateKey)
            
            // Also save per-date history for analytics lookups
            let dateKey = historyKey(for: dailyTaskSet.date)
            UserDefaults.standard.set(data, forKey: dateKey)
        }
    }
    
    private func historyKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "dailyTasks_\(formatter.string(from: date))"
    }
    
    // MARK: - Analytics
    var completionRate: Int { dailyTaskSet.completionPercent }
    
    func consistencyScore() -> Int {
        // Check last 7 days of task data for consistency
        let cal = Calendar.current
        var daysWithGoalMet = 0
        for dayOffset in 0..<7 {
            let date = cal.date(byAdding: .day, value: -dayOffset, to: Date())!
            if dayOffset == 0 {
                // Use live data for today
                if dailyTaskSet.completionRate >= 0.8 { daysWithGoalMet += 1 }
            } else {
                let key = historyKey(for: date)
                if let data = UserDefaults.standard.data(forKey: key),
                   let set = try? JSONDecoder().decode(DailyTaskSet.self, from: data),
                   set.completionRate >= 0.8 {
                    daysWithGoalMet += 1
                }
            }
        }
        return (daysWithGoalMet * 100) / 7
    }
    
    func performanceTrend() -> PerformanceTrend {
        let cal = Calendar.current
        var recentRates: [Double] = []
        for dayOffset in 0..<7 {
            let date = cal.date(byAdding: .day, value: -dayOffset, to: Date())!
            if dayOffset == 0 {
                recentRates.append(dailyTaskSet.completionRate)
            } else {
                let key = historyKey(for: date)
                if let data = UserDefaults.standard.data(forKey: key),
                   let set = try? JSONDecoder().decode(DailyTaskSet.self, from: data) {
                    recentRates.append(set.completionRate)
                }
            }
        }
        guard recentRates.count >= 3 else { return .stable }
        let recent = recentRates.prefix(3).reduce(0, +) / 3.0
        let older = recentRates.suffix(from: min(3, recentRates.count)).reduce(0, +) / max(1.0, Double(recentRates.count - 3))
        if recent > older + 0.1 { return .improving }
        if recent < older - 0.1 { return .declining }
        return .stable
    }
    
    // MARK: - Routine Block Auto-Complete (existing functionality)
    func checkAutoComplete() {
        let planner = PlannerEngine.shared
        var changed = false
        
        for i in planner.todayRoutine.blocks.indices {
            let block = planner.todayRoutine.blocks[i]
            guard !block.isCompleted else { continue }
            
            if block.type.autoCompletes && block.hasTimePassed {
                planner.todayRoutine.blocks[i].isCompleted = true
                changed = true
            }
        }
        
        if changed {
            planner.objectWillChange.send()
        }
    }
    
    // MARK: - Wake Up
    func checkWakeUp() {
        let planner = PlannerEngine.shared
        guard !greetingDismissed else { return }
        
        for i in planner.todayRoutine.blocks.indices {
            let block = planner.todayRoutine.blocks[i]
            if block.type == .wakeUp && !block.isCompleted {
                if block.isCurrentlyActive || block.hasTimePassed {
                    planner.todayRoutine.blocks[i].isCompleted = true
                    planner.objectWillChange.send()
                    
                    showMorningGreeting = true
                    UserDefaults.standard.set(Date(), forKey: wakeCompletedKey)
                    
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 4_000_000_000)
                        withAnimation(.spring(response: 0.4)) {
                            self.showMorningGreeting = false
                            self.greetingDismissed = true
                        }
                    }
                    
                    HapticManager.notification(.success)
                }
                break
            }
        }
    }
    
    // MARK: - Exercise Completion
    func completeExercise() {
        let planner = PlannerEngine.shared
        for i in planner.todayRoutine.blocks.indices {
            if planner.todayRoutine.blocks[i].type == .exercise && !planner.todayRoutine.blocks[i].isCompleted {
                planner.todayRoutine.blocks[i].isCompleted = true
                planner.objectWillChange.send()
                break
            }
        }
    }
    
    // MARK: - Study Completion
    func completeStudy(blockId: UUID) {
        let planner = PlannerEngine.shared
        if let idx = planner.todayRoutine.blocks.firstIndex(where: { $0.id == blockId }) {
            planner.todayRoutine.blocks[idx].isCompleted = true
            planner.objectWillChange.send()
        }
    }
    
    // MARK: - Sleep Completion
    func completeSleepIfNeeded() {
        let planner = PlannerEngine.shared
        let cal = Calendar.current
        let now = Date()
        let hour = cal.component(.hour, from: now)
        
        let today = cal.startOfDay(for: now)
        if let lastSleep = UserDefaults.standard.object(forKey: sleepCompletedKey) as? Date,
           cal.startOfDay(for: lastSleep) == today {
            return
        }
        
        for i in planner.todayRoutine.blocks.indices {
            let block = planner.todayRoutine.blocks[i]
            if block.type == .sleep && !block.isCompleted {
                let startMins = block.startHour * 60 + block.startMinute
                let nowMins = hour * 60 + cal.component(.minute, from: now)
                
                if nowMins >= startMins || hour < 6 {
                    planner.todayRoutine.blocks[i].isCompleted = true
                    planner.objectWillChange.send()
                    UserDefaults.standard.set(now, forKey: sleepCompletedKey)
                }
                break
            }
        }
    }
    
    // MARK: - App Lifecycle
    func onAppBecameActive() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        if let lastWake = UserDefaults.standard.object(forKey: wakeCompletedKey) as? Date,
           cal.startOfDay(for: lastWake) == today {
            greetingDismissed = true
        } else {
            greetingDismissed = false
        }
        
        checkWakeUp()
        checkAutoComplete()
        checkDailyReset()
        checkHealthTasks()
    }
    
    // MARK: - Start Monitoring
    func startMonitoring() {
        checkWakeUp()
        checkAutoComplete()
        checkHealthTasks()
        
        // Periodic checks every 60 seconds
        Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                self.checkAutoComplete()
                self.checkHealthTasks()
                self.checkDailyReset()
            }
        }
    }
}
