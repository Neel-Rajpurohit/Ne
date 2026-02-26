import Foundation
import SwiftUI

// MARK: - Event Category

enum EventCategory: String, Codable, CaseIterable, Identifiable {
    case study = "Study"
    case health = "Health"
    case specialDay = "Special Day"
    case work = "Work"
    case personal = "Personal"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .study: return "book.fill"
        case .health: return "heart.fill"
        case .specialDay: return "star.fill"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .study: return Color(hex: "3B82F6")     // Blue
        case .health: return Color(hex: "8B5CF6")    // Purple
        case .specialDay: return Color(hex: "F59E0B") // Yellow/Amber
        case .work: return Color(hex: "10B981")      // Green
        case .personal: return Color(hex: "10B981")  // Green
        }
    }
    
    var dotColor: Color { color }
}

// MARK: - Repeat Option

enum RepeatOption: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .none: return "calendar"
        case .daily: return "arrow.clockwise"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar.circle"
        case .yearly: return "calendar.badge.exclamationmark"
        }
    }
}

// MARK: - Reminder Time

enum ReminderTime: String, Codable, CaseIterable, Identifiable {
    case atTime = "At time"
    case tenMinBefore = "10 min before"
    case oneHourBefore = "1 hour before"
    case oneDayBefore = "1 day before"
    
    var id: String { rawValue }
    
    /// Offset in seconds to subtract from event time
    var offsetSeconds: TimeInterval {
        switch self {
        case .atTime: return 0
        case .tenMinBefore: return 600
        case .oneHourBefore: return 3600
        case .oneDayBefore: return 86400
        }
    }
}

// MARK: - Calendar Event

struct CalendarEvent: Codable, Identifiable {
    let id: UUID
    var title: String
    var category: EventCategory
    var date: Date            // The date (and time if not all-day)
    var isAllDay: Bool
    var repeatOption: RepeatOption
    var reminderTime: ReminderTime
    var isCompleted: Bool
    var notes: String
    
    init(
        title: String,
        category: EventCategory,
        date: Date,
        isAllDay: Bool = false,
        repeatOption: RepeatOption = .none,
        reminderTime: ReminderTime = .tenMinBefore,
        notes: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.date = date
        self.isAllDay = isAllDay
        self.repeatOption = repeatOption
        self.reminderTime = reminderTime
        self.isCompleted = false
        self.notes = notes
    }
    
    var timeString: String {
        if isAllDay { return "All Day" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
