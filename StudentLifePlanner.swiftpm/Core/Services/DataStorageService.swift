import Foundation

@MainActor
class DataStorageService {
    nonisolated static let shared = DataStorageService()
    private let defaults = UserDefaults.standard
    
    nonisolated private init() {}
    
    // MARK: - Student Profile
    
    func saveProfile(_ profile: StudentProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            defaults.set(encoded, forKey: Constants.userProfileKey)
        }
    }
    
    func loadProfile() -> StudentProfile? {
        guard let data = defaults.data(forKey: Constants.userProfileKey) else {
            return nil
        }
        return try? JSONDecoder().decode(StudentProfile.self, from: data)
    }
    
    // MARK: - Timetable
    
    func saveTimetable(_ timetable: Timetable) {
        if let encoded = try? JSONEncoder().encode(timetable) {
            defaults.set(encoded, forKey: Constants.timetableKey)
        }
    }
    
    func loadTimetable() -> Timetable? {
        guard let data = defaults.data(forKey: Constants.timetableKey) else {
            return nil
        }
        return try? JSONDecoder().decode(Timetable.self, from: data)
    }
    
    // MARK: - Routine Tasks
    
    func saveRoutineTasks(_ tasks: [RoutineTask]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            defaults.set(encoded, forKey: Constants.routineTasksKey)
        }
    }
    
    func loadRoutineTasks() -> [RoutineTask]? {
        guard let data = defaults.data(forKey: Constants.routineTasksKey) else {
            return nil
        }
        return try? JSONDecoder().decode([RoutineTask].self, from: data)
    }
    
    // MARK: - Study Sessions
    
    func saveStudySessions(_ sessions: [StudySession]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            defaults.set(encoded, forKey: Constants.studySessionsKey)
        }
    }
    
    func loadStudySessions() -> [StudySession] {
        guard let data = defaults.data(forKey: Constants.studySessionsKey) else {
            return []
        }
        return (try? JSONDecoder().decode([StudySession].self, from: data)) ?? []
    }
    
    func addStudySession(_ session: StudySession) {
        var sessions = loadStudySessions()
        sessions.append(session)
        saveStudySessions(sessions)
    }
    
    // MARK: - Points History
    
    func savePointsHistory(_ history: PointsHistory) {
        if let encoded = try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: Constants.pointsHistoryKey)
        }
    }
    
    func loadPointsHistory() -> PointsHistory {
        guard let data = defaults.data(forKey: Constants.pointsHistoryKey) else {
            return PointsHistory()
        }
        return (try? JSONDecoder().decode(PointsHistory.self, from: data)) ?? PointsHistory()
    }
    
    // MARK: - Completion History (Date -> Completed)
    
    func markDayCompleted(_ date: Date, completed: Bool) {
        var history = getCompletionHistory()
        let key = DateHelper.formatDate(date)
        history[key] = completed
        
        if let encoded = try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: Constants.completionHistoryKey)
        }
    }
    
    func isDayCompleted(_ date: Date) -> Bool {
        let history = getCompletionHistory()
        let key = DateHelper.formatDate(date)
        return history[key] ?? false
    }
    
    private func getCompletionHistory() -> [String: Bool] {
        guard let data = defaults.data(forKey: Constants.completionHistoryKey) else {
            return [:]
        }
        return (try? JSONDecoder().decode([String: Bool].self, from: data)) ?? [:]
    }
    
    // MARK: - Last Submission Date
    
    func getLastSubmissionDate() -> Date? {
        return defaults.object(forKey: Constants.lastSubmissionKey) as? Date
    }
    
    func setLastSubmissionDate(_ date: Date) {
        defaults.set(date, forKey: Constants.lastSubmissionKey)
    }
    
    // MARK: - Reset Data
    
    func resetAllData() {
        let keys = [
            Constants.userProfileKey,
            Constants.timetableKey,
            Constants.pointsHistoryKey,
            Constants.routineTasksKey,
            Constants.studySessionsKey,
            Constants.lastSubmissionKey,
            Constants.completionHistoryKey
        ]
        
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
}
