import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboardingComplete") var isOnboardingComplete: Bool = false
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    
    var body: some View {
        if isOnboardingComplete {
            MainTabView()
        } else if !hasSeenIntro {
            IntroductionContainerView(onFinish: {
                withAnimation {
                    hasSeenIntro = true
                }
            })
        } else {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView()
}
