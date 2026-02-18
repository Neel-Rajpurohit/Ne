import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity
    let onToggle: () -> Void
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 30) {
                InfoCard {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text(activity.title)
                                .font(.title2.bold())
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Image(systemName: activityIcon)
                                .font(.title)
                                .foregroundColor(AppColors.primary)
                        }
                        
                        Divider()
                        
                        HStack {
                            Label(DateHelper.shared.formatTime(activity.startTime), systemImage: "clock")
                            Text("-")
                            Text(DateHelper.shared.formatTime(activity.endTime))
                        }
                        .font(.headline)
                        .foregroundColor(Color(hex: "1E293B").opacity(0.6))
                        
                        Text("Task Details")
                            .font(.headline)
                            .foregroundColor(Color(hex: "1E293B"))
                            .padding(.top)
                        
                        Text(taskDescription)
                            .font(.body)
                            .foregroundColor(Color(hex: "1E293B").opacity(0.8))
                    }
                }
                .padding()
                
                if !activity.isCompleted {
                    if activity.requiresVerification {
                        NavigationLink(destination: ProofUploadView(onComplete: onToggle)) {
                            verificationButtonLabel(title: "Verify & Complete Task")
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: onToggle) {
                            verificationButtonLabel(title: "Complete Task")
                        }
                        .padding(.horizontal)
                    }
                } else {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Activity Completed")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Capsule().stroke(Color.green, lineWidth: 2))
                }
                
                Spacer()
            }
        }
    }
    
    private func verificationButtonLabel(title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primary)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.5), .clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    var activityIcon: String {
        switch activity.type {
        case .study: return "book.fill"
        case .exercise: return "figure.cross.training"
        case .yoga: return "figure.yoga"
        case .breathing: return "wind"
        case .game: return "gamecontroller.fill"
        default: return "calendar"
        }
    }
    
    var taskDescription: String {
        switch activity.type {
        case .study: return "Focused study session. Use the Pomodoro technique for best results."
        case .exercise: return "Keep your body moving. Consistency is key to long-term health."
        case .yoga: return "Connect with your breath and improve flexibility."
        case .breathing: return "Take a moment to center yourself and reduce stress."
        case .game: return "A 5-minute mind game to refresh your brain and boost productivity."
        default: return "Attend your scheduled session and stay engaged."
        }
    }
}
