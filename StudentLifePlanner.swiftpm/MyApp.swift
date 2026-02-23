import SwiftUI

@main
struct StudentLifePlannerApp: App {
    @ObservedObject private var profileManager = ProfileManager.shared
    @StateObject private var themeManager = AppThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if profileManager.hasOnboarded {
                    ContentView()
                        .preferredColorScheme(themeManager.colorScheme)
                } else {
                    OnboardingView()
                        .preferredColorScheme(.dark)
                }
            }
            .animation(.easeInOut, value: profileManager.hasOnboarded)
        }
    }
}
