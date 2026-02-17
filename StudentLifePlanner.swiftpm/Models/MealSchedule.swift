import Foundation

struct MealSchedule: Codable {
    var breakfastTime: Date
    var lunchTime: Date
    var dinnerTime: Date
    
    static var defaultSchedule: MealSchedule {
        let calendar = Calendar.current
        let today = Date()
        return MealSchedule(
            breakfastTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today) ?? today,
            lunchTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: today) ?? today,
            dinnerTime: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) ?? today
        )
    }
}
