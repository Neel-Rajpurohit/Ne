import SwiftUI

struct HealthView: View {
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Health & Wellness")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            NavigationLink(destination: ExerciseView()) {
                                HealthCard(title: "Exercise", subtitle: "Stay strong and active", icon: "figure.cross.training", color: .green)
                            }
                            
                            NavigationLink(destination: YogaView()) {
                                HealthCard(title: "Yoga", subtitle: "Balance and flexibility", icon: "figure.yoga", color: .purple)
                            }
                            
                            NavigationLink(destination: BreathingView()) {
                                HealthCard(title: "Breathing", subtitle: "Relax and refocus", icon: "wind", color: .cyan)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HealthCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "1E293B"))
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "1E293B").opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.accent.opacity(0.5))
        }
        .padding()
        .background(
            ZStack {
                BlurView(style: .systemThinMaterialLight)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            }
        )
        .cornerRadius(16)
    }
}
