import SwiftUI

@main
struct StudentLifePlannerApp: App {
    @StateObject private var profileManager = ProfileManager.shared
    @StateObject private var themeManager = AppThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            if profileManager.hasOnboarded {
                ContentView()
                    .preferredColorScheme(themeManager.colorScheme)
            } else {
                OnboardingView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
