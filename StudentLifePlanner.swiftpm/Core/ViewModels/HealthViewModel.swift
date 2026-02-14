import Foundation
import Combine

@MainActor
class HealthViewModel: ObservableObject {
    @Published var selectedCategory: ExerciseCategory = .yoga
    @Published var exercises: [Exercise] = []
    @Published var yogaPoses: [YogaPose] = []
    @Published var breathingExercises: [BreathingExercise] = []
    
    init() {
        loadExercises()
    }
    
    func loadExercises() {
        exercises = ExerciseProvider.getExercises()
        yogaPoses = ExerciseProvider.getYogaPoses()
        breathingExercises = ExerciseProvider.getBreathingExercises()
    }
    
    func getFilteredExercises() -> [Exercise] {
        return exercises.filter { $0.category == selectedCategory }
    }
    
    func getYogaPosesByDifficulty(_ difficulty: YogaDifficulty) -> [YogaPose] {
        return yogaPoses.filter { $0.difficulty == difficulty }
    }
    
    func getRecommendedExercise() -> Exercise? {
        // Recommend based on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 9 {
            // Morning - recommend yoga
            return exercises.filter { $0.category == .yoga }.randomElement()
        } else if hour < 17 {
            // Daytime - recommend fitness
            return exercises.filter { $0.category == .fitness }.randomElement()
        } else {
            // Evening - recommend breathing
            return exercises.filter { $0.category == .breathing }.randomElement()
        }
    }
    
    func getRecommendedYogaPose(forBeginners: Bool = true) -> YogaPose? {
        if forBeginners {
            return yogaPoses.filter { $0.difficulty == .beginner }.randomElement()
        }
        return yogaPoses.randomElement()
    }
}
