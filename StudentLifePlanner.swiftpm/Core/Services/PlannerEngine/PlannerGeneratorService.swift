import Foundation

@MainActor
class PlannerGeneratorService {
    static let shared = PlannerGeneratorService()
    
    func generatePlan(for date: Date) -> DailyPlan {
        let storage = LocalStorageService.shared
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        let weeklyTimetable = storage.loadWeeklyTimetable() ?? WeeklyTimetable.defaultSchedule()
        let daySchedule = weeklyTimetable.schedules[dayOfWeek]
        
        var activities: [Activity] = []
        
        if let schedule = daySchedule, schedule.isActive {
            // 1. Add Fixed Academic Activities with Buffers
            let inst = schedule.institution
            
            // Adjust dates to match the target 'date'
            let startTime = adjustDate(inst.startTime, to: date)
            let endTime = adjustDate(inst.endTime, to: date)
            
            // Buffer Before School (1 Hour)
            if let bufferStart = calendar.date(byAdding: .minute, value: -Constants.prepBufferMinutes, to: startTime) {
                activities.append(Activity(title: "Pre-College Prep", startTime: bufferStart, endTime: startTime, type: .rest))
            }
            
            activities.append(Activity(title: "School/College", startTime: startTime, endTime: endTime, type: .school))
            
            // Buffer After School (30 Minutes)
            if let bufferEnd = calendar.date(byAdding: .minute, value: Constants.restBufferMinutes, to: endTime) {
                activities.append(Activity(title: "Post-College Rest", startTime: endTime, endTime: bufferEnd, type: .rest))
            }
            
            // Tuition
            if schedule.tuition.hasTuition, let tStart = schedule.tuition.startTime, let tEnd = schedule.tuition.endTime {
                activities.append(Activity(title: "Tuition", startTime: adjustDate(tStart, to: date), endTime: adjustDate(tEnd, to: date), type: .tuition))
            }
            
            // Extra Class
            if schedule.extraClass.hasExtraClasses, let eStart = schedule.extraClass.startTime, let eEnd = schedule.extraClass.endTime {
                activities.append(Activity(title: "Extra Class", startTime: adjustDate(eStart, to: date), endTime: adjustDate(eEnd, to: date), type: .extraClass))
            }
        }
        
        // 2. Add Meals
        if let m = storage.loadMealSchedule() {
            activities.append(Activity(title: "Breakfast", startTime: adjustDate(m.breakfastTime, to: date), endTime: calendar.date(byAdding: .minute, value: 30, to: adjustDate(m.breakfastTime, to: date))!, type: .rest))
            activities.append(Activity(title: "Lunch", startTime: adjustDate(m.lunchTime, to: date), endTime: calendar.date(byAdding: .minute, value: 45, to: adjustDate(m.lunchTime, to: date))!, type: .rest))
            activities.append(Activity(title: "Dinner", startTime: adjustDate(m.dinnerTime, to: date), endTime: calendar.date(byAdding: .minute, value: 45, to: adjustDate(m.dinnerTime, to: date))!, type: .rest))
        }
        
        // 3. Add Morning Routine (Fixed 55 mins)
        let dayStart = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: date) ?? date
        let yogaEnd = calendar.date(byAdding: .minute, value: 25, to: dayStart)!
        let exerciseEnd = calendar.date(byAdding: .minute, value: 25, to: yogaEnd)!
        let breathingEnd = calendar.date(byAdding: .minute, value: 5, to: exerciseEnd)!
        
        activities.append(Activity(title: "Morning Yoga 🧘", startTime: dayStart, endTime: yogaEnd, type: .exercise))
        activities.append(Activity(title: "Quick Exercise 🏋️", startTime: yogaEnd, endTime: exerciseEnd, type: .exercise))
        activities.append(Activity(title: "Breathing Exercise 🧘‍♂️", startTime: exerciseEnd, endTime: breathingEnd, type: .exercise))

        // 4. Sort activities by start time
        activities.sort { $0.startTime < $1.startTime }
        
        // 5. Fill the gaps
        let dayEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: date) ?? date
        
        var currentPointer = dayStart
        var generatedActivities: [Activity] = []
        
        if !activities.isEmpty {
            for fixed in activities {
                if currentPointer < fixed.startTime {
                    fillGap(from: currentPointer, to: fixed.startTime, into: &generatedActivities)
                }
                generatedActivities.append(fixed)
                // Handle possible overlap (fixed event starts before previous ends)
                currentPointer = max(currentPointer, fixed.endTime)
            }
        }
        
        if currentPointer < dayEnd {
            fillGap(from: currentPointer, to: dayEnd, into: &generatedActivities)
        }
        
        return DailyPlan(date: date, activities: generatedActivities)
    }
    
    private func fillGap(from start: Date, to end: Date, into list: inout [Activity]) {
        let duration = end.timeIntervalSince(start) / 60
        
        if duration >= 60 {
            // Long Gap: Study
            list.append(Activity(title: "Focused Study", startTime: start, endTime: end, type: .study))
        } else if duration >= 30 {
            // Medium Gap: Exercise/Yoga
            list.append(Activity(title: "Quick Wellness", startTime: start, endTime: end, type: .exercise))
        } else if duration >= 5 {
            // Short Gap: Rest (Replaced Mind Game)
            list.append(Activity(title: "Quick Rest", startTime: start, endTime: end, type: .rest))
        } else if duration > 0 {
            // Very Short Gap: Rest
            list.append(Activity(title: "Micro Rest", startTime: start, endTime: end, type: .rest))
        }
    }
    
    private var calendar: Calendar { Calendar.current }
    
    private func adjustDate(_ baseDate: Date, to targetDate: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: baseDate)
        return calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: components.second ?? 0, of: targetDate) ?? targetDate
    }
}
