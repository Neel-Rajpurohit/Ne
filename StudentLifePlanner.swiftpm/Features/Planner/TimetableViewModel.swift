import SwiftUI

@MainActor
class TimetableViewModel: ObservableObject {
    @Published var institutionSchedule: InstitutionSchedule?
    @Published var tuitionSchedule: TuitionSchedule?
    @Published var extraClasses: [ExtraClassSchedule] = []
    
    let storage: LocalStorageService
    
    init(storage: LocalStorageService = .shared) {
        self.storage = storage
    }
    
    func saveTimetable() {
        // Implementation for saving
    }
}
