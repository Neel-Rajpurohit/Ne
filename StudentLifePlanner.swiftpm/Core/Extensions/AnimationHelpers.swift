import SwiftUI

// MARK: - Animation Helpers
struct AnimationHelpers {
    // Spring animations
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let smooth = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let gentle = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeOut(duration: 0.2)
    
    // Haptic feedback
    @MainActor
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    @MainActor
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    @MainActor
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    @MainActor
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Bounce Animation Modifier
struct BounceModifier: ViewModifier {
    @State private var isPressed = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AnimationHelpers.bouncy, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            AnimationHelpers.impact(.light)
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}

extension View {
    func bounceEffect(action: @escaping () -> Void = {}) -> some View {
        self.modifier(BounceModifier(action: action))
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - Stagger Animation
struct StaggeredAppearance: ViewModifier {
    let index: Int
    let total: Int
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(
                    AnimationHelpers.smooth
                        .delay(Double(index) * 0.1)
                ) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggeredAppearance(index: Int, total: Int) -> some View {
        self.modifier(StaggeredAppearance(index: index, total: total))
    }
}
