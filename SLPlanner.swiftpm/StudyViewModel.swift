import SwiftUI

// MARK: - Study ViewModel
@MainActor
class StudyViewModel: ObservableObject {
    @Published var subjects: [Subject]
    @Published var assignments: [Assignment]
    @Published var sessions: [StudySession]
    @Published var showAddSubject = false
    @Published var showAddAssignment = false
    
    private let defaults = UserDefaults.standard
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "subjects"),
           let saved = try? JSONDecoder().decode([Subject].self, from: data) {
            self.subjects = saved
        } else {
            self.subjects = Subject.samples
        }
        
        if let data = UserDefaults.standard.data(forKey: "assignments"),
           let saved = try? JSONDecoder().decode([Assignment].self, from: data) {
            self.assignments = saved
        } else {
            self.assignments = []
        }
        
        if let data = UserDefaults.standard.data(forKey: "studySessions"),
           let saved = try? JSONDecoder().decode([StudySession].self, from: data) {
            self.sessions = saved
        } else {
            self.sessions = []
        }
    }
    
    var totalStudyMinutesToday: Int {
        sessions.filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.durationMinutes }
    }
    
    var totalStudyMinutesThisWeek: Int {
        let weekAgo = Date().daysAgo(7)
        return sessions.filter { $0.date > weekAgo }
            .reduce(0) { $0 + $1.durationMinutes }
    }
    
    var averageFocusScore: Int {
        let todaySessions = sessions.filter { Calendar.current.isDateInToday($0.date) }
        guard !todaySessions.isEmpty else { return 0 }
        return todaySessions.reduce(0) { $0 + $1.focusScore } / todaySessions.count
    }
    
    var pendingAssignments: [Assignment] {
        assignments.filter { !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }
    }
    
    func subject(for id: UUID) -> Subject? {
        subjects.first { $0.id == id }
    }
    
    func addSubject(_ subject: Subject) {
        subjects.append(subject)
        saveSubjects()
    }
    
    func addAssignment(_ assignment: Assignment) {
        assignments.append(assignment)
        saveAssignments()
    }
    
    func toggleAssignment(_ id: UUID) {
        if let idx = assignments.firstIndex(where: { $0.id == id }) {
            assignments[idx].isCompleted.toggle()
            saveAssignments()
            if assignments[idx].isCompleted {
                GameEngineManager.shared.awardXP(amount: 15, source: "Assignment Done", icon: "checkmark.circle.fill")
            }
        }
    }
    
    func recordSession(subjectId: UUID, durationMinutes: Int) {
        let xp = durationMinutes * GameEngineManager.xpStudyPerMinute
        let session = StudySession(subjectId: subjectId, durationMinutes: durationMinutes, xpEarned: xp)
        sessions.append(session)
        saveSessions()
        
        if let idx = subjects.firstIndex(where: { $0.id == subjectId }) {
            subjects[idx].totalStudyMinutes += durationMinutes
            saveSubjects()
        }
        
        GameEngineManager.shared.awardXP(amount: xp, source: "Study \(durationMinutes)m", icon: "book.fill")
    }
    
    func deleteSubject(_ id: UUID) {
        subjects.removeAll { $0.id == id }
        assignments.removeAll { $0.subjectId == id }
        saveSubjects()
        saveAssignments()
    }
    
    private func saveSubjects() {
        if let data = try? JSONEncoder().encode(subjects) { defaults.set(data, forKey: "subjects") }
    }
    private func saveAssignments() {
        if let data = try? JSONEncoder().encode(assignments) { defaults.set(data, forKey: "assignments") }
    }
    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) { defaults.set(data, forKey: "studySessions") }
    }
}
