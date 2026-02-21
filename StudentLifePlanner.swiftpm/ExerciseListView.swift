import SwiftUI

// MARK: - Exercise List View
struct ExerciseListView: View {
    @State private var selectedDifficulty: ExerciseDifficulty?
    @State private var appeared = false
    
    var filteredExercises: [ExerciseModel] {
        if let diff = selectedDifficulty {
            return ExerciseModel.exercises.filter { $0.difficulty == diff }
        }
        return ExerciseModel.exercises
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterButton(label: "All", isSelected: selectedDifficulty == nil) { selectedDifficulty = nil }
                        ForEach(ExerciseDifficulty.allCases, id: \.self) { diff in
                            filterButton(label: diff.rawValue, isSelected: selectedDifficulty == diff) { selectedDifficulty = diff }
                        }
                    }
                }
                
                // Exercise Cards
                ForEach(filteredExercises) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        ExerciseCard(exercise: exercise)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20).padding(.top, 10)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationTitle("Exercises")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
    }
    
    private func filterButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { action(); HapticManager.selection() }) {
            Text(label).font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(isSelected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(isSelected ? AnyShapeStyle(AppTheme.fitnessGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
                .clipShape(Capsule())
        }
    }
}
