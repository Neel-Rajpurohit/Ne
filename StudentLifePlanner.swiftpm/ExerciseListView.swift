import SwiftUI

// MARK: - Exercise List View
struct ExerciseListView: View {
    @State private var selectedCategory: ExerciseCategory?
    @State private var selectedDifficulty: ExerciseDifficulty?
    @State private var appeared = false
    
    var filteredExercises: [ExerciseModel] {
        var result = ExerciseModel.exercises
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        if let diff = selectedDifficulty {
            result = result.filter { $0.difficulty == diff }
        }
        return result
    }
    
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterButton(label: "All", icon: "square.grid.2x2", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            filterButton(label: cat.rawValue, icon: cat.icon, isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                            }
                        }
                    }
                }
                
                // Difficulty Sub-filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        miniFilter(label: "All Levels", isSelected: selectedDifficulty == nil) { selectedDifficulty = nil }
                        ForEach(ExerciseDifficulty.allCases, id: \.self) { diff in
                            miniFilter(label: diff.rawValue, isSelected: selectedDifficulty == diff) { selectedDifficulty = diff }
                        }
                    }
                }
                
                // 2-Column Grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredExercises) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            exerciseGridCard(exercise)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
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
    
    // MARK: - Grid Card
    private func exerciseGridCard(_ exercise: ExerciseModel) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(exercise.category.color.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: exercise.icon)
                    .font(.title3)
                    .foregroundStyle(exercise.category.color)
            }
            
            Text(exercise.name)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(exercise.muscleGroup)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(AppTheme.textTertiary)
            
            HStack(spacing: 3) {
                ForEach(0..<exercise.difficulty.dots, id: \.self) { _ in
                    Circle().fill(exercise.difficulty.color).frame(width: 6, height: 6)
                }
                Text("• \(exercise.sets)×\(exercise.reps)")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .glassBackground(cornerRadius: 16)
    }
    
    // MARK: - Filter Buttons
    private func filterButton(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { action(); HapticManager.selection() }) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption2)
                Text(label).font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.textSecondary)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(isSelected ? AnyShapeStyle(AppTheme.fitnessGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
            .clipShape(Capsule())
        }
    }
    
    private func miniFilter(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { action(); HapticManager.selection() }) {
            Text(label)
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(isSelected ? .white : AppTheme.textTertiary)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                .clipShape(Capsule())
        }
    }
}
