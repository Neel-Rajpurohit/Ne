import SwiftUI

struct HomeView: View {
    @StateObject var routineViewModel = RoutineViewModel()
    @StateObject var timerViewModel = StudyTimerViewModel()
    private let pointsManager = PointsManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Points Card
                        InfoCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your Points")
                                        .font(.appHeadline)
                                        .foregroundColor(.appTextSecondary)
                                    
                                    Text("\(pointsManager.getTotalPoints())")
                                        .font(.appPoints)
                                        .foregroundColor(.appAccent)
                                    
                                    Text(pointsManager.getPerformanceLevel())
                                        .font(.appCallout)
                                        .foregroundColor(.appSuccess)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "star.circle.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(.appAccent.opacity(0.3))
                            }
                        }
                        
                        // Today's Schedule Preview
                        TodayScheduleView()
                        
                        // Quick Actions
                        QuickActionsView()
                        
                        // Motivational message
                        InfoCard {
                            HStack {
                                Image(systemName: "hands.sparkles.fill")
                                    .font(.title)
                                    .foregroundColor(.appSecondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Keep Going!")
                                        .font(.appHeadline)
                                        .foregroundColor(.appText)
                                    
                                    Text("Consistency is the key to success.")
                                        .font(.appCaption)
                                        .foregroundColor(.appTextSecondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
        }
    }
}
