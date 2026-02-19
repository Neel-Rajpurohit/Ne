import SwiftUI

struct BreathingView: View {
    @State private var isInhaling = false
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 40) {
                Text("Breathing Session")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                ZStack {
                    Circle()
                        .fill(AppColors.secondary.opacity(0.3))
                        .frame(width: isInhaling ? 250 : 100, height: isInhaling ? 250 : 100)
                        .blur(radius: 20)
                    
                    Circle()
                        .stroke(AppColors.textPrimary.opacity(0.5), lineWidth: 2)
                        .frame(width: isInhaling ? 250 : 100, height: isInhaling ? 250 : 100)
                    
                    Text(isInhaling ? "Exhale" : "Inhale")
                        .font(.title2)
                        .foregroundColor(AppColors.textPrimary)
                }
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: isInhaling)
                .onAppear {
                    isInhaling = true
                }
                
                Text("Follow the circle to relax your mind focus.")
                    .foregroundColor(AppColors.textPrimary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
}
