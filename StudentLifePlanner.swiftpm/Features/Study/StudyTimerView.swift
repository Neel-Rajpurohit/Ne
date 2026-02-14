import SwiftUI

struct StudyTimerView: View {
    @StateObject var viewModel = StudyTimerViewModel()
    
    var body: some View {
        ZStack {
            AppBackground(style: .study)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Timer Display
                TimerCircle(
                    progress: viewModel.progress,
                    timeString: viewModel.formattedTime,
                    isFocusMode: viewModel.isFocusMode
                )
                
                // Session info
                Text(viewModel.sessionInfo)
                    .font(.appTitle2)
                    .foregroundColor(.appTextSecondary)
                
                Spacer()
                
                // Controls
                HStack(spacing: 20) {
                    // Reset button
                    Button(action: {
                        viewModel.resetTimer()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .foregroundColor(.appPrimary)
                            .frame(width: 60, height: 60)
                            .background(Color.appCardBackground)
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // Play/Pause button
                    Button(action: {
                        if viewModel.isRunning {
                            viewModel.pauseTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }) {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(viewModel.isFocusMode ? Color.appPrimary : Color.appSuccess)
                            .cornerRadius(40)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                    }
                    
                    // Info button (navigate to sessions)
                    NavigationLink(destination: FocusSessionView(viewModel: viewModel)) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title)
                            .foregroundColor(.appPrimary)
                            .frame(width: 60, height: 60)
                            .background(Color.appCardBackground)
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .navigationTitle("Study Timer")
        .navigationBarTitleDisplayMode(.inline)
    }
}
