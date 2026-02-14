import Foundation
import UserNotifications

@MainActor
class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // Request notification permission
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    // Schedule daily routine reminder
    func scheduleDailyReminder(at hour: Int, minute: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_\(hour)_\(minute)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // Schedule morning motivation
    func scheduleMorningMotivation() {
        scheduleDailyReminder(
            at: 6,
            minute: 30,
            title: "Good Morning! 🌅",
            body: "Start your day with energy! Check your routine for today."
        )
    }
    
    // Schedule study reminder
    func scheduleStudyReminder() {
        scheduleDailyReminder(
            at: 9,
            minute: 0,
            title: "Study Time 📚",
            body: "Time to focus! Start your study session."
        )
    }
    
    // Schedule evening review
    func scheduleEveningReview() {
        scheduleDailyReminder(
            at: 21,
            minute: 0,
            title: "Daily Review ⭐",
            body: "Complete your routine and earn points!"
        )
    }
    
    // Schedule custom notification
    func scheduleNotification(identifier: String, title: String, body: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // Cancel specific notification
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Setup default notifications
    func setupDefaultNotifications() {
        scheduleMorningMotivation()
        scheduleStudyReminder()
        scheduleEveningReview()
    }
}
