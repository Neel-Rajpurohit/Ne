import SwiftUI

struct DailyPlannerView: View {
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack {
                    HStack {
                        Text("Daily Planner")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "1E293B"))
                        Spacer()
                        Text(DateHelper.shared.formatDateWithDay(Date()))
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "1E293B").opacity(0.6))
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            if let activities = viewModel.dailyPlan?.activities {
                                ForEach(activities) { activity in
                                    NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                        ActivityRow(activity: activity) {
                                            viewModel.toggleCompletion(for: activity.id)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ActivityRow: View {
    let activity: Activity
    var onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Time Indicator
            VStack {
                Text(DateHelper.shared.formatTime(activity.startTime))
                    .font(.caption.bold())
                    .foregroundColor(Color(hex: "1E293B").opacity(0.6))
                Rectangle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 2)
            }
            .frame(width: 60)
            
            // Content Card
            InfoCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.title)
                            .font(.headline)
                            .strikethrough(activity.isCompleted)
                            .foregroundColor(activity.isCompleted ? .secondary : .primary)
                        
                        Text(activity.type.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(typeColor.opacity(0.2))
                            .foregroundColor(typeColor)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Button(action: onToggle) {
                        Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(activity.isCompleted ? .green : AppColors.primary)
                    }
                }
            }
            .padding(.vertical, 8)
            .opacity(activity.isCompleted ? 0.8 : 1.0)
        }
    }
    
    var typeColor: Color {
        switch activity.type {
        case .study: return .blue
        case .exercise, .yoga: return .green
        case .breathing: return .cyan
        case .rest: return .orange
        case .school, .tuition, .extraClass: return .purple
        }
    }
}
