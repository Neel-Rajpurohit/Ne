import SwiftUI

@main
struct StudentLifePlannerApp: App {
    @StateObject private var profileManager = ProfileManager.shared
    @StateObject private var themeManager = AppThemeManager.shared
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasOnboarded {
                    ContentView()
                        .preferredColorScheme(themeManager.colorScheme)
                } else {
                    OnboardingView()
                        .preferredColorScheme(.dark)
                }
            }
            .animation(.easeInOut, value: hasOnboarded)
        }
    }
}
