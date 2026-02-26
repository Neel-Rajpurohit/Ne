import Foundation
import SwiftUI

// MARK: - Task Type
enum TaskVerificationType: String, Codable, Sendable {
    case auto = "auto"  // HealthKit-verified — user CANNOT manually complete
    case manual = "manual"  // User-confirmed or timer-verified
}

// MARK: - Task Category
enum TaskCategory: String, Codable, CaseIterable, Sendable {
    // Auto (Health)
    case water = "Water"
    case sleep = "Sleep"
    case activeMinutes = "Active Minutes"
    case running = "Running"

    // Manual
    case homework = "Homework"
    case study = "Study"
    case meditation = "Meditation"
    case gym = "Gym"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .water: return "drop.fill"
        case .sleep: return "moon.fill"
        case .activeMinutes: return "flame.fill"
        case .running: return "figure.run"
        case .homework: return "pencil.and.list.clipboard"
        case .study: return "book.fill"
        case .meditation: return "brain.head.profile"
        case .gym: return "dumbbell.fill"
        case .custom: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .water: return Color(hex: "00D2FF")
        case .sleep: return Color(hex: "6366F1")
        case .activeMinutes: return Color(hex: "F59E0B")
        case .running: return Color(hex: "EF4444")
        case .homework: return Color(hex: "10B981")
        case .study: return Color(hex: "3B82F6")
        case .meditation: return Color(hex: "A78BFA")
        case .gym: return Color(hex: "EC4899")
        case .custom: return Color(hex: "8B5CF6")
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .water:
            return LinearGradient(
                colors: [Color(hex: "00D2FF"), Color(hex: "3A7BD5")], startPoint: .topLeading,
                endPoint: .bottomTrailing)
        case .sleep:
            return LinearGradient(
                colors: [Color(hex: "4F46E5"), Color(hex: "818CF8")], startPoint: .topLeading,
                endPoint: .bottomTrailing)
        case .activeMinutes:
            return LinearGradient(
                colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")], startPoint: .topLeading,
                endPoint: .bottomTrailing)
        case .running:
            return LinearGradient(
                colors: [Color(hex: "EF4444"), Color(hex: "F97316")], startPoint: .topLeading,
                endPoint: .bottomTrailing)
        case .homework:
            return LinearGradient(
                colors: [Color(hex: "10B981"), Color(hex: "06B6D4")], startPoint: .topLeading,
                endPoint: .bottomTrailing)
        case .study:
            return LinearGradient(
                colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")], startPoint: .topLeading,
                endPoint: .bottomTrailing)
        case .meditation:
            return LinearGradient(
                colors: [Color(hex: "7C3AED"), Color(hex: "A78BFA")], startPoint: .topLeading,
                endPoint: .bottomTrailing)
        case .gym:
            return LinearGradient(
                colors: [Color(hex: "EC4899"), Color(hex: "8B5CF6")], startPoint: .topLeading,
                endPoint: .bottomTrailing)
        case .custom:
            return LinearGradient(
                colors: [Color(hex: "8B5CF6"), Color(hex: "6366F1")], startPoint: .topLeading,
                endPoint: .bottomTrailing)
        }
    }

    var verificationType: TaskVerificationType {
        switch self {
        case .water, .sleep, .activeMinutes, .running:
            return .auto
        case .homework, .study, .meditation, .gym, .custom:
            return .manual
        }
    }

    var defaultXP: Int {
        switch self {
        case .water: return 30
        case .sleep: return 20
        case .activeMinutes: return 40
        case .running: return 60
        case .homework: return 35
        case .study: return 40
        case .meditation: return 25
        case .gym: return 50
        case .custom: return 20
        }
    }

    /// Unit label for display
    var unit: String {
        switch self {
        case .water: return "mL"
        case .sleep: return "hours"
        case .activeMinutes: return "min"
        case .running: return "km"
        case .homework: return ""
        case .study: return "min"
        case .meditation: return "min"
        case .gym: return "min"
        case .custom: return ""
        }
    }

    /// Whether this task uses a timer for verification
    var usesTimer: Bool {
        switch self {
        case .study, .meditation, .gym:
            return true
        default:
            return false
        }
    }
}

// MARK: - Task Status
enum TaskStatus: String, Codable, Sendable {
    case pending = "pending"
    case completed = "completed"
}

// MARK: - Daily Task
struct DailyTask: Codable, Identifiable, Sendable {
    let id: UUID
    var title: String
    var type: TaskVerificationType
    var category: TaskCategory
    var goalValue: Double
    var currentValue: Double
    var status: TaskStatus
    var rewardXP: Int
    var completedAt: Date?
    var createdAt: Date

    var isCompleted: Bool { status == .completed }

    var progress: Double {
        guard goalValue > 0 else { return isCompleted ? 1.0 : 0.0 }
        return min(1.0, currentValue / goalValue)
    }

    var progressPercent: Int {
        Int(progress * 100)
    }

    /// Formatted current value display
    var currentDisplay: String {
        if category == .water {
            return currentValue >= 1000
                ? String(format: "%.1fL", currentValue / 1000) : "\(Int(currentValue))mL"
        }
        if category == .sleep {
            return String(format: "%.1f", currentValue)
        }
        return "\(Int(currentValue))"
    }

    /// Formatted goal value display
    var goalDisplay: String {
        if category == .water {
            return goalValue >= 1000
                ? String(format: "%.1fL", goalValue / 1000) : "\(Int(goalValue))mL"
        }
        if category == .sleep {
            return String(format: "%.0f", goalValue)
        }
        return "\(Int(goalValue))"
    }

    /// Can the user manually complete this task?
    var canCompleteManually: Bool {
        type == .manual && !category.usesTimer
    }

    /// Does this task need a timer to verify?
    var needsTimer: Bool {
        type == .manual && category.usesTimer
    }

    static func create(title: String, category: TaskCategory, goalValue: Double, xp: Int? = nil)
        -> DailyTask
    {
        DailyTask(
            id: UUID(),
            title: title,
            type: category.verificationType,
            category: category,
            goalValue: goalValue,
            currentValue: 0,
            status: .pending,
            rewardXP: xp ?? category.defaultXP,
            completedAt: nil,
            createdAt: Date()
        )
    }
}

// MARK: - Daily Task Set
struct DailyTaskSet: Codable, Sendable {
    var date: Date
    var tasks: [DailyTask]

    var completedCount: Int { tasks.filter { $0.isCompleted }.count }
    var totalCount: Int { tasks.count }
    var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    var completionPercent: Int { Int(completionRate * 100) }
    var totalXPEarned: Int { tasks.filter { $0.isCompleted }.reduce(0) { $0 + $1.rewardXP } }
    var totalXPAvailable: Int { tasks.reduce(0) { $0 + $1.rewardXP } }

    var autoTasks: [DailyTask] { tasks.filter { $0.type == .auto } }
    var manualTasks: [DailyTask] { tasks.filter { $0.type == .manual } }

    static func empty(for date: Date) -> DailyTaskSet {
        DailyTaskSet(date: date, tasks: [])
    }
}

// MARK: - Performance Trend
enum PerformanceTrend: String, Sendable {
    case improving = "Improving"
    case stable = "Stable"
    case declining = "Declining"

    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    var color: Color {
        switch self {
        case .improving: return Color(hex: "10B981")
        case .stable: return Color(hex: "F59E0B")
        case .declining: return Color(hex: "EF4444")
        }
    }
}
