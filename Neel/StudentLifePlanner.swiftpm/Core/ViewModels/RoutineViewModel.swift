import SwiftUI
import Foundation

@MainActor
class RoutineViewModel: ObservableObject {
    @Published var tasks: [RoutineTask] = []
    @Published var canSubmit: Bool = true
    
    init() {
        loadRoutine()
        checkSubmissionStatus()
    }
    
    func loadRoutine() {
        if let data = UserDefaults.standard.data(forKey: "user_profile"),
           let profile = try? JSONDecoder().decode(StudentProfile.self, from: data) {
            self.tasks = RoutineGenerator.generateRoutine(for: profile.age, educationLevel: profile.educationLevel)
        } else {
            self.tasks = RoutineGenerator.generateRoutine(for: 18, educationLevel: "University")
        }
    }
    
    func checkSubmissionStatus() {
        canSubmit = PointsManager.shared.canSubmitToday()
    }
    
    func toggleTaskCompletion(taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func submitDailyRoutine() {
        guard canSubmit else { return }
        
        let points = PointsManager.shared.calculateDailyPoints(tasks: tasks)
        PointsManager.shared.addPoints(points)
        canSubmit = false
    }
}
