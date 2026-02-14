import SwiftUI

struct EnhancedProgressView: View {
    private let pointsManager = PointsManager.shared
    private let calendarService = CalendarService.shared
    @StateObject private var timerViewModel = StudyTimerViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground(style: .progress)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Total points
                        InfoCard {
                            VStack(spacing: 12) {
                                Text("Total Points")
                                    .font(.appHeadline)
                                    .foregroundColor(.appTextSecondary)
                                
                                Text("\(pointsManager.getTotalPoints())")
                                    .font(.appPoints)
                                    .foregroundColor(.appAccent)
                                
                                Text(pointsManager.getPerformanceLevel())
                                    .font(.appCallout)
                                    .foregroundColor(.appSuccess)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Stats grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(
                                title: "Current Streak",
                                value: "\(calendarService.getCurrentStreak())",
                                icon: "flame.fill",
                                color: .appSuccess
                            )
                            
                            StatCard(
                                title: "Best Streak",
                                value: "\(calendarService.getLongestStreak())",
                                icon: "trophy.fill",
                                color: .appAccent
                            )
                            
                            let weeklyStats = calendarService.getWeeklyStats()
                            StatCard(
                                title: "Week Points",
                                value: "\(weeklyStats.totalPoints)",
                                icon: "star.fill",
                                color: .appPrimary
                            )
                            
                            StatCard(
                                title: "Focus Time",
                                value: timerViewModel.getTodayFocusTime(),
                                icon: "clock.fill",
                                color: .appSecondary
                            )
                        }
                        
                        // Monthly completion
                        InfoCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("This Month")
                                        .font(.appHeadline)
                                        .foregroundColor(.appText)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(calendarService.getMonthlyCompletionRate() * 100))%")
                                        .font(.appTitle2)
                                        .foregroundColor(.appPrimary)
                                }
                                
                                SwiftUI.ProgressView(value: calendarService.getMonthlyCompletionRate())
                                    .tint(.appPrimary)
                                
                                Text("Completion Rate")
                                    .font(.appCaption)
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                        
                        // Quick links
                        VStack(spacing: 12) {
                            NavigationLink(destination: CalendarView()) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.appPrimary)
                                    
                                    Text("View Calendar")
                                        .font(.appBody)
                                        .foregroundColor(.appText)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.appTextSecondary)
                                }
                                .padding()
                                .background(Color.appCardBackground)
                                .cornerRadius(Constants.cardCornerRadius)
                            }
                            
                            NavigationLink(destination: FocusSessionView(viewModel: timerViewModel)) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(.appSecondary)
                                    
                                    Text("Study Sessions")
                                        .font(.appBody)
                                        .foregroundColor(.appText)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.appTextSecondary)
                                }
                                .padding()
                                .background(Color.appCardBackground)
                                .cornerRadius(Constants.cardCornerRadius)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .onAppear {
                timerViewModel.loadTodayStats()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        InfoCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.appTitle)
                    .foregroundColor(.appText)
                
                Text(title)
                    .font(.appCaption)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
