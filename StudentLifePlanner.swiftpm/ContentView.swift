import SwiftUI

// MARK: - Content View (Main Tab Shell)
struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var game = GameEngineManager.shared
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
                
                TimetableView()
                    .tabItem { Label("Timetable", systemImage: "calendar") }.tag(1)
                
                HealthOverviewView()
                    .tabItem { Label("Health", systemImage: "heart.fill") }.tag(2)
                
                QuizHomeView()
                    .tabItem { Label("Quiz", systemImage: "brain.head.profile") }.tag(3)
                
                GamificationView()
                    .tabItem { Label("Profile", systemImage: "person.fill") }.tag(4)
            }
            .tint(tabTint)
            
            // XP Popup
            if game.showXPPopup {
                xpPopup
            }
        }
    }
    
    private var tabTint: Color {
        switch selectedTab {
        case 0: return AppTheme.neonCyan
        case 1: return AppTheme.studyBlue
        case 2: return AppTheme.healthGreen
        case 3: return AppTheme.quizPink
        case 4: return AppTheme.primaryPurple
        default: return AppTheme.neonCyan
        }
    }
    
    private var xpPopup: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill").foregroundStyle(AppTheme.warmOrange)
            Text("+\(game.lastXPGained) XP")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.warmOrange)
        }
        .padding(.horizontal, 20).padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: AppTheme.warmOrange.opacity(0.3), radius: 10)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.4), value: game.showXPPopup)
        .padding(.top, 50)
    }
}
