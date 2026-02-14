import SwiftUI

struct AnimatedStatCard: View {
    let title: String
    let value: Int
    let icon: String
    let gradient: LinearGradient
    @State private var animatedValue: Int = 0
    @State private var isAnimating = false
    
    var body: some View {
        GlassCard {
            VStack(spacing: 12) {
                // Animated icon
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(gradient)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Animated number
                Text("\(animatedValue)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(gradient)
                
                // Title
                Text(title)
                    .font(.appCaption)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            isAnimating = true
            animateNumber()
        }
    }
    
    private func animateNumber() {
        let steps = 30
        let increment = value / steps
        let duration = 1.0
        let delay = duration / Double(steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(step)) {
                animatedValue = min(increment * step, value)
            }
        }
    }
}
