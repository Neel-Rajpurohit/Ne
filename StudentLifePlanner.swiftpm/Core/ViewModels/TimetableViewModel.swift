import Foundation
import Combine

@MainActor
class TimetableViewModel: ObservableObject {
    @Published var timetable: Timetable = Timetable()
    @Published var selectedDay: DayOfWeek = .monday
    @Published var hasConflicts: Bool = false
    @Published var errorMessage: String = ""
    
    private let storage = DataStorageService.shared
    
    init() {
        loadTimetable()
    }
    
    func loadTimetable() {
        if let saved = storage.loadTimetable() {
            timetable = saved
        }
        checkForConflicts()
    }
    
    func saveTimetable() {
        storage.saveTimetable(timetable)
        regenerateRoutine()
    }
    
    func addTimeSlot(day: DayOfWeek, startTime: Date, endTime: Date, subject: String, location: String) {
        let newSlot = TimeSlot(
            day: day,
            startTime: startTime,
            endTime: endTime,
            subject: subject,
            location: location
        )
        
        // Check for conflicts
        if let conflict = findConflict(with: newSlot) {
            errorMessage = "Time slot conflicts with \(conflict.subject) at \(conflict.location)"
            hasConflicts = true
            return
        }
        
        timetable.timeSlots.append(newSlot)
        saveTimetable()
        checkForConflicts()
    }
    
    func removeTimeSlot(_ slot: TimeSlot) {
        timetable.timeSlots.removeAll { $0.id == slot.id }
        saveTimetable()
        checkForConflicts()
    }
    
    func getSlotsForDay(_ day: DayOfWeek) -> [TimeSlot] {
        return timetable.getSlotsForDay(day)
    }
    
    func getSlotsForSelectedDay() -> [TimeSlot] {
        return getSlotsForDay(selectedDay)
    }
    
    private func findConflict(with newSlot: TimeSlot) -> TimeSlot? {
        return timetable.timeSlots.first { $0.conflictsWith(newSlot) }
    }
    
    private func checkForConflicts() {
        hasConflicts = timetable.hasConflicts()
    }
    
    private func regenerateRoutine() {
        // Update profile to indicate timetable exists
        if var profile = storage.loadProfile() {
            profile.hasTimetable = !timetable.timeSlots.isEmpty
            storage.saveProfile(profile)
        }
        
        // Regenerate routine with new timetable
        if let profile = storage.loadProfile() {
            let tasks = RoutineGenerator.generateRoutine(
                for: profile.age,
                educationLevel: profile.educationLevel,
                timetable: timetable
            )
            storage.saveRoutineTasks(tasks)
        }
    }
    
    func clearTimetable() {
        timetable = Timetable()
        saveTimetable()
    }
}
