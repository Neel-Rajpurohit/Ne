import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            AnimationHelpers.impact(.light)
            withAnimation(AnimationHelpers.bouncy) {
                iconScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(AnimationHelpers.bouncy) {
                    iconScale = 1.0
                }
            }
            action()
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(iconScale)
                }
                
                Text(title)
                    .font(.appCaption)
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                        .fill(Color.white.opacity(0.3))
                        .background(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.5), color.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .cornerRadius(Constants.cardCornerRadius)
            .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AnimationHelpers.bouncy, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionButton(
            title: "Study Timer",
            icon: "timer",
            color: .appPrimary,
            action: {}
        )
        .padding()
    }
}
