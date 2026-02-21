import Foundation
import SwiftUI

// MARK: - Subject
struct Subject: Codable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var colorHex: String
    var professor: String
    var totalStudyMinutes: Int
    
    var color: Color { Color(hex: colorHex) }
    
    init(name: String, colorHex: String, professor: String = "", totalStudyMinutes: Int = 0) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.professor = professor
        self.totalStudyMinutes = totalStudyMinutes
    }
    
    static let samples: [Subject] = [
        Subject(name: "Mathematics", colorHex: "3B82F6", professor: "Prof. Kumar"),
        Subject(name: "Physics", colorHex: "8B5CF6", professor: "Prof. Singh"),
        Subject(name: "Chemistry", colorHex: "10B981", professor: "Prof. Sharma"),
        Subject(name: "English", colorHex: "F59E0B", professor: "Prof. Patel"),
        Subject(name: "Computer Science", colorHex: "EC4899", professor: "Prof. Reddy"),
    ]
}

// MARK: - Assignment
struct Assignment: Codable, Identifiable, Sendable {
    let id: UUID
    var title: String
    var subjectId: UUID
    var dueDate: Date
    var priority: AssignmentPriority
    var isCompleted: Bool
    
    init(title: String, subjectId: UUID, dueDate: Date, priority: AssignmentPriority = .medium, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.subjectId = subjectId
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
    }
}

enum AssignmentPriority: String, Codable, CaseIterable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return Color(hex: "10B981")
        case .medium: return Color(hex: "F59E0B")
        case .high: return Color(hex: "EF4444")
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "equal"
        case .high: return "arrow.up"
        }
    }
}

// MARK: - Study Session
struct StudySession: Codable, Identifiable, Sendable {
    let id: UUID
    let subjectId: UUID
    let date: Date
    let durationMinutes: Int
    let focusScore: Int // 1-100
    let xpEarned: Int
    
    init(subjectId: UUID, durationMinutes: Int, focusScore: Int = 80, xpEarned: Int = 0) {
        self.id = UUID()
        self.subjectId = subjectId
        self.date = Date()
        self.durationMinutes = durationMinutes
        self.focusScore = focusScore
        self.xpEarned = xpEarned
    }
}
