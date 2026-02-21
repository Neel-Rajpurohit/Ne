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
}

struct TimeBlock: Codable, Identifiable {
    let id: UUID
    var type: BlockType
    var subject: String?
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    
    init(type: BlockType, subject: String? = nil, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) {
        self.id = UUID()
        self.type = type
        self.subject = subject
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
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
        durationMinutes / 30  // 25 study + 5 break = 30 min per cycle
    }
}

struct DailyRoutine: Codable {
    var date: Date
    var blocks: [TimeBlock]
    
    var studyBlocks: [TimeBlock] { blocks.filter { $0.type == .study } }
    var totalStudyMinutes: Int { studyBlocks.reduce(0) { $0 + $1.durationMinutes } }
}
