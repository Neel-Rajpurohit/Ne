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
                    VStack(spacing: 24) {
                        // Hero total points with animation
                        AnimatedStatCard(
                            title: "Total Points",
                            value: pointsManager.getTotalPoints(),
                            icon: "star.circle.fill",
                            gradient: .accentGradient
                        )
                        .padding(.horizontal)
                        
                        // Performance level badge
                        GlassCard {
                            HStack(spacing: 12) {
                                Image(systemName: "trophy.fill")
                                    .font(.title2)
                                    .foregroundStyle(LinearGradient.warmGradient)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Performance Level")
                                        .font(.appCaption)
                                        .foregroundColor(.appTextSecondary)
                                    
                                    Text(pointsManager.getPerformanceLevel())
                                        .font(.appTitle2)
                                        .foregroundStyle(LinearGradient.warmGradient)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Stats grid with glassmorphism
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            // Streak card
                            GlassCard {
                                VStack(spacing: 12) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.orange, .red],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    
                                    Text("\(calendarService.getCurrentStreak())")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(LinearGradient.warmGradient)
                                    
                                    Text("Current Streak")
                                        .font(.appCaption)
                                        .foregroundColor(.appTextSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .staggeredAppearance(index: 0, total: 4)
                            
                            // Best streak card
                            GlassCard {
                                VStack(spacing: 12) {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(LinearGradient.accentGradient)
                                    
                                    Text("\(calendarService.getLongestStreak())")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(LinearGradient.accentGradient)
                                    
                                    Text("Best Streak")
                                        .font(.appCaption)
                                        .foregroundColor(.appTextSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .staggeredAppearance(index: 1, total: 4)
                            
                            // Week points card
                            let weeklyStats = calendarService.getWeeklyStats()
                            GlassCard {
                                VStack(spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(LinearGradient.primaryGradient)
                                    
                                    Text("\(weeklyStats.totalPoints)")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(LinearGradient.primaryGradient)
                                    
                                    Text("Week Points")
                                        .font(.appCaption)
                                        .foregroundColor(.appTextSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .staggeredAppearance(index: 2, total: 4)
                            
                            // Focus time card
                            GlassCard {
                                VStack(spacing: 12) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(LinearGradient.successGradient)
                                    
                                    Text(timerViewModel.getTodayFocusTime())
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(LinearGradient.successGradient)
                                    
                                    Text("Focus Time")
                                        .font(.appCaption)
                                        .foregroundColor(.appTextSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .staggeredAppearance(index: 3, total: 4)
                        }
                        .padding(.horizontal)
                        
                        // Monthly completion with gradient progress bar
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("This Month")
                                            .font(.appHeadline)
                                            .foregroundColor(.appText)
                                        
                                        Text("Completion Rate")
                                            .font(.appCaption)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(Int(calendarService.getMonthlyCompletionRate() * 100))%")
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundStyle(LinearGradient.primaryGradient)
                                }
                                
                                // Gradient progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 12)
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(LinearGradient.primaryGradient)
                                            .frame(width: geometry.size.width * calendarService.getMonthlyCompletionRate(), height: 12)
                                            .shadow(color: .purple.opacity(0.5), radius: 4)
                                    }
                                }
                                .frame(height: 12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Quick links with enhanced design
                        VStack(spacing: 12) {
                            NavigationLink(destination: CalendarView()) {
                                GlassCard {
                                    HStack(spacing: 16) {
                                        Image(systemName: "calendar")
                                            .font(.title2)
                                            .foregroundStyle(LinearGradient.primaryGradient)
                                        
                                        Text("View Calendar")
                                            .font(.appHeadline)
                                            .foregroundColor(.appText)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: FocusSessionView(viewModel: timerViewModel)) {
                                GlassCard {
                                    HStack(spacing: 16) {
                                        Image(systemName: "chart.bar.fill")
                                            .font(.title2)
                                            .foregroundStyle(LinearGradient.successGradient)
                                        
                                        Text("Study Sessions")
                                            .font(.appHeadline)
                                            .foregroundColor(.appText)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
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
