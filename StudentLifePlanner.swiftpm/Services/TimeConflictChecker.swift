import Foundation

struct TimeConflictChecker {
    static func hasConflict(_ start1: Date, _ end1: Date, _ start2: Date, _ end2: Date) -> Bool {
        return (start1 < end2) && (start2 < end1)
    }
    
    static func isWithinSchedule(_ date: Date, scheduleStart: Date, scheduleEnd: Date) -> Bool {
        return date >= scheduleStart && date <= scheduleEnd
    }
}
