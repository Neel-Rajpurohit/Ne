import Foundation

extension Date {
    /// Returns formatted date string like "Feb 20, 2026"
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: self)
    }
    
    /// Returns day name like "Mon", "Tue"
    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    /// Returns single letter day like "M", "T", "W"
    var singleLetterDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: self)
    }
    
    /// Returns full day name like "Monday"
    var fullDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    /// Returns "Today", "Yesterday", or the formatted date
    var relativeLabel: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInYesterday(self) { return "Yesterday" }
        return formattedDate
    }
    
    /// Start of the current day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Date N days ago
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    /// Check if same day as another date
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    /// Get the last 7 days including today
    static var lastSevenDays: [Date] {
        (0..<7).reversed().map { Date().daysAgo($0) }
    }
    
    /// Greeting-style date like "Friday, Feb 20"
    var greetingDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: self)
    }
}
