import Foundation
import SwiftUI

// MARK: - Exercise Difficulty
enum ExerciseDifficulty: String, Codable, CaseIterable, Sendable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: Color {
        switch self {
        case .beginner: return Color(hex: "10B981")
        case .intermediate: return Color(hex: "F59E0B")
        case .advanced: return Color(hex: "EF4444")
        }
    }
    
    var dots: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        }
    }
}

// MARK: - Exercise Model
struct ExerciseModel: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let icon: String
    let duration: Int // seconds
    let calories: Int
    let difficulty: ExerciseDifficulty
    let muscleGroup: String
    let instructions: String
    let sets: Int
    let reps: Int
    
    static let exercises: [ExerciseModel] = [
        ExerciseModel(name: "Push-ups", icon: "figure.strengthtraining.traditional", duration: 60, calories: 10, difficulty: .beginner, muscleGroup: "Chest", instructions: "Keep your body straight. Lower chest to floor, push back up.", sets: 3, reps: 15),
        ExerciseModel(name: "Squats", icon: "figure.strengthtraining.functional", duration: 60, calories: 12, difficulty: .beginner, muscleGroup: "Legs", instructions: "Stand feet shoulder-width apart. Lower hips back and down.", sets: 3, reps: 20),
        ExerciseModel(name: "Plank", icon: "figure.core.training", duration: 60, calories: 8, difficulty: .beginner, muscleGroup: "Core", instructions: "Hold body straight in push-up position on forearms.", sets: 3, reps: 1),
        ExerciseModel(name: "Burpees", icon: "figure.jumprope", duration: 45, calories: 15, difficulty: .advanced, muscleGroup: "Full Body", instructions: "Squat, jump feet back, push-up, jump feet forward, jump up.", sets: 3, reps: 10),
        ExerciseModel(name: "Mountain Climbers", icon: "figure.run", duration: 45, calories: 12, difficulty: .intermediate, muscleGroup: "Core", instructions: "In plank position, alternate bringing knees to chest.", sets: 3, reps: 20),
        ExerciseModel(name: "Jumping Jacks", icon: "figure.jumprope", duration: 60, calories: 10, difficulty: .beginner, muscleGroup: "Full Body", instructions: "Jump feet apart, arms overhead. Jump back together.", sets: 3, reps: 30),
        ExerciseModel(name: "Lunges", icon: "figure.walk", duration: 60, calories: 11, difficulty: .beginner, muscleGroup: "Legs", instructions: "Step forward, lower back knee toward floor. Alternate legs.", sets: 3, reps: 12),
        ExerciseModel(name: "Bicycle Crunches", icon: "figure.core.training", duration: 45, calories: 9, difficulty: .intermediate, muscleGroup: "Core", instructions: "Lie on back, alternate touching elbow to opposite knee.", sets: 3, reps: 20),
        ExerciseModel(name: "Tricep Dips", icon: "figure.strengthtraining.traditional", duration: 45, calories: 8, difficulty: .intermediate, muscleGroup: "Arms", instructions: "Use a chair behind you. Lower body by bending arms.", sets: 3, reps: 12),
        ExerciseModel(name: "High Knees", icon: "figure.run", duration: 45, calories: 14, difficulty: .intermediate, muscleGroup: "Legs", instructions: "Run in place, lifting knees as high as possible.", sets: 3, reps: 30),
        ExerciseModel(name: "Superman Hold", icon: "figure.flexibility", duration: 30, calories: 6, difficulty: .beginner, muscleGroup: "Back", instructions: "Lie face down, lift arms and legs off the ground.", sets: 3, reps: 10),
        ExerciseModel(name: "Wall Sit", icon: "figure.strengthtraining.functional", duration: 45, calories: 7, difficulty: .intermediate, muscleGroup: "Legs", instructions: "Lean against wall with knees at 90 degrees. Hold.", sets: 3, reps: 1),
        ExerciseModel(name: "Diamond Push-ups", icon: "figure.strengthtraining.traditional", duration: 60, calories: 12, difficulty: .advanced, muscleGroup: "Arms", instructions: "Push-up with hands forming a diamond shape.", sets: 3, reps: 10),
        ExerciseModel(name: "Leg Raises", icon: "figure.core.training", duration: 45, calories: 8, difficulty: .intermediate, muscleGroup: "Core", instructions: "Lie on back, raise straight legs to 90 degrees.", sets: 3, reps: 15),
        ExerciseModel(name: "Jump Squats", icon: "figure.jumprope", duration: 45, calories: 15, difficulty: .advanced, muscleGroup: "Legs", instructions: "Squat down, then explode upward into a jump.", sets: 3, reps: 12),
    ]
}

// MARK: - Yoga Model
struct YogaModel: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let icon: String
    let holdTime: Int // seconds
    let difficulty: ExerciseDifficulty
    let benefits: [String]
    let instructions: String
    
    static let poses: [YogaModel] = [
        YogaModel(name: "Mountain Pose", icon: "figure.stand", holdTime: 30, difficulty: .beginner, benefits: ["Posture", "Balance", "Focus"], instructions: "Stand tall, feet together, arms at sides. Press feet into floor."),
        YogaModel(name: "Warrior I", icon: "figure.martial.arts", holdTime: 30, difficulty: .beginner, benefits: ["Strength", "Flexibility", "Stamina"], instructions: "Step one foot back, bend front knee 90°, arms overhead."),
        YogaModel(name: "Warrior II", icon: "figure.martial.arts", holdTime: 30, difficulty: .beginner, benefits: ["Legs", "Core", "Focus"], instructions: "Wide stance, front knee bent, arms extended to sides."),
        YogaModel(name: "Tree Pose", icon: "figure.stand", holdTime: 30, difficulty: .beginner, benefits: ["Balance", "Focus", "Leg Strength"], instructions: "Stand on one leg, other foot on inner thigh, hands in prayer."),
        YogaModel(name: "Downward Dog", icon: "figure.flexibility", holdTime: 45, difficulty: .beginner, benefits: ["Stretch", "Strength", "Calm"], instructions: "Hands and feet on floor, hips high, body in inverted V."),
        YogaModel(name: "Cobra Pose", icon: "figure.flexibility", holdTime: 20, difficulty: .beginner, benefits: ["Back Strength", "Flexibility", "Chest Opening"], instructions: "Lie face down, press hands into floor, lift chest up."),
        YogaModel(name: "Child's Pose", icon: "figure.flexibility", holdTime: 60, difficulty: .beginner, benefits: ["Relaxation", "Stretch", "Stress Relief"], instructions: "Kneel, sit on heels, stretch arms forward on floor."),
        YogaModel(name: "Triangle Pose", icon: "figure.flexibility", holdTime: 30, difficulty: .intermediate, benefits: ["Stretch", "Balance", "Core"], instructions: "Wide stance, reach one hand to ankle, other to sky."),
        YogaModel(name: "Crow Pose", icon: "figure.strengthtraining.functional", holdTime: 15, difficulty: .advanced, benefits: ["Arm Strength", "Balance", "Core"], instructions: "Balance on hands with knees resting on upper arms."),
        YogaModel(name: "Pigeon Pose", icon: "figure.flexibility", holdTime: 45, difficulty: .intermediate, benefits: ["Hip Flexibility", "Relaxation", "Stretch"], instructions: "One leg bent forward, other extended back. Fold forward."),
    ]
}

// MARK: - Breathing Preset
struct BreathingPreset: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let icon: String
    let inhale: Int
    let holdIn: Int
    let exhale: Int
    let holdOut: Int
    let cycles: Int
    let description: String
    
    static let presets: [BreathingPreset] = [
        BreathingPreset(name: "Box Breathing", icon: "square", inhale: 4, holdIn: 4, exhale: 4, holdOut: 4, cycles: 4, description: "Equal timing for calm focus. Used by Navy SEALs."),
        BreathingPreset(name: "4-7-8 Relaxation", icon: "moon.fill", inhale: 4, holdIn: 7, exhale: 8, holdOut: 0, cycles: 4, description: "Deep relaxation and sleep aid technique."),
        BreathingPreset(name: "Energizing Breath", icon: "bolt.fill", inhale: 2, holdIn: 0, exhale: 2, holdOut: 0, cycles: 10, description: "Quick breathing to boost energy and alertness."),
        BreathingPreset(name: "Calm Focus", icon: "brain.head.profile", inhale: 4, holdIn: 4, exhale: 6, holdOut: 2, cycles: 5, description: "Longer exhale for parasympathetic activation."),
    ]
}
