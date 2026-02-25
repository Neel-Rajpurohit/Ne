import Foundation
import SwiftUI

// MARK: - Sleep Data
struct SleepData: Codable, Identifiable, Sendable {
    var id: String { date.ISO8601Format() }
    var date: Date
    var hours: Double
    var quality: SleepQuality
    var bedtime: Date?
    var wakeTime: Date?
    
    var isGoalMet: Bool { hours >= 7.0 }
    
    static func empty(for date: Date) -> SleepData {
        SleepData(date: date, hours: 0, quality: .notLogged)
    }
}

enum SleepQuality: String, Codable, CaseIterable, Sendable {
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"
    case notLogged = "Not Logged"
    
    var icon: String {
        switch self {
        case .poor: return "😴"
        case .fair: return "😐"
        case .good: return "😊"
        case .excellent: return "🌟"
        case .notLogged: return "➖"
        }
    }
    
    var color: Color {
        switch self {
        case .poor: return Color(hex: "EF4444")
        case .fair: return Color(hex: "F59E0B")
        case .good: return Color(hex: "10B981")
        case .excellent: return Color(hex: "06B6D4")
        case .notLogged: return Color(hex: "6B7280")
        }
    }
}

// MARK: - Mental Health Log
struct MentalHealthLog: Codable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let mood: MoodType
    let stressLevel: Int // 1-10
    let journalEntry: String
    
    init(mood: MoodType, stressLevel: Int, journalEntry: String = "") {
        self.id = UUID()
        self.date = Date()
        self.mood = mood
        self.stressLevel = stressLevel
        self.journalEntry = journalEntry
    }
}

enum MoodType: String, Codable, CaseIterable, Sendable {
    case happy = "Happy"
    case calm = "Calm"
    case neutral = "Neutral"
    case anxious = "Anxious"
    case sad = "Sad"
    case stressed = "Stressed"
    case energetic = "Energetic"
    case tired = "Tired"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .calm: return "😌"
        case .neutral: return "😐"
        case .anxious: return "😰"
        case .sad: return "😢"
        case .stressed: return "😤"
        case .energetic: return "⚡"
        case .tired: return "😴"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return Color(hex: "F59E0B")
        case .calm: return Color(hex: "06B6D4")
        case .neutral: return Color(hex: "6B7280")
        case .anxious: return Color(hex: "F97316")
        case .sad: return Color(hex: "3B82F6")
        case .stressed: return Color(hex: "EF4444")
        case .energetic: return Color(hex: "10B981")
        case .tired: return Color(hex: "8B5CF6")
        }
    }
}
