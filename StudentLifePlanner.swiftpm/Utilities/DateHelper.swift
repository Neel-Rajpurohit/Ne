import Foundation

struct DateHelper {
    static let calendar = Calendar.current
    
    // Check if date is today
    static func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    // Check if date is yesterday
    static func isYesterday(_ date: Date) -> Bool {
        return calendar.isDateInYesterday(date)
    }
    
    // Get start of day
    static func startOfDay(_ date: Date = Date()) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    // Get end of day
    static func endOfDay(_ date: Date = Date()) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfDay(date)) ?? date
    }
    
    // Days between two dates
    static func daysBetween(_ start: Date, _ end: Date) -> Int {
        let startDay = startOfDay(start)
        let endDay = startOfDay(end)
        let components = calendar.dateComponents([.day], from: startDay, to: endDay)
        return abs(components.day ?? 0)
    }
    
    // Format date as "MMM dd, yyyy"
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    // Format date as "EEEE, MMM dd" (e.g., "Monday, Feb 14")
    static func formatDateWithDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM dd"
        return formatter.string(from: date)
    }
    
    // Format time as "h:mm a" (e.g., "2:30 PM")
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    // Create date from hour and minute
    static func createTime(hour: Int, minute: Int) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }
    
    // Get current month dates
    static func getDaysInCurrentMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = monthInterval.start
        
        while currentDate < monthInterval.end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
    
    // Get day of week (1 = Sunday, 7 = Saturday)
    static func getDayOfWeek(_ date: Date) -> Int {
        return calendar.component(.weekday, from: date)
    }
    
    // Check if two dates are on the same day
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}
