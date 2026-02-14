import SwiftUI
import Foundation

struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    var gradient: LinearGradient = .successGradient
    var size: CGFloat = 150
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.15)
                .foregroundStyle(gradient.opacity(0.3))
            
            // Progress ring with gradient
            Circle()
                .trim(from: 0.0, to: CGFloat(min(animatedProgress, 1.0)))
                .stroke(
                    gradient,
                    style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: 270.0))
                .shadow(color: .purple.opacity(0.5), radius: 8, x: 0, y: 0)
            
            // Percentage text
            VStack(spacing: 4) {
                Text(String(format: "%.0f%%", min(animatedProgress, 1.0) * 100.0))
                    .font(.system(size: size / 4, weight: .bold, design: .rounded))
                    .foregroundStyle(gradient)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(Animation.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(Animation.easeOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
}
