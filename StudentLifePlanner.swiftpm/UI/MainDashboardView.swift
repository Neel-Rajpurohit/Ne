import SwiftUI

struct MainDashboardView: View {
    var body: some View {
        TabView {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Routine Tab
            EnhancedRoutineView()
                .tabItem {
                    Label("Routine", systemImage: "calendar")
                }
            
            // Study Tab
            NavigationView {
                StudyTimerView()
            }
            .tabItem {
                Label("Study", systemImage: "timer")
            }
            
            // Health Tab
            HealthDashboardView()
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
            
            // Progress Tab
            EnhancedProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
        }
        .accentColor(.appPrimary)
    }
}
