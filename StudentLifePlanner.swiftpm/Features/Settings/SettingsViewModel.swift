import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("isPrivacyLockEnabled") var isPrivacyLockEnabled: Bool = false
    @AppStorage("academicMode") var academicMode: String = "School"
    
    // Timetable Schedules
    @Published var weeklyTimetable: WeeklyTimetable
    @Published var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    
    let academicModes = ["School", "College", "University", "Competitive Exams"]
    private let storage = LocalStorageService.shared
    
    init() {
        // Load weekly timetable from storage or use default
        self.weeklyTimetable = storage.loadWeeklyTimetable() ?? WeeklyTimetable.defaultSchedule()
    }
    
    var currentDaySchedule: DaySchedule {
        get { weeklyTimetable.schedules[selectedDay]! }
        set { weeklyTimetable.schedules[selectedDay] = newValue }
    }
    
    func saveSchedules() {
        storage.saveWeeklyTimetable(weeklyTimetable)
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
}
