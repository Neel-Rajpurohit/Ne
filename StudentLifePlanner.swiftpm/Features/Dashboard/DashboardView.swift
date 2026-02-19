import SwiftUI

struct DashboardView: View {
    @StateObject private var plannerViewModel = PlannerViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: plannerViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            DailyPlannerView(viewModel: plannerViewModel)
                .tabItem {
                    Label("Planner", systemImage: "calendar")
                }
            
            HealthView()
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
            
            GameMenuView(showBackButton: false)
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
