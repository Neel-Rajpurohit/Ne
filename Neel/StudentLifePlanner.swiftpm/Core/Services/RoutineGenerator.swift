import Foundation

class RoutineGenerator {
    static func generateRoutine(for age: Int, educationLevel: String) -> [RoutineTask] {
        var tasks: [RoutineTask] = []
        
        // Morning
        tasks.append(RoutineTask(title: "Wake up & Morning Prayer", time: "06:00 AM", category: .relaxation))
        tasks.append(RoutineTask(title: "Morning Yoga & Exercise", time: "06:30 AM", category: .exercise))
        tasks.append(RoutineTask(title: "Healthy Breakfast", time: "07:30 AM", category: .meal))
        
        // Study Session 1
        tasks.append(RoutineTask(title: "Priority Study Session", time: "08:30 AM", category: .study))
        
        // Mid-day
        tasks.append(RoutineTask(title: "Short Break", time: "11:00 AM", category: .relaxation))
        tasks.append(RoutineTask(title: "Lunch", time: "01:00 PM", category: .meal))
        
        // Afternoon
        tasks.append(RoutineTask(title: "Study Session 2", time: "02:00 PM", category: .study))
        tasks.append(RoutineTask(title: "Evening Snack & Tea", time: "04:30 PM", category: .meal))
        
        // Evening
        tasks.append(RoutineTask(title: "Physical Activity/Walk", time: "05:30 PM", category: .exercise))
        tasks.append(RoutineTask(title: "Dinner", time: "08:00 PM", category: .meal))
        
        // Night
        tasks.append(RoutineTask(title: "Review & Planning", time: "09:00 PM", category: .study))
        tasks.append(RoutineTask(title: "Relaxation/Breathing", time: "09:30 PM", category: .relaxation))
        tasks.append(RoutineTask(title: "Sleep", time: "10:00 PM", category: .sleep))
        
        return tasks
    }
}
