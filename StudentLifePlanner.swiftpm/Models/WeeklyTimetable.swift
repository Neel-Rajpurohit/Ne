import Foundation

struct DaySchedule: Codable {
    var institution: InstitutionSchedule
    var tuition: TuitionSchedule
    var extraClass: ExtraClassSchedule
    var isActive: Bool = true
}

struct WeeklyTimetable: Codable {
    var schedules: [Int: DaySchedule] // 1: Sunday ... 7: Saturday
    
    static func defaultSchedule() -> WeeklyTimetable {
        let calendar = Calendar.current
        let schoolStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let schoolEnd = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!
        
        let defaultDay = DaySchedule(
            institution: InstitutionSchedule(startTime: schoolStart, endTime: schoolEnd),
            tuition: TuitionSchedule(hasTuition: false, startTime: nil, endTime: nil),
            extraClass: ExtraClassSchedule(hasExtraClasses: false, startTime: nil, endTime: nil)
        )
        
        var weekly: [Int: DaySchedule] = [:]
        for day in 2...6 { // Mon-Fri
            weekly[day] = defaultDay
        }
        
        // Weekend optional or inactive
        var weekendDay = defaultDay
        weekendDay.isActive = false
        weekly[1] = weekendDay // Sunday
        weekly[7] = weekendDay // Saturday
        
        return WeeklyTimetable(schedules: weekly)
    }
}
