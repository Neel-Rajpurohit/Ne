import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Your Progress")
                    .font(.largeTitle)
                    .bold()
                
                HStack {
                    VStack {
                        Text("\(appState.points.totalPoints)")
                            .font(.title)
                            .bold()
                        Text("Total Points")
                            .font(.caption)
                    }
                    
                    Divider()
                    
                    VStack {
                        Text("\(appState.points.balance)")
                            .font(.title)
                            .bold()
                        Text("Balance")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}
