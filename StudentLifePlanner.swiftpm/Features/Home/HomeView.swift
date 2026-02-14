import SwiftUI

struct HomeView: View {
    @StateObject var routineViewModel = RoutineViewModel()
    @StateObject var timerViewModel = StudyTimerViewModel()
    private let pointsManager = PointsManager.shared
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Points Section
                        VStack(spacing: 16) {
                            // Large animated points display
                            AnimatedStatCard(
                                title: "Total Points",
                                value: pointsManager.getTotalPoints(),
                                icon: "star.circle.fill",
                                gradient: .accentGradient
                            )
                            .staggeredAppearance(index: 0, total: 5)
                            
                            // Performance level badge
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(LinearGradient.warmGradient)
                                
                                Text(pointsManager.getPerformanceLevel())
                                    .font(.appHeadline)
                                    .foregroundStyle(LinearGradient.warmGradient)
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                                    .fill(Color.white.opacity(0.2))
                                    .background(.ultraThinMaterial)
                            )
                            .cornerRadius(Constants.cardCornerRadius)
                            .shadow(color: Color.orange.opacity(0.2), radius: 10)
                            .staggeredAppearance(index: 1, total: 5)
                        }
                        .padding(.horizontal)
                        
                        // Today's Schedule Preview
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "calendar.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(LinearGradient.primaryGradient)
                                
                                Text("Today's Schedule")
                                    .font(.appTitle2)
                                    .foregroundColor(.appText)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            TodayScheduleView()
                                .staggeredAppearance(index: 2, total: 5)
                        }
                        
                        // Quick Actions
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "bolt.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(LinearGradient.successGradient)
                                
                                Text("Quick Actions")
                                    .font(.appTitle2)
                                    .foregroundColor(.appText)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            QuickActionsView()
                                .staggeredAppearance(index: 3, total: 5)
                        }
                        
                        // Motivational Section with Glassmorphism
                        GlassCard {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient.coolGradient)
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "hands.sparkles.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Keep Going!")
                                        .font(.appHeadline)
                                        .foregroundColor(.appText)
                                    
                                    Text("Consistency is the key to success.")
                                        .font(.appBody)
                                        .foregroundColor(.appTextSecondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        .staggeredAppearance(index: 4, total: 5)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Home")
        }
        .onAppear {
            isAnimating = true
        }
    }
}
