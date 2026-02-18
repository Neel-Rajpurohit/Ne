import SwiftUI

struct ExerciseView: View {
    let exercises = [
        ("Push Ups", "3 sets of 15"),
        ("Squats", "3 sets of 20"),
        ("Plank", "1 minute hold"),
        ("Jumping Jacks", "2 minutes")
    ]
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 20) {
                Text("Daily Exercise")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Complete these to maintain your points.")
                    .foregroundColor(AppColors.textPrimary.opacity(0.7))
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(exercises, id: \.0) { exercise in
                            InfoCard {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(exercise.0)
                                            .font(.headline)
                                        Text(exercise.1)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "figure.cross.training")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                NavigationLink(destination: ProofUploadView(onComplete: {})) {
                    Text("Complete & Take Photo Proof")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.secondary.opacity(0.5), lineWidth: 0.5)
                        )
                }
                .padding()
            }
        }
    }
}
