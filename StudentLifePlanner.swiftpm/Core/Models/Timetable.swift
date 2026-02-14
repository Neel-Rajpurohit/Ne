import Foundation

enum DayOfWeek: String, Codable, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    static func fromDate(_ date: Date) -> DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: date)
        // weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}

struct TimeSlot: Identifiable, Codable {
    let id: UUID
    let day: DayOfWeek
    let startTime: Date
    let endTime: Date
    let subject: String
    let location: String // e.g., "School", "College", "Tuition"
    
    init(day: DayOfWeek, startTime: Date, endTime: Date, subject: String, location: String) {
        self.id = UUID()
        self.day = day
        self.startTime = startTime
        self.endTime = endTime
        self.subject = subject
        self.location = location
    }
    
    func conflictsWith(_ other: TimeSlot) -> Bool {
        guard self.day == other.day else { return false }
        
        // Check if time ranges overlap
        return (self.startTime < other.endTime && self.endTime > other.startTime)
    }
}

struct Timetable: Codable {
    var timeSlots: [TimeSlot]
    
    init(timeSlots: [TimeSlot] = []) {
        self.timeSlots = timeSlots
    }
    
    func getSlotsForDay(_ day: DayOfWeek) -> [TimeSlot] {
        return timeSlots.filter { $0.day == day }.sorted { $0.startTime < $1.startTime }
    }
    
    func getSlotsForToday() -> [TimeSlot] {
        let today = DayOfWeek.fromDate(Date())
        return getSlotsForDay(today)
    }
    
    func hasConflicts() -> Bool {
        for i in 0..<timeSlots.count {
            for j in (i+1)..<timeSlots.count {
                if timeSlots[i].conflictsWith(timeSlots[j]) {
                    return true
                }
            }
        }
        return false
    }
}
