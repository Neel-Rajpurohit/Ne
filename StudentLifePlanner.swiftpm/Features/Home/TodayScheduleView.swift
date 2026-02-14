import SwiftUI

struct TodayScheduleView: View {
    @StateObject var viewModel = RoutineViewModel()
    
    private var upcomingTasks: [RoutineTask] {
        Array(viewModel.tasks.filter { !$0.isCompleted }.prefix(4))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Schedule")
                    .font(.appTitle2)
                    .foregroundColor(.appText)
                
                Spacer()
                
                NavigationLink(destination: RoutineView()) {
                    Text("View All")
                        .font(.appCallout)
                        .foregroundColor(.appPrimary)
                }
            }
            .padding(.horizontal)
            
            if upcomingTasks.isEmpty {
                InfoCard {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.appSuccess)
                        
                        Text("All tasks completed!")
                            .font(.appBody)
                            .foregroundColor(.appText)
                    }
                }
            } else {
                ForEach(upcomingTasks) { task in
                    InfoCard {
                        HStack {
                            Circle()
                                .fill(task.category.color)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .font(.appBody)
                                    .foregroundColor(.appText)
                                
                                Text(task.time)
                                    .font(.appCaption)
                                    .foregroundColor(.appTextSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .appSuccess : .appTextSecondary)
                        }
                    }
                }
            }
        }
    }
}
