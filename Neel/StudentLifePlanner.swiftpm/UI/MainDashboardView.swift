import SwiftUI

struct MainDashboardView: View {
    var body: some View {
        TabView {
            RoutineView()
                .tabItem {
                    Label("Routine", systemImage: "calendar")
                }
            
            ExerciseYogaView()
                .tabItem {
                    Label("Exercise", systemImage: "figure.walk")
                }
            
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
        }
        .accentColor(.appPrimary)
    }
}
