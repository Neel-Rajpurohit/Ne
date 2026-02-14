import SwiftUI

struct InfoCard<Content: View>: View {
    let content: Content
    var style: CardStyle = .glass
    @State private var isPressed = false
    
    init(style: CardStyle = .glass, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        .padding()
        .background(backgroundView)
        .cornerRadius(Constants.cardCornerRadius)
        .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AnimationHelpers.smooth, value: isPressed)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .glass:
            ZStack {
                RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                    .fill(Color.white.opacity(0.25))
                    .background(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        case .solid:
            Color.appCardBackground
        case .gradient(let gradient):
            gradient
                .opacity(0.15)
                .background(Color.appCardBackground)
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .glass:
            return Color.black.opacity(0.08)
        case .solid:
            return Color.black.opacity(0.05)
        case .gradient:
            return Color.black.opacity(0.1)
        }
    }
}

enum CardStyle {
    case glass
    case solid
    case gradient(LinearGradient)
}
