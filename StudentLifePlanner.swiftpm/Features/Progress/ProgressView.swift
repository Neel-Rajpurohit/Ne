import SwiftUI

struct ProgressView: View {
    @StateObject var viewModel = ProgressViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground()
                
                VStack(spacing: 30) {
                    InfoCard {
                        VStack(spacing: 20) {
                            Text("Your Progress")
                                .font(.appHeadline)
                            
                            ProgressRing(progress: viewModel.progressPercentage, color: .appPrimary, size: 200)
                            
                            VStack(spacing: 5) {
                                Text("\(viewModel.totalPoints) Points")
                                    .font(.appTitle)
                                    .foregroundColor(.appPrimary)
                                
                                Text(viewModel.performanceLevel)
                                    .font(.appHeadline)
                                    .foregroundColor(.appSuccess)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                    .padding()
                    
                    InfoCard {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Consistency Tips")
                                .font(.appHeadline)
                            
                            HStack(spacing: 15) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.appAccent)
                                Text("Complete all tasks to earn 10 points daily.")
                                    .font(.appBody)
                            }
                            
                            HStack(spacing: 15) {
                                Image(systemName: "timer")
                                    .foregroundColor(.appPrimary)
                                Text("Consistency is key to forming healthy habits.")
                                    .font(.appBody)
                            }
                            
                            HStack(spacing: 15) {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.appSecondary)
                                Text("Track your progress weekly to stay motivated.")
                                    .font(.appBody)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Performance")
            .onAppear {
                viewModel.refreshProgress()
            }
        }
    }
}
