import SwiftUI

// MARK: - Content View (Main Tab Shell)
struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var game = GameEngineManager.shared
    @StateObject private var taskManager = TaskCompletionManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
                
                TimetableView()
                    .tabItem { Label("Timetable", systemImage: "calendar") }.tag(1)
                
                HealthOverviewView()
                    .tabItem { Label("Health", systemImage: "heart.fill") }.tag(2)
                
                CalendarView()
                    .tabItem { Label("Calendar", systemImage: "calendar.badge.plus") }.tag(3)
                
                GamificationView()
                    .tabItem { Label("Profile", systemImage: "person.fill") }.tag(4)
            }
            .tint(tabTint)
            
            // Confetti overlay
            ConfettiView(isActive: $taskManager.showConfetti)
            
            // Task Completion Toast
            if let completedTask = taskManager.lastCompletedTask, taskManager.showConfetti {
                VStack {
                    TaskCompletionToast(task: completedTask)
                    Spacer()
                }
                .padding(.top, 50)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.5), value: taskManager.showConfetti)
            }
            
            // XP Popup
            if game.showXPPopup {
                xpPopup
            }
            
            // Morning Greeting Overlay
            if taskManager.showMorningGreeting {
                morningGreetingOverlay
            }
        }
        .onAppear {
            PlannerEngine.shared.generateToday()
            taskManager.startMonitoring()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                // Phone going off / app closing → mark sleep if it's nighttime
                taskManager.completeSleepIfNeeded()
            } else if newPhase == .active {
                // App opening → check wake-up and auto-complete
                taskManager.onAppBecameActive()
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
    
    // MARK: - Morning Greeting
    private var morningGreetingOverlay: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Text("☀️")
                    .font(.system(size: 50))
                
                Text("Good Morning!")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Start your day with us 🌟")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(ProfileManager.shared.profile.name.isEmpty ? "" : "Let's go, \(ProfileManager.shared.profile.name)!")
                    .font(.system(.headline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.warmOrange)
            }
            .padding(40)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                    .shadow(color: AppTheme.warmOrange.opacity(0.3), radius: 20)
            )
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5).ignoresSafeArea())
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
        .onTapGesture {
            withAnimation(.spring(response: 0.4)) {
                taskManager.showMorningGreeting = false
                taskManager.greetingDismissed = true
            }
        }
    }
}
