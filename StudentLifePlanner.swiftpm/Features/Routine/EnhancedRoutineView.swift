import SwiftUI

struct EnhancedRoutineView: View {
    @StateObject var viewModel = RoutineViewModel()
    @State private var showingSubmissionAlert = false
    
    private var tasksByCategory: [(category: RoutineCategory, tasks: [RoutineTask])] {
        let categories = RoutineCategory.allCases
        return categories.compactMap { category in
            let filtered = viewModel.tasks.filter { $0.category == category }
            return filtered.isEmpty ? nil : (category, filtered)
        }
    }
    
    var body: some View {
        ZStack {
            AppBackground(style: .default)
            
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress overview
                        InfoCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Today's Progress")
                                        .font(.appHeadline)
                                        .foregroundColor(.appText)
                                    
                                    let completed = viewModel.tasks.filter { $0.isCompleted }.count
                                    let total = viewModel.tasks.count
                                    
                                    Text("\(completed) / \(total) tasks")
                                        .font(.appTitle)
                                        .foregroundColor(.appPrimary)
                                }
                                
                                Spacer()
                                
                                ProgressRing(
                                    progress: viewModel.tasks.isEmpty ? 0 : Double(viewModel.tasks.filter { $0.isCompleted }.count) / Double(viewModel.tasks.count),
                                    size: 60
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Tasks by category
                        ForEach(tasksByCategory, id: \.category) { item in
                            CategorySection(category: item.category, tasks: item.tasks, viewModel: viewModel)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Submit button
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
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingSubmissionAlert) {
            Alert(
                title: Text("Well Done!"),
                message: Text("Points have been added to your profile. Keep it up!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct CategorySection: View {
    let category: RoutineCategory
    let tasks: [RoutineTask]
    @ObservedObject var viewModel: RoutineViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)
                
                Text(category.rawValue)
                    .font(.appTitle2)
                    .foregroundColor(.appText)
            }
            .padding(.horizontal)
            
            ForEach(tasks) { task in
                RoutineRow(task: task) {
                    viewModel.toggleTaskCompletion(taskId: task.id)
                }
            }
        }
    }
}
