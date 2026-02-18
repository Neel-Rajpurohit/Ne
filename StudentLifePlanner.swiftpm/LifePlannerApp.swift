import SwiftUI

@main
struct LifePlannerApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var appRouter = AppRouter()
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(appRouter)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        }
    }
}
