import SwiftUI
import Foundation

struct ContentView: View {
    @AppStorage("user_profile") var userProfileData: Data?
    
    var body: some View {
        Group {
            if let data = userProfileData,
               let profile = try? JSONDecoder().decode(StudentProfile.self, from: data),
               profile.isOnboardingComplete {
                MainDashboardView()
                    .transition(.opacity)
            } else {
                WelcomeView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: userProfileData)
    }
}
