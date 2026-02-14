import Foundation

class RoutineGenerator {
    
    // Generate routine with timetable awareness
    static func generateRoutine(for age: Int, educationLevel: String, timetable: Timetable? = nil) -> [RoutineTask] {
        var tasks: [RoutineTask] = []
        
        // Get today's timetable slots
        let todaySlots = timetable?.getSlotsForToday() ?? []
        
        // Morning routine
        tasks.append(RoutineTask(title: "Wake up & Morning Prayer", time: "06:00 AM", category: .relaxation))
        tasks.append(RoutineTask(title: "Morning Yoga & Exercise", time: "06:30 AM", category: .exercise))
        tasks.append(RoutineTask(title: "Healthy Breakfast", time: "07:30 AM", category: .meal))
        
        // Add timetable-based slots (school/college/tuition)
        for slot in todaySlots {
            let timeStr = DateHelper.formatTime(slot.startTime)
            tasks.append(RoutineTask(
                title: "\(slot.subject) at \(slot.location)",
                time: timeStr,
                category: .study
            ))
        }
        
        // Smart study session insertion in free time
        if todaySlots.isEmpty {
            // No timetable - use default study sessions
            tasks.append(RoutineTask(title: "Priority Study Session", time: "08:30 AM", category: .study))
            tasks.append(RoutineTask(title: "Study Session 2", time: "02:00 PM", category: .study))
        } else {
            // Find free time slots and insert study sessions
            let freeSlots = findFreeTimeSlots(timetableSlots: todaySlots)
            for (index, slot) in freeSlots.enumerated() {
                let timeStr = DateHelper.formatTime(slot.start)
                tasks.append(RoutineTask(
                    title: "Study Session \(index + 1)",
                    time: timeStr,
                    category: .study
                ))
            }
        }
        
        // Mid-day
        if !hasTaskNear(tasks: tasks, hour: 11) {
            tasks.append(RoutineTask(title: "Short Break", time: "11:00 AM", category: .relaxation))
        }
        tasks.append(RoutineTask(title: "Lunch", time: "01:00 PM", category: .meal))
        
        // Afternoon
        tasks.append(RoutineTask(title: "Evening Snack & Tea", time: "04:30 PM", category: .meal))
        
        // Evening
        tasks.append(RoutineTask(title: "Physical Activity/Walk", time: "05:30 PM", category: .exercise))
        tasks.append(RoutineTask(title: "Dinner", time: "08:00 PM", category: .meal))
        
        // Night
        tasks.append(RoutineTask(title: "Review & Planning", time: "09:00 PM", category: .study))
        tasks.append(RoutineTask(title: "Relaxation/Breathing", time: "09:30 PM", category: .relaxation))
        
        // Adjust sleep time based on age
        let sleepTime = getSleepTime(for: age)
        tasks.append(RoutineTask(title: "Sleep", time: sleepTime, category: .sleep))
        
        // Sort tasks by time
        return tasks.sorted { timeToMinutes($0.time) < timeToMinutes($1.time) }
    }
    
    // Find free time slots between timetable commitments
    private static func findFreeTimeSlots(timetableSlots: [TimeSlot]) -> [(start: Date, end: Date)] {
        var freeSlots: [(start: Date, end: Date)] = []
        
        let sortedSlots = timetableSlots.sorted { $0.startTime < $1.startTime }
        
        // Morning free time (8 AM - first slot)
        let morningStart = DateHelper.createTime(hour: 8, minute: 0)
        if let firstSlot = sortedSlots.first {
            let gap = DateHelper.daysBetween(morningStart, firstSlot.startTime)
            if gap > 0 && firstSlot.startTime.timeIntervalSince(morningStart) > 3600 { // At least 1 hour
                freeSlots.append((morningStart, firstSlot.startTime))
            }
        }
        
        // Between slots
        for i in 0..<sortedSlots.count - 1 {
            let currentEnd = sortedSlots[i].endTime
            let nextStart = sortedSlots[i + 1].startTime
            
            let gap = nextStart.timeIntervalSince(currentEnd)
            if gap > 3600 { // At least 1 hour free
                freeSlots.append((currentEnd, nextStart))
            }
        }
        
        // Evening free time (after last slot - before 8 PM)
        let eveningEnd = DateHelper.createTime(hour: 20, minute: 0)
        if let lastSlot = sortedSlots.last {
            let gap = eveningEnd.timeIntervalSince(lastSlot.endTime)
            if gap > 3600 {
                freeSlots.append((lastSlot.endTime, eveningEnd))
            }
        }
        
        return freeSlots.filter { $0.end.timeIntervalSince($0.start) >= 1800 } // At least 30 min
    }
    
    // Check if there's already a task near this hour
    private static func hasTaskNear(tasks: [RoutineTask], hour: Int) -> Bool {
        let targetMinutes = hour * 60
        return tasks.contains { task in
            let taskMinutes = timeToMinutes(task.time)
            return abs(taskMinutes - targetMinutes) < 60 // Within 1 hour
        }
    }
    
    // Convert time string to minutes for sorting
    private static func timeToMinutes(_ time: String) -> Int {
        let components = time.components(separatedBy: " ")
        guard components.count == 2 else { return 0 }
        
        let timeComponents = components[0].components(separatedBy: ":")
        guard timeComponents.count == 2,
              let hours = Int(timeComponents[0]),
              let minutes = Int(timeComponents[1]) else {
            return 0
        }
        
        var totalMinutes = hours * 60 + minutes
        
        // Handle PM times
        if components[1] == "PM" && hours != 12 {
            totalMinutes += 12 * 60
        } else if components[1] == "AM" && hours == 12 {
            totalMinutes -= 12 * 60
        }
        
        return totalMinutes
    }
    
    // Get recommended sleep time based on age
    private static func getSleepTime(for age: Int) -> String {
        if age < 18 {
            return "10:00 PM" // Students need more sleep
        } else if age < 25 {
            return "10:30 PM"
        } else {
            return "11:00 PM"
        }
    }
}
