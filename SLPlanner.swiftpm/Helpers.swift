import SwiftUI

// MARK: - Haptic Feedback
@MainActor
enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Greeting Generator
enum GreetingHelper {
    static func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning ☀️"
        case 12..<17:
            return "Good Afternoon 🌤"
        case 17..<21:
            return "Good Evening 🌅"
        default:
            return "Good Night 🌙"
        }
    }

    static func motivationalMessage(runProgress: Double, waterProgress: Double) -> String {
        let avg = (runProgress + waterProgress) / 2.0
        switch avg {
        case 0..<0.25:
            return "Let's get moving! Every step counts 💪"
        case 0.25..<0.5:
            return "Nice start! Keep the momentum going 🚀"
        case 0.5..<0.75:
            return "Halfway there! You're doing amazing ⭐️"
        case 0.75..<1.0:
            return "Almost there! Push to the finish line 🏁"
        default:
            return "Goals crushed! You're a champion 🏆"
        }
    }
}

// MARK: - Glassmorphism Modifier
struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial.opacity(0.5))
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}
