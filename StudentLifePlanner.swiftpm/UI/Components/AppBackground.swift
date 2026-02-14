import SwiftUI

struct AppBackground: View {
    var style: BackgroundStyle = .default
    
    var body: some View {
        LinearGradient(
            gradient: gradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var gradient: Gradient {
        switch style {
        case .default:
            return Gradient(colors: [
                Color(hex: "E0F7FA"),
                Color(hex: "F3E5F5")
            ])
        case .study:
            return Gradient(colors: [
                Color(hex: "E3F2FD"),
                Color(hex: "FFF9C4")
            ])
        case .health:
            return Gradient(colors: [
                Color(hex: "E8F5E9"),
                Color(hex: "F1F8E9")
            ])
        case .progress:
            return Gradient(colors: [
                Color(hex: "FFF3E0"),
                Color(hex: "FFE0B2")
            ])
        }
    }
}

enum BackgroundStyle {
    case `default`
    case study
    case health
    case progress
}
