import SwiftUI

struct GradientBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            AppColors.backgroundStart
                .ignoresSafeArea()
            
            // Holi Color Clouds (Gulal) in Motion
            RadialGradient(
                gradient: Gradient(colors: [AppColors.primary.opacity(0.15), .clear]),
                center: animate ? .topLeading : .top,
                startRadius: 0,
                endRadius: animate ? 600 : 400
            )
            .offset(x: animate ? -50 : 50, y: animate ? -20 : 20)
            .ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [AppColors.secondary.opacity(0.2), .clear]),
                center: animate ? .bottomTrailing : .bottom,
                startRadius: 0,
                endRadius: animate ? 700 : 500
            )
            .offset(x: animate ? 60 : -60, y: animate ? 30 : -30)
            .ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [AppColors.accent.opacity(0.15), .clear]),
                center: animate ? .center : .bottomLeading,
                startRadius: 0,
                endRadius: animate ? 500 : 300
            )
            .scaleEffect(animate ? 1.2 : 0.8)
            .ignoresSafeArea()
            
            // Powder Texture
            ForEach(0..<40, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 3, height: 3)
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}
