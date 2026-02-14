import SwiftUI
import Foundation

@MainActor
class RoutineViewModel: ObservableObject {
    @Published var tasks: [RoutineTask] = []
    @Published var canSubmit: Bool = true
    
    private let pointsManager = PointsManager.shared
    private let storage = DataStorageService.shared
    private let calendarService = CalendarService.shared
    
    init() {
        loadOrGenerateRoutine()
        checkSubmissionStatus()
    }
    
    func loadOrGenerateRoutine() {
        // Try to load saved routine
        if let savedTasks = storage.loadRoutineTasks() {
            tasks = savedTasks
        } else {
            generateRoutine()
        }
    }
    
    func generateRoutine() {
        guard let profile = storage.loadProfile() else {
            tasks = RoutineGenerator.generateRoutine(for: 18, educationLevel: "University")
            return
        }
        
        let timetable = storage.loadTimetable()
        tasks = RoutineGenerator.generateRoutine(
            for: profile.age,
            educationLevel: profile.educationLevel,
            timetable: timetable
        )
        
        storage.saveRoutineTasks(tasks)
    }
    
    func toggleTaskCompletion(taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted.toggle()
            storage.saveRoutineTasks(tasks)
        }
    }
    
    func submitDailyRoutine() {
        guard pointsManager.canSubmitToday() else {
            canSubmit = false
            return
        }
        
        let points = pointsManager.calculateDailyPoints(tasks: tasks)
        pointsManager.addPoints(points)
        
        // Save to points history
        let completedCount = tasks.filter { $0.isCompleted }.count
        let record = PointsRecord(
            date: Date(),
            pointsEarned: points,
            tasksCompleted: completedCount,
            totalTasks: tasks.count
        )
        
        var history = storage.loadPointsHistory()
        history.addRecord(record)
        storage.savePointsHistory(history)
        
        // Mark day as completed
        calendarService.markDayCompleted(Date())
        
        canSubmit = false
    }
    
    private func checkSubmissionStatus() {
        canSubmit = pointsManager.canSubmitToday()
    }
    
    func resetDay() {
        for index in tasks.indices {
            tasks[index].isCompleted = false
        }
        storage.saveRoutineTasks(tasks)
    }
}
