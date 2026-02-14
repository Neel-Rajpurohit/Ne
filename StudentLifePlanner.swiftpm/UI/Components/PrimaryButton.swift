import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var gradient: LinearGradient = .primaryGradient
    var isLoading: Bool = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            AnimationHelpers.impact(.medium)
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                
                Text(title)
                    .font(.appHeadline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                ZStack {
                    gradient
                    
                    // Shimmer overlay
                    if !isLoading {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.2),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .blur(radius: 10)
                    }
                }
            )
            .cornerRadius(16)
            .shadow(color: Color.purple.opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(AnimationHelpers.bouncy, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .disabled(isLoading)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}
