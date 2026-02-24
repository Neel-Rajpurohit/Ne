import Foundation
import SwiftUI

// MARK: - Calendar Event Manager

@MainActor
class CalendarEventManager: ObservableObject {
    static let shared = CalendarEventManager()
    
    @Published var events: [CalendarEvent] = []
    
    private let storageKey = "calendarEvents"
    
    private init() {
        load()
    }
    
    // MARK: - CRUD
    
    func addEvent(_ event: CalendarEvent) {
        events.append(event)
        save()
        NotificationManager.shared.scheduleEventReminder(event)
    }
    
    func deleteEvent(id: UUID) {
        events.removeAll { $0.id == id }
        save()
        NotificationManager.shared.cancelNotification(id: id.uuidString)
    }
    
    func toggleComplete(id: UUID) {
        if let idx = events.firstIndex(where: { $0.id == id }) {
            events[idx].isCompleted.toggle()
            save()
        }
    }
    
    func updateEvent(_ event: CalendarEvent) {
        if let idx = events.firstIndex(where: { $0.id == event.id }) {
            events[idx] = event
            save()
            NotificationManager.shared.cancelNotification(id: event.id.uuidString)
            NotificationManager.shared.scheduleEventReminder(event)
        }
    }
    
    // MARK: - Query
    
    /// Get all events for a specific date (including expanded recurring events)
    func events(for date: Date) -> [CalendarEvent] {
        let cal = Calendar.current
        var result: [CalendarEvent] = []
        
        for event in events {
            if event.repeatOption == .none {
                // One-time event — check if same day
                if cal.isDate(event.date, inSameDayAs: date) {
                    result.append(event)
                }
            } else {
                // Recurring — check if the date matches the recurrence pattern
                if matchesRecurrence(event: event, on: date) {
                    // Create a virtual occurrence with the target date's time
                    var occurrence = event
                    let timeComponents = cal.dateComponents([.hour, .minute], from: event.date)
                    if let targetDate = cal.date(bySettingHour: timeComponents.hour ?? 0,
                                                  minute: timeComponents.minute ?? 0,
                                                  second: 0, of: date) {
                        occurrence.date = targetDate
                    }
                    result.append(occurrence)
                }
            }
        }
        
        // Sort by time (all-day first, then by time)
        result.sort { a, b in
            if a.isAllDay && !b.isAllDay { return true }
            if !a.isAllDay && b.isAllDay { return false }
            return a.date < b.date
        }
        
        return result
    }
    
    /// Check if a date has any events (for dot indicators)
    func hasEvents(on date: Date) -> Bool {
        !events(for: date).isEmpty
    }
    
    /// Get unique categories with events on a date (for colored dots)
    func eventCategories(on date: Date) -> [EventCategory] {
        let evts = events(for: date)
        let categories = Set(evts.map { $0.category })
        return Array(categories).sorted { $0.rawValue < $1.rawValue }
    }
    
    /// Count of pending (not completed) events for today
    var pendingTodayCount: Int {
        events(for: Date()).filter { !$0.isCompleted }.count
    }
    
    // MARK: - Recurrence Logic
    
    private func matchesRecurrence(event: CalendarEvent, on date: Date) -> Bool {
        let cal = Calendar.current
        
        // Event must have started on or before the target date
        guard date >= cal.startOfDay(for: event.date) else { return false }
        
        switch event.repeatOption {
        case .none:
            return cal.isDate(event.date, inSameDayAs: date)
            
        case .daily:
            return true // Every day after start date
            
        case .weekly:
            let eventWeekday = cal.component(.weekday, from: event.date)
            let targetWeekday = cal.component(.weekday, from: date)
            return eventWeekday == targetWeekday
            
        case .monthly:
            let eventDay = cal.component(.day, from: event.date)
            let targetDay = cal.component(.day, from: date)
            return eventDay == targetDay
            
        case .yearly:
            let eventComponents = cal.dateComponents([.month, .day], from: event.date)
            let targetComponents = cal.dateComponents([.month, .day], from: date)
            return eventComponents.month == targetComponents.month &&
                   eventComponents.day == targetComponents.day
        }
    }
    
    // MARK: - Persistence
    
    private func save() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CalendarEvent].self, from: data) {
            events = decoded
        }
    }
}
