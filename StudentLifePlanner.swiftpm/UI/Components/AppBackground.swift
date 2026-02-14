import SwiftUI

struct AppBackground: View {
    var style: BackgroundStyle = .default
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: gradient,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
            ) {
                animateGradient = true
            }
        }
    }
    
    private var gradient: Gradient {
        switch style {
        case .default:
            return Gradient(colors: [
                Color(hex: "a8edea"),
                Color(hex: "fed6e3"),
                Color(hex: "E0F7FA")
            ])
        case .study:
            return Gradient(colors: [
                Color(hex: "667eea"),
                Color(hex: "764ba2"),
                Color(hex: "a8c0ff")
            ])
        case .health:
            return Gradient(colors: [
                Color(hex: "4facfe"),
                Color(hex: "00f2fe"),
                Color(hex: "a8edea")
            ])
        case .progress:
            return Gradient(colors: [
                Color(hex: "fa709a"),
                Color(hex: "fee140"),
                Color(hex: "ffd89b")
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
