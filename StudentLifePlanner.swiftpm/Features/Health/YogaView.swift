import SwiftUI

struct YogaView: View {
    let poses = [
        ("Mountain Pose", "Tadasana"),
        ("Tree Pose", "Vrikshasana"),
        ("Triangle Pose", "Trikonasana"),
        ("Child's Pose", "Balasana")
    ]
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 20) {
                Text("Yoga & Mindfulness")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Hold each pose for 10-15 deep breaths.")
                    .foregroundColor(AppColors.textPrimary.opacity(0.7))
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(poses, id: \.0) { pose in
                            InfoCard {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(pose.0)
                                            .font(.headline)
                                        Text(pose.1)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "figure.yoga")
                                        .foregroundColor(.purple)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                NavigationLink(destination: ProofUploadView(onComplete: {})) {
                    Text("Session Done")
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
