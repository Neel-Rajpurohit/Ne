import SwiftUI

struct TimerCircle: View {
    let progress: Double
    let timeString: String
    let isFocusMode: Bool
    
    private var circleColor: Color {
        isFocusMode ? .appPrimary : .appSuccess
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(circleColor.opacity(0.2), lineWidth: 20)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    circleColor,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            // Time text
            VStack(spacing: 8) {
                Text(timeString)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.appText)
                
                Text(isFocusMode ? "Focus" : "Break")
                    .font(.appHeadline)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .frame(width: 280, height: 280)
    }
}
