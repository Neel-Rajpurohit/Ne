import Foundation

@MainActor
class PlannerGeneratorService {
    static let shared = PlannerGeneratorService()
    
    func generatePlan(for date: Date) -> DailyPlan {
        let storage = LocalStorageService.shared
        let institution = storage.loadInstitutionSchedule()
        let tuition = storage.loadTuitionSchedule()
        let extra = storage.loadExtraClassSchedule()
        let meals = storage.loadMealSchedule()
        
        var activities: [Activity] = []
        
        // 1. Add Fixed Academic Activities with Buffers
        if let inst = institution {
            // Buffer Before School (1 Hour)
            if let bufferStart = calendar.date(byAdding: .minute, value: -Constants.prepBufferMinutes, to: inst.startTime) {
                activities.append(Activity(title: "Pre-College Prep", startTime: bufferStart, endTime: inst.startTime, type: .rest))
            }
            
            activities.append(Activity(title: "School/College", startTime: inst.startTime, endTime: inst.endTime, type: .school))
            
            // Buffer After School (30 Minutes)
            if let bufferEnd = calendar.date(byAdding: .minute, value: Constants.restBufferMinutes, to: inst.endTime) {
                activities.append(Activity(title: "Post-College Rest", startTime: inst.endTime, endTime: bufferEnd, type: .rest))
            }
        }
        
        if let tuit = tuition, tuit.hasTuition, let start = tuit.startTime, let end = tuit.endTime {
            activities.append(Activity(title: "Tuition", startTime: start, endTime: end, type: .tuition))
        }
        
        if let ext = extra, ext.hasExtraClasses, let start = ext.startTime, let end = ext.endTime {
            activities.append(Activity(title: "Extra Class", startTime: start, endTime: end, type: .extraClass))
        }
        
        // 2. Add Meals
        if let m = meals {
            activities.append(Activity(title: "Breakfast", startTime: m.breakfastTime, endTime: calendar.date(byAdding: .minute, value: 30, to: m.breakfastTime)!, type: .rest))
            activities.append(Activity(title: "Lunch", startTime: m.lunchTime, endTime: calendar.date(byAdding: .minute, value: 45, to: m.lunchTime)!, type: .rest))
            activities.append(Activity(title: "Dinner", startTime: m.dinnerTime, endTime: calendar.date(byAdding: .minute, value: 45, to: m.dinnerTime)!, type: .rest))
        }
        
        // 3. Sort activities by start time
        activities.sort { $0.startTime < $1.startTime }
        
        // 4. Fill the gaps
        let calendar = Calendar.current
        let dayStart = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: date) ?? date
        let dayEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: date) ?? date
        
        var currentPointer = dayStart
        var generatedActivities: [Activity] = []
        
        if !activities.isEmpty {
            for fixed in activities {
                if currentPointer < fixed.startTime {
                    fillGap(from: currentPointer, to: fixed.startTime, into: &generatedActivities)
                }
                generatedActivities.append(fixed)
                currentPointer = fixed.endTime
            }
        }
        
        if currentPointer < dayEnd {
            fillGap(from: currentPointer, to: dayEnd, into: &generatedActivities)
        }
        
        return DailyPlan(date: date, activities: generatedActivities)
    }
    
    private func fillGap(from start: Date, to end: Date, into list: inout [Activity]) {
        let duration = end.timeIntervalSince(start)
        let minutes = Int(duration / 60)
        
        var current = start
        
        if minutes >= 30 {
            // If gap is large, add a mix
            if minutes >= 60 {
                // Add Exercise/Yoga if it's the first gap or morning
                list.append(Activity(title: "Wellness Session", startTime: current, endTime: calendar.date(byAdding: .minute, value: 30, to: current)!, type: .exercise))
                current = calendar.date(byAdding: .minute, value: 30, to: current)!
            }
            
            // Add Study Sessions in remaining time
            while current < end {
                let remaining = Int(end.timeIntervalSince(current) / 60)
                if remaining >= 30 {
                    list.append(Activity(title: "Deep Study", startTime: current, endTime: calendar.date(byAdding: .minute, value: 25, to: current)!, type: .study))
                    current = calendar.date(byAdding: .minute, value: 25, to: current)!
                    
                    list.append(Activity(title: "Short Break", startTime: current, endTime: calendar.date(byAdding: .minute, value: 5, to: current)!, type: .rest))
                    current = calendar.date(byAdding: .minute, value: 5, to: current)!
                } else {
                    list.append(Activity(title: "Rest/Breathing", startTime: current, endTime: end, type: .breathing))
                    current = end
                }
            }
        } else if minutes > 0 {
            list.append(Activity(title: "Rest", startTime: start, endTime: end, type: .rest))
        }
    }
    
    private var calendar: Calendar { Calendar.current }
}
