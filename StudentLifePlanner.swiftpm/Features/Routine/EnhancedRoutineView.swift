import SwiftUI

struct EnhancedRoutineView: View {
    @StateObject var viewModel = RoutineViewModel()
    @State private var showingSubmissionAlert = false
    @State private var showCelebration = false
    
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
                    VStack(spacing: 24) {
                        // Progress overview with glassmorphism
                        GlassCard {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(LinearGradient.successGradient)
                                        
                                        Text("Today's Progress")
                                            .font(.appHeadline)
                                            .foregroundColor(.appText)
                                    }
                                    
                                    let completed = viewModel.tasks.filter { $0.isCompleted }.count
                                    let total = viewModel.tasks.count
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("\(completed)")
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundStyle(LinearGradient.primaryGradient)
                                        
                                        Text("/ \(total)")
                                            .font(.appTitle)
                                            .foregroundColor(.appTextSecondary)
                                        
                                        Text("tasks")
                                            .font(.appBody)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                ProgressRing(
                                    progress: viewModel.tasks.isEmpty ? 0 : Double(viewModel.tasks.filter { $0.isCompleted }.count) / Double(viewModel.tasks.count),
                                    gradient: .successGradient,
                                    size: 80
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Tasks by category with enhanced design
                        ForEach(Array(tasksByCategory.enumerated()), id: \.element.category) { index, item in
                            CategorySection(category: item.category, tasks: item.tasks, viewModel: viewModel)
                                .staggeredAppearance(index: index, total: tasksByCategory.count)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Enhanced submit button with gradient
                PrimaryButton(
                    title: viewModel.canSubmit ? "Finish Day & Earn Points 🎉" : "Points Already Claimed Today",
                    action: {
                        viewModel.submitDailyRoutine()
                        showCelebration = true
                        AnimationHelpers.success()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingSubmissionAlert = true
                        }
                    },
                    gradient: viewModel.canSubmit ? .warmGradient : .primaryGradient
                )
                .disabled(!viewModel.canSubmit)
                .opacity(viewModel.canSubmit ? 1.0 : 0.6)
                .padding()
            }
        }
        .navigationTitle("Daily Routine")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingSubmissionAlert) {
            Alert(
                title: Text("Well Done! 🎉"),
                message: Text("Points have been added to your profile. Keep up the amazing work!"),
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
            // Category header with gradient
            HStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [category.color, category.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 12, height: 12)
                    .shadow(color: category.color.opacity(0.5), radius: 4)
                
                Text(category.rawValue)
                    .font(.appTitle2)
                    .foregroundColor(.appText)
                
                Spacer()
                
                // Category completion indicator
                let completed = tasks.filter { $0.isCompleted }.count
                Text("\(completed)/\(tasks.count)")
                    .font(.appCaption)
                    .foregroundColor(.appTextSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(category.color.opacity(0.15))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            ForEach(tasks) { task in
                RoutineRow(task: task) {
                    AnimationHelpers.impact(.light)
                    viewModel.toggleTaskCompletion(taskId: task.id)
                }
            }
        }
    }
}
