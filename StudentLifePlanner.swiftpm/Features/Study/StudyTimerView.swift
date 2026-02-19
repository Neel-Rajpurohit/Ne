import SwiftUI

struct StudyTimerView: View {
    @State private var timeRemaining = 25 * 60
    @State private var timerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 40) {
                    Text("Study Focus")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 20)
                            .frame(width: 250, height: 250)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(25 * 60))
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                        
                        Text(timeString(timeRemaining))
                            .font(.system(size: 60, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    VStack(spacing: 20) {
                        Button(action: { timerRunning.toggle() }) {
                            Text(timerRunning ? "Stop Session" : "Start Focus Session")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(timerRunning ? Color.red.opacity(0.8) : AppColors.primary)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [AppColors.accent.opacity(0.3), .clear]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                        }
                        .padding(.horizontal, 40)
                        
                        Button(action: {
                            timeRemaining = 25 * 60
                            timerRunning = false
                        }) {
                            Label("Reset Timer", systemImage: "arrow.clockwise")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(timerRunning ? "Focus on your task..." : "Get ready to celebrate focus!")
                        .foregroundColor(Color(hex: "1E293B").opacity(0.6))
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
            .navigationBarHidden(true)
            .onReceive(timer) { _ in
                if timerRunning && timeRemaining > 0 {
                    timeRemaining -= 1
                } else if timeRemaining == 0 {
                    timerRunning = false
                }
            }
        }
    }
    
    func timeString(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
