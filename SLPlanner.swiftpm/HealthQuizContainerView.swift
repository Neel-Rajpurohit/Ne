import SwiftUI

// MARK: - Health & Quiz Container View
struct HealthQuizContainerView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.mainGradient.ignoresSafeArea()
                
                TabView(selection: $selectedTab) {
                    // Slide 0: Health
                    HealthOverviewView()
                        .tag(0)
                    
                    // Slide 1: Quiz & Games
                    QuizHomeView()
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: selectedTab)
            }
            .navigationTitle(selectedTab == 0 ? "Health" : "Quiz & Games")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
