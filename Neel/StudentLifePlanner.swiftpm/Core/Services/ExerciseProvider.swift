import Foundation

class ExerciseProvider {
    static func getExercises() -> [Exercise] {
        return [
            Exercise(name: "Surya Namaskar", description: "A sequence of 12 powerful yoga poses.", duration: "10 mins", category: .yoga, iconName: "figure.yoga"),
            Exercise(name: "Pushups", description: "Classic exercise for upper body strength.", duration: "5 mins", category: .fitness, iconName: "figure.strengthtraining.traditional"),
            Exercise(name: "Deep Breathing", description: "Relieve stress and improve focus.", duration: "3 mins", category: .breathing, iconName: "wind"),
            Exercise(name: "Plank", description: "Core strengthening exercise.", duration: "2 mins", category: .fitness, iconName: "figure.core.training"),
            Exercise(name: "Tadasana", description: "Mountain pose for better posture.", duration: "5 mins", category: .yoga, iconName: "figure.yoga"),
            Exercise(name: "Box Breathing", description: "Square breathing for mental clarity.", duration: "5 mins", category: .breathing, iconName: "lungs")
        ]
    }
}
