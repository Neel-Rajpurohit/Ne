import SwiftUI

// MARK: - LinearGradient Extensions
extension LinearGradient {
    static let primaryGradient = LinearGradient(
        colors: [.gradientPrimary1, .gradientPrimary2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [.gradientAccent1, .gradientAccent2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [.gradientSuccess1, .gradientSuccess2],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [.gradientWarning1, .gradientWarning2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let coolGradient = LinearGradient(
        colors: [.gradientCool1, .gradientCool2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Glassmorphism Modifier
struct GlassmorphismModifier: ViewModifier {
    var opacity: Double = 0.2
    var blur: CGFloat = 10
    var borderOpacity: Double = 0.3
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Blur background
                    Color.white.opacity(opacity)
                        .blur(radius: blur)
                    
                    // Border glow
                    RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                        .stroke(Color.white.opacity(borderOpacity), lineWidth: 1)
                }
            )
            .background(.ultraThinMaterial)
            .cornerRadius(Constants.cardCornerRadius)
    }
}

extension View {
    func glassmorphism(opacity: Double = 0.2, blur: CGFloat = 10, borderOpacity: Double = 0.3) -> some View {
        self.modifier(GlassmorphismModifier(opacity: opacity, blur: blur, borderOpacity: borderOpacity))
    }
}

// MARK: - Gradient Overlay
struct GradientOverlay: ViewModifier {
    let gradient: LinearGradient
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .overlay(
                gradient
                    .opacity(opacity)
                    .cornerRadius(Constants.cardCornerRadius)
            )
    }
}

extension View {
    func gradientOverlay(_ gradient: LinearGradient, opacity: Double = 0.3) -> some View {
        self.modifier(GradientOverlay(gradient: gradient, opacity: opacity))
    }
}
