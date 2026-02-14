import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var opacity: Double = 0.2
    var blur: CGFloat = 10
    
    init(opacity: Double = 0.2, blur: CGFloat = 10, @ViewBuilder content: () -> Content) {
        self.opacity = opacity
        self.blur = blur
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                ZStack {
                    // Glass effect
                    RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                        .fill(Color.white.opacity(opacity))
                        .background(.ultraThinMaterial)
                    
                    // Border glow
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
            )
            .cornerRadius(Constants.cardCornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
