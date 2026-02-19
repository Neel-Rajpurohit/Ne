import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    @AppStorage("isOnboardingComplete") var isOnboardingComplete: Bool = false
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    
    var body: some View {
        Group {
            switch appRouter.currentRoot {
            case .introduction:
                IntroductionContainerView(onFinish: {
                    Task { @MainActor in
                        hasSeenIntro = true
                        appRouter.navigate(to: .onboarding)
                    }
                })
            case .onboarding:
                WelcomeView()
            case .mainTab:
                DashboardView()
            }
        }
        .onAppear {
            if isOnboardingComplete {
                appRouter.currentRoot = .mainTab
            } else if !hasSeenIntro {
                appRouter.currentRoot = .introduction
            } else {
                appRouter.currentRoot = .onboarding
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
