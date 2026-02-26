import SwiftUI

// MARK: - App Constants
enum AppConstants {
    static let appName = "NeelHealth"

    // Default Goals
    static let defaultRunGoal: Double = 2.0  // KM
    static let defaultWaterGoal: Double = 2500  // in mL

    // Water Increments
    static let waterQuickAdd: Double = 250  // mL
    static let waterIncrements: [Double] = [100, 250, 500, 750]

    // Animation
    static let animationDuration: Double = 0.6
    static let springResponse: Double = 0.55
    static let springDamping: Double = 0.7

    // Storage Keys
    static let runGoalKey = "runGoal"
    static let waterGoalKey = "waterGoal"
    static let waterIntakeKey = "waterIntakes"
    static let streakKey = "streakData"
    static let darkModeKey = "darkModeEnabled"
    static let achievementsKey = "achievements"
}

// MARK: - App Colors
enum AppColors {
    // Primary Gradients
    static let runGradient = LinearGradient(
        colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let waterGradient = LinearGradient(
        colors: [Color(hex: "00D2FF"), Color(hex: "3A7BD5")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let streakGradient = LinearGradient(
        colors: [Color(hex: "F7971E"), Color(hex: "FFD200")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.15)

    // Accent Colors
    static let runColor = Color(hex: "667EEA")
    static let waterColor = Color(hex: "00D2FF")
    static let streakColor = Color(hex: "F7971E")
    static let successColor = Color(hex: "00E676")
    static let dangerColor = Color(hex: "FF5252")

    // Text
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let tertiaryText = Color.white.opacity(0.4)
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
