import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var size: CGFloat = 150
    var thickness: CGFloat = 15
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: thickness)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [AppColors.secondary, AppColors.primary, AppColors.accent, AppColors.secondary]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 0)
            
            VStack {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Text("Completed")
                    .font(.system(size: size * 0.1))
                    .foregroundColor(Color(hex: "1E293B").opacity(0.6))
            }
        }
        .frame(width: size, height: size)
    }
}
