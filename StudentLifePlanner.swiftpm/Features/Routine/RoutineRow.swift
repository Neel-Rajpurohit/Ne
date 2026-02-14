import SwiftUI

struct RoutineRow: View {
    let task: RoutineTask
    let onToggle: () -> Void
    
    var body: some View {
        InfoCard {
            HStack(spacing: 15) {
                Image(systemName: categoryIcon)
                    .font(.title2)
                    .foregroundColor(.appPrimary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.appHeadline)
                        .strikethrough(task.isCompleted)
                    
                    Text(task.time)
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(task.isCompleted ? .appSuccess : .appPrimary)
                }
            }
        }
    }
    
    private var categoryIcon: String {
        switch task.category {
        case .study: return "book.fill"
        case .meal: return "fork.knife"
        case .exercise: return "figure.walk"
        case .relaxation: return "leaf.fill"
        case .sleep: return "bed.double.fill"
        }
    }
}
