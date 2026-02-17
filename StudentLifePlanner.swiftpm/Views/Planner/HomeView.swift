import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Hello, \(viewModel.profile?.name ?? "Student")")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "1E293B"))
                                Text("Happy Holi! Stay vibrant today.")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(AppColors.primary.opacity(0.8))
                            }
                            Spacer()
                            NavigationLink(destination: PointsDetailView(viewModel: viewModel)) {
                                PointsView(points: viewModel.points.balance)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Progress Section
                        InfoCard {
                            HStack(spacing: 20) {
                                ProgressRing(progress: viewModel.completionProgress, size: 100)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Daily Progress")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("\(viewModel.dailyPlan?.activities.filter { $0.isCompleted }.count ?? 0) of \(viewModel.dailyPlan?.activities.count ?? 0) tasks done")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Access Panel
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Access Panel")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            HStack(spacing: 15) {
                                NavigationLink(destination: StudyTimerView()) {
                                    CompactActionCard(title: "Study", icon: "timer", color: .orange)
                                }
                                NavigationLink(destination: CalendarView()) {
                                    CompactActionCard(title: "Progress", icon: "chart.bar.fill", color: .purple)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Upcoming Task or Game Suggestion
                        if let nextTask = viewModel.dailyPlan?.activities.first(where: { !$0.isCompleted && $0.startTime > Date() }) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(nextTask.type == .game ? "Want a Refresh?" : "Next Up")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                if nextTask.type == .game {
                                    NavigationLink(destination: GameMenuView()) {
                                        InfoCard {
                                            HStack(spacing: 15) {
                                                ZStack {
                                                    Circle()
                                                        .fill(AppColors.accent.opacity(0.2))
                                                        .frame(width: 50, height: 50)
                                                    Image(systemName: "gamecontroller.fill")
                                                        .foregroundColor(AppColors.accent)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Play a 5-minute Mind Game?")
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                    Text("Refresh your brain before the next session")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                } else {
                                    InfoCard {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(nextTask.title)
                                                    .font(.headline)
                                                Text("\(DateHelper.shared.formatTime(nextTask.startTime)) - \(DateHelper.shared.formatTime(nextTask.endTime))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct PointsView: View {
    let points: Int
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .foregroundColor(AppColors.accent)
            Text("\(points)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "1E293B"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ZStack {
                BlurView(style: .systemThinMaterialLight)
                Capsule()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .clipShape(Capsule())
    }
}

struct CompactActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.secondary.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(AppColors.accent)
            }
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "1E293B"))
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
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
