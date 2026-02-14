import SwiftUI
import Foundation

extension Color {
    static let appPrimary = Color(hex: "007AFF") // Modern Blue
    static let appSecondary = Color(hex: "5856D6") // Purple
    static let appBackground = Color(hex: "F2F2F7") // Light Gray
    static let appCardBackground = Color.white
    static let appText = Color.black
    static let appTextSecondary = Color.gray
    static let appAccent = Color(hex: "FF9500") // Orange
    static let appSuccess = Color(hex: "34C759") // Green
    static let appWarning = Color(hex: "FF9500") // Orange
    static let appError = Color(hex: "FF3B30") // Red
    
    // Category colors
    static let categoryStudy = Color(hex: "007AFF") // Blue
    static let categoryMeal = Color(hex: "FF9500") // Orange
    static let categoryExercise = Color(hex: "34C759") // Green
    static let categoryRelaxation = Color(hex: "5856D6") // Purple
    static let categorySleep = Color(hex: "AF52DE") // Indigo
    
    // Health category colors
    static let healthFitness = Color(hex: "FF6B6B")
    static let healthYoga = Color(hex: "4ECDC4")
    static let healthBreathing = Color(hex: "95E1D3")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Helper for routine category colors
extension RoutineCategory {
    var color: Color {
        switch self {
        case .study: return .categoryStudy
        case .meal: return .categoryMeal
        case .exercise: return .categoryExercise
        case .relaxation: return .categoryRelaxation
        case .sleep: return .categorySleep
        }
    }
}

// Helper for exercise category colors
extension ExerciseCategory {
    var color: Color {
        switch self {
        case .fitness: return .healthFitness
        case .yoga: return .healthYoga
        case .breathing: return .healthBreathing
        }
    }
}
