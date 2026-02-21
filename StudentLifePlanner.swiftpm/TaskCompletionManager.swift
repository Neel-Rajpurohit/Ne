import SwiftUI

// MARK: - Task Completion Manager
// Centralized manager for tracking and auto-completing timetable blocks

@MainActor
class TaskCompletionManager: ObservableObject {
    static let shared = TaskCompletionManager()
    
    @Published var showMorningGreeting = false
    @Published var greetingDismissed = false
    
    private let sleepCompletedKey = "lastSleepCompletedDate"
    private let wakeCompletedKey = "lastWakeCompletedDate"
    
    private init() {
        // Reset greeting dismissed if it's a new day
        let today = Calendar.current.startOfDay(for: Date())
        if let lastWake = UserDefaults.standard.object(forKey: wakeCompletedKey) as? Date,
           Calendar.current.startOfDay(for: lastWake) == today {
            greetingDismissed = true
        }
    }
    
    // MARK: - Auto-Complete Check
    /// Call periodically to auto-complete time-based blocks
    func checkAutoComplete() {
        let planner = PlannerEngine.shared
        var changed = false
        
        for i in planner.todayRoutine.blocks.indices {
            let block = planner.todayRoutine.blocks[i]
            guard !block.isCompleted else { continue }
            
            // Auto-complete time-based blocks when their time passes
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
    /// Check if it's wake-up time and mark complete + show greeting
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
                    
                    // Auto-dismiss after 4 seconds
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
    
    // MARK: - Sleep Completion (App goes to background at night)
    func completeSleepIfNeeded() {
        let planner = PlannerEngine.shared
        let cal = Calendar.current
        let now = Date()
        let hour = cal.component(.hour, from: now)
        
        // Check if already completed sleep today
        let today = cal.startOfDay(for: now)
        if let lastSleep = UserDefaults.standard.object(forKey: sleepCompletedKey) as? Date,
           cal.startOfDay(for: lastSleep) == today {
            return
        }
        
        // If current time is during sleep hours (typically evening/night: after 8 PM or before 5 AM)
        for i in planner.todayRoutine.blocks.indices {
            let block = planner.todayRoutine.blocks[i]
            if block.type == .sleep && !block.isCompleted {
                // Complete if currently in the sleep window or past the start time
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
    
    // MARK: - App Became Active (foreground)
    func onAppBecameActive() {
        // Re-check wake-up when app comes to foreground
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        // Only show greeting once per day
        if let lastWake = UserDefaults.standard.object(forKey: wakeCompletedKey) as? Date,
           cal.startOfDay(for: lastWake) == today {
            greetingDismissed = true
        } else {
            greetingDismissed = false
        }
        
        checkWakeUp()
        checkAutoComplete()
    }
    
    // MARK: - Start Monitoring
    func startMonitoring() {
        checkWakeUp()
        checkAutoComplete()
        
        // Schedule periodic checks using Task instead of Timer
        Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60_000_000_000) // 60 seconds
                self.checkAutoComplete()
            }
        }
    }
}
