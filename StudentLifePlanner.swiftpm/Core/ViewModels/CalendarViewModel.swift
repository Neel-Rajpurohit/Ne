import Foundation
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date?
    @Published var daysInMonth: [Date] = []
    
    private let calendarService = CalendarService.shared
    
    init() {
        loadCurrentMonth()
    }
    
    func loadCurrentMonth() {
        daysInMonth = DateHelper.getDaysInCurrentMonth()
    }
    
    func isDayCompleted(_ date: Date) -> Bool {
        return calendarService.isDayCompleted(date)
    }
    
    func isToday(_ date: Date) -> Bool {
        return DateHelper.isToday(date)
    }
    
    func isFutureDate(_ date: Date) -> Bool {
        return date > Date()
    }
    
    func getCurrentStreak() -> Int {
        return calendarService.getCurrentStreak()
    }
    
    func getLongestStreak() -> Int {
        return calendarService.getLongestStreak()
    }
    
    func getMonthlyCompletionRate() -> Double {
        return calendarService.getMonthlyCompletionRate()
    }
    
    func getMonthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    func previousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            loadMonth(newMonth)
        }
    }
    
    func nextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            loadMonth(newMonth)
        }
    }
    
    private func loadMonth(_ date: Date) {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: date) else {
            return
        }
        
        var dates: [Date] = []
        var currentDate = monthInterval.start
        
        while currentDate < monthInterval.end {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        daysInMonth = dates
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
    }
}
