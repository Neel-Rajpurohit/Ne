import Foundation
import SwiftUI

// MARK: - Timetable Models

enum BlockType: String, Codable, CaseIterable {
    case wakeUp = "Wake Up"
    case school = "School"
    case study = "Study"
    case breakTime = "Break"
    case lunch = "Lunch"
    case tuition = "Tuition"
    case exercise = "Exercise"
    case freeTime = "Free Time"
    case sleep = "Sleep"
    
    var icon: String {
        switch self {
        case .wakeUp: return "sunrise.fill"
        case .school: return "building.columns.fill"
        case .study: return "book.fill"
        case .breakTime: return "gamecontroller.fill"
        case .lunch: return "fork.knife"
        case .tuition: return "person.fill"
        case .exercise: return "figure.run"
        case .freeTime: return "sparkles"
        case .sleep: return "moon.fill"
        }
    }
    
    var lightColor: Color {
        switch self {
        case .wakeUp: return Color(hex: "F59E0B")
        case .school: return Color(hex: "3B82F6")
        case .study: return Color(hex: "8B5CF6")
        case .breakTime: return Color(hex: "10B981")
        case .lunch: return Color(hex: "F97316")
        case .tuition: return Color(hex: "6366F1")
        case .exercise: return Color(hex: "EF4444")
        case .freeTime: return Color(hex: "EC4899")
        case .sleep: return Color(hex: "6366F1")
        }
    }
    
    /// Whether this block auto-completes when its time passes
    var autoCompletes: Bool {
        switch self {
        case .breakTime:
            return true
        default:
            return false
        }
    }
    
    /// Whether user can manually tap to mark this block as complete
    var canCompleteManually: Bool {
        switch self {
        case .school, .lunch, .freeTime, .tuition:
            return true
        default:
            return false
        }
    }
}

struct TimeBlock: Codable, Identifiable {
    let id: UUID
    var type: BlockType
    var subject: String?
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var isCompleted: Bool
    
    // Pomodoro cycle config (only used for .study blocks)
    var cycles: Int
    var studyDuration: Int   // minutes per study phase
    var breakDuration: Int   // minutes per break phase
    
    init(type: BlockType, subject: String? = nil, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, cycles: Int = 2, studyDuration: Int = 25, breakDuration: Int = 5) {
        self.id = UUID()
        self.type = type
        self.subject = subject
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.isCompleted = false
        self.cycles = cycles
        self.studyDuration = studyDuration
        self.breakDuration = breakDuration
    }
    
    var startTime: String {
        String(format: "%d:%02d", startHour, startMinute)
    }
    
    var endTime: String {
        String(format: "%d:%02d", endHour, endMinute)
    }
    
    var durationMinutes: Int {
        (endHour * 60 + endMinute) - (startHour * 60 + startMinute)
    }
    
    var displayTitle: String {
        if let subject = subject { return "\(type.rawValue): \(subject)" }
        return type.rawValue
    }
    
    var pomodoroCount: Int {
        type == .study ? cycles : 0
    }
    
    /// Total study minutes across all cycles
    var totalStudyMinutes: Int {
        cycles * studyDuration
    }
    
    /// Total break minutes across all cycles
    var totalBreakMinutes: Int {
        cycles * breakDuration
    }
    
    /// Formatted session description e.g. "2 Cycles (25+5 ×2)"
    var sessionDescription: String {
        "\(cycles) Cycle\(cycles == 1 ? "" : "s") (\(studyDuration)+\(breakDuration) ×\(cycles))"
    }
    
    /// Check if current time is within this block's window
    var isCurrentlyActive: Bool {
        let cal = Calendar.current
        let now = Date()
        let hour = cal.component(.hour, from: now)
        let minute = cal.component(.minute, from: now)
        let nowMins = hour * 60 + minute
        let startMins = startHour * 60 + startMinute
        let endMins = endHour * 60 + endMinute
        return nowMins >= startMins && nowMins < endMins
    }
    
    /// Check if current time has passed this block's end
    var hasTimePassed: Bool {
        let cal = Calendar.current
        let now = Date()
        let hour = cal.component(.hour, from: now)
        let minute = cal.component(.minute, from: now)
        let nowMins = hour * 60 + minute
        let endMins = endHour * 60 + endMinute
        return nowMins >= endMins
    }
}

struct DailyRoutine: Codable {
    var date: Date
    var blocks: [TimeBlock]
    
    var studyBlocks: [TimeBlock] { blocks.filter { $0.type == .study } }
    var totalStudyMinutes: Int { studyBlocks.reduce(0) { $0 + $1.durationMinutes } }
    
    var completedCount: Int { blocks.filter { $0.isCompleted }.count }
    var completionPercentage: Double {
        guard !blocks.isEmpty else { return 0 }
        return Double(completedCount) / Double(blocks.count)
    }
    
    mutating func markComplete(_ blockId: UUID) {
        if let idx = blocks.firstIndex(where: { $0.id == blockId }) {
            blocks[idx].isCompleted = true
        }
    }
    
    mutating func markCompleteByType(_ type: BlockType) {
        for i in blocks.indices where blocks[i].type == type && !blocks[i].isCompleted {
            blocks[i].isCompleted = true
            break // Only mark the first uncompleted block of this type
        }
    }
}
