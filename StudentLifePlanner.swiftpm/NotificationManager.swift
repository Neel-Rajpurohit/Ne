import Foundation
import UserNotifications

// MARK: - Notification Manager

@MainActor
class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Permission
    
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Schedule Event Reminder
    
    func scheduleEventReminder(_ event: CalendarEvent) {
        // Remove any existing notification for this event
        cancelNotification(id: event.id.uuidString)
        
        let content = UNMutableNotificationContent()
        content.title = event.category.icon + " " + event.title
        content.sound = .default
        
        if event.isAllDay {
            content.body = "Today is \(event.title)!"
            // Trigger at 8 AM on the event day
            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: event.date)
            dateComponents.hour = 8
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
            center.add(request)
        } else {
            // Calculate trigger time based on reminder offset
            let triggerDate = event.date.addingTimeInterval(-event.reminderTime.offsetSeconds)
            
            if event.reminderTime == .atTime {
                content.body = "\(event.title) starts now!"
            } else {
                content.body = "\(event.title) starts in \(event.reminderTime.rawValue.replacingOccurrences(of: " before", with: ""))."
            }
            
            if event.repeatOption != .none {
                // Recurring notification
                var components: Set<Calendar.Component> = []
                switch event.repeatOption {
                case .daily:
                    components = [.hour, .minute]
                case .weekly:
                    components = [.weekday, .hour, .minute]
                case .monthly:
                    components = [.day, .hour, .minute]
                case .yearly:
                    components = [.month, .day, .hour, .minute]
                case .none:
                    break
                }
                
                let dateComponents = Calendar.current.dateComponents(components, from: triggerDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
                center.add(request)
            } else {
                // One-time notification
                guard triggerDate > Date() else { return }
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
                center.add(request)
            }
        }
    }
    
    // MARK: - Smart Daily Reminder Engine (7 AM Daily)
    
    @MainActor
    func scheduleMorningSummary() {
        let id = "morning_summary"
        cancelNotification(id: id)
        
        let profile = ProfileManager.shared.profile
        let name = profile.name.isEmpty ? "Neel" : profile.name
        
        let today = Date()
        
        // Fetch events and routine for today
        let events = CalendarEventManager.shared.events(for: today)
        let routine = PlannerEngine.shared.generateRoutine(for: today, profile: profile)
        
        let filteredRoutine = routine.blocks.filter({ $0.type == .study || $0.type == .exercise })
        let totalTasks = events.count + filteredRoutine.count
        
        let content = UNMutableNotificationContent()
        content.title = "Good Morning, \(name) ☀️"
        
        if totalTasks > 0 {
            var body = "You have \(totalTasks) tasks today."
            
            // List up to 2 specific tasks
            for event in events.prefix(2) {
                body += "\n\(event.title) at \(event.timeString)."
            }
            
            if events.count < 2 {
                for block in filteredRoutine.prefix(2 - events.count) {
                    body += "\n\(block.displayTitle) at \(block.startTime)."
                }
            }
            
            content.body = body
        } else {
            content.body = "No specific tasks scheduled for today. Have a productive day!"
        }
        
        content.sound = .default
        
        // Trigger at 7 AM every day
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }
    
    // MARK: - Evening Completion Check (9 PM Daily)
    
    @MainActor
    func scheduleEveningReminder() {
        let id = "evening_pending"
        cancelNotification(id: id)
        
        let taskSet = TaskCompletionManager.shared.dailyTaskSet
        let pendingCount = taskSet.totalCount - taskSet.completedCount
        
        guard pendingCount > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Pending Tasks ⏰"
        content.body = "You still have \(pendingCount) pending task\(pendingCount == 1 ? "" : "s") today."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }
    
    // MARK: - Setup & Refresh
    
    @MainActor
    func setupDailyNotifications() {
        requestPermission()
        scheduleMorningSummary()
        scheduleEveningReminder()
    }
    
    // MARK: - Cancel
    
    func cancelNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
