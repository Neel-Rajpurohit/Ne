import SwiftUI

struct RoutineView: View {
    @StateObject var viewModel = RoutineViewModel()
    @State private var showingSubmissionAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground()
                
                VStack {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(viewModel.tasks) { task in
                                RoutineRow(task: task) {
                                    viewModel.toggleTaskCompletion(taskId: task.id)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    PrimaryButton(title: viewModel.canSubmit ? "Finish Day & Earn Points" : "Points Already Claimed Today") {
                        viewModel.submitDailyRoutine()
                        showingSubmissionAlert = true
                    }
                    .disabled(!viewModel.canSubmit)
                    .opacity(viewModel.canSubmit ? 1.0 : 0.6)
                    .padding()
                }
            }
            .navigationTitle("Daily Routine")
            .alert(isPresented: $showingSubmissionAlert) {
                Alert(
                    title: Text("Well Done!"),
                    message: Text("Points have been added to your profile. Keep it up!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
