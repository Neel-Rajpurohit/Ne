import SwiftUI

// MARK: - Theme Manager
@MainActor
class AppThemeManager: ObservableObject {
    static let shared = AppThemeManager()
    
    @AppStorage("appThemeMode") var themeMode: ThemeMode = .dark
    
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

enum ThemeMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

// MARK: - App Theme / Design System
enum AppTheme {
    
    // MARK: - Primary Palette
    static let primaryIndigo = Color(hex: "4F46E5")
    static let primaryPurple = Color(hex: "7C3AED")
    static let neonCyan = Color(hex: "06B6D4")
    static let healthGreen = Color(hex: "10B981")
    static let dangerRed = Color(hex: "EF4444")
    static let warmOrange = Color(hex: "F59E0B")
    static let studyBlue = Color(hex: "3B82F6")
    static let quizPink = Color(hex: "EC4899")
    static let fitnessLime = Color(hex: "84CC16")
    static let sleepIndigo = Color(hex: "6366F1")
    static let mentalLavender = Color(hex: "A78BFA")
    static let yogaTeal = Color(hex: "14B8A6")
    static let breathingCyan = Color(hex: "22D3EE")
   
    // MARK: - Gradients
    static let mainGradient = LinearGradient(
        colors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let lightBG = LinearGradient(
        colors: [Color(hex: "F5F7FA"), Color(hex: "EEF2F7")],
        startPoint: .top, endPoint: .bottom
    )
    
    static let studyGradient = LinearGradient(
        colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let healthGradient = LinearGradient(
        colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let fitnessGradient = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let quizGradient = LinearGradient(
        colors: [Color(hex: "EC4899"), Color(hex: "8B5CF6")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let xpGradient = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "FFD200")],
        startPoint: .leading, endPoint: .trailing
    )
    
    static let breathingGradient = LinearGradient(
        colors: [Color(hex: "06B6D4"), Color(hex: "22D3EE"), Color(hex: "67E8F9")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let yogaGradient = LinearGradient(
        colors: [Color(hex: "14B8A6"), Color(hex: "5EEAD4")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let sleepGradient = LinearGradient(
        colors: [Color(hex: "4F46E5"), Color(hex: "6366F1"), Color(hex: "818CF8")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let mentalGradient = LinearGradient(
        colors: [Color(hex: "7C3AED"), Color(hex: "A78BFA")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    // MARK: - Pomodoro Gradients
    static let pomodoroStudyGradient = LinearGradient(
        colors: [Color(hex: "7C3AED"), Color(hex: "A78BFA")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let pomodoroBreakGradient = LinearGradient(
        colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    // MARK: - Level Gradients (RPG)
    static func levelGradient(for level: Int) -> LinearGradient {
        switch level {
        case 1...5:
            return LinearGradient(colors: [Color(hex: "6B7280"), Color(hex: "9CA3AF")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 6...10:
            return LinearGradient(colors: [Color(hex: "3B82F6"), Color(hex: "60A5FA")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 11...20:
            return LinearGradient(colors: [Color(hex: "8B5CF6"), Color(hex: "A78BFA")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 21...35:
            return LinearGradient(colors: [Color(hex: "F59E0B"), Color(hex: "FCD34D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color(hex: "EF4444"), Color(hex: "F97316")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)
    
    // MARK: - Card Styles
    static let cardBG = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.15)
}
