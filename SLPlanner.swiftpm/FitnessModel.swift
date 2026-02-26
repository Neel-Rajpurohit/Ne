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

// MARK: - Exercise Category
enum ExerciseCategory: String, CaseIterable, Sendable {
    case strength = "Strength"
    case cardio = "Cardio"
    case stretching = "Stretching"
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "bolt.heart.fill"
        case .stretching: return "figure.flexibility"
        }
    }
    
    var color: Color {
        switch self {
        case .strength: return Color(hex: "8B5CF6")
        case .cardio: return Color(hex: "3B82F6")
        case .stretching: return Color(hex: "F59E0B")
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
    let category: ExerciseCategory
    let instructions: String
    let sets: Int
    let reps: Int
    let correctForm: [String]
    let commonMistakes: [String]
    let breathingTip: String
    
    static let exercises: [ExerciseModel] = [
        // ─── Strength ───
        ExerciseModel(
            name: "Push-ups", icon: "figure.strengthtraining.traditional",
            duration: 60, calories: 10, difficulty: .beginner, muscleGroup: "Chest",
            category: .strength,
            instructions: "Keep your body straight. Lower chest to floor, push back up.",
            sets: 3, reps: 15,
            correctForm: ["Keep back straight", "Engage core throughout", "Elbows at 45° angle", "Neck neutral, look at floor"],
            commonMistakes: ["Hips dropping toward floor", "Flaring elbows out wide", "Half range of motion", "Not engaging core"],
            breathingTip: "Inhale as you lower down, exhale as you push up"
        ),
        ExerciseModel(
            name: "Squats", icon: "figure.strengthtraining.functional",
            duration: 60, calories: 12, difficulty: .beginner, muscleGroup: "Legs",
            category: .strength,
            instructions: "Stand feet shoulder-width apart. Lower hips back and down.",
            sets: 3, reps: 20,
            correctForm: ["Feet shoulder-width apart", "Knees track over toes", "Chest up, back straight", "Weight on heels"],
            commonMistakes: ["Knees caving inward", "Rounding lower back", "Rising onto toes", "Not going deep enough"],
            breathingTip: "Inhale as you squat down, exhale as you stand up"
        ),
        ExerciseModel(
            name: "Plank", icon: "figure.core.training",
            duration: 60, calories: 8, difficulty: .beginner, muscleGroup: "Core",
            category: .strength,
            instructions: "Hold body straight in push-up position on forearms.",
            sets: 3, reps: 1,
            correctForm: ["Body in straight line", "Forearms flat on floor", "Engage glutes and core", "Shoulders over elbows"],
            commonMistakes: ["Hips sagging down", "Hips piking up too high", "Holding breath", "Looking forward (strains neck)"],
            breathingTip: "Breathe steadily — in through nose, out through mouth"
        ),
        ExerciseModel(
            name: "Lunges", icon: "figure.walk",
            duration: 60, calories: 11, difficulty: .beginner, muscleGroup: "Legs",
            category: .strength,
            instructions: "Step forward, lower back knee toward floor. Alternate legs.",
            sets: 3, reps: 12,
            correctForm: ["Front knee at 90°", "Back knee almost touches floor", "Torso upright", "Core engaged"],
            commonMistakes: ["Front knee past toes", "Leaning forward", "Short steps", "Wobbling side to side"],
            breathingTip: "Inhale as you step forward, exhale as you push back up"
        ),
        ExerciseModel(
            name: "Tricep Dips", icon: "figure.strengthtraining.traditional",
            duration: 45, calories: 8, difficulty: .intermediate, muscleGroup: "Arms",
            category: .strength,
            instructions: "Use a chair behind you. Lower body by bending arms.",
            sets: 3, reps: 12,
            correctForm: ["Hands shoulder-width on edge", "Elbows point backward", "Lower until arms at 90°", "Keep back close to chair"],
            commonMistakes: ["Elbows flaring outward", "Shoulders shrugging up", "Going too fast", "Not full range of motion"],
            breathingTip: "Inhale as you lower, exhale as you press up"
        ),
        ExerciseModel(
            name: "Diamond Push-ups", icon: "figure.strengthtraining.traditional",
            duration: 60, calories: 12, difficulty: .advanced, muscleGroup: "Arms",
            category: .strength,
            instructions: "Push-up with hands forming a diamond shape.",
            sets: 3, reps: 10,
            correctForm: ["Hands form diamond under chest", "Elbows close to body", "Full range of motion", "Core tight throughout"],
            commonMistakes: ["Hands too far forward", "Hips dropping", "Flaring elbows", "Rushing reps"],
            breathingTip: "Inhale down slowly, exhale forcefully pushing up"
        ),
        ExerciseModel(
            name: "Superman Hold", icon: "figure.flexibility",
            duration: 30, calories: 6, difficulty: .beginner, muscleGroup: "Back",
            category: .strength,
            instructions: "Lie face down, lift arms and legs off the ground.",
            sets: 3, reps: 10,
            correctForm: ["Arms extended overhead", "Lift chest and thighs together", "Squeeze glutes at top", "Hold for 2-3 seconds"],
            commonMistakes: ["Jerking movements", "Not lifting high enough", "Bending knees", "Straining neck upward"],
            breathingTip: "Inhale to prepare, exhale as you lift, hold breath briefly"
        ),
        
        // ─── Cardio ───
        ExerciseModel(
            name: "Jumping Jacks", icon: "figure.jumprope",
            duration: 60, calories: 10, difficulty: .beginner, muscleGroup: "Full Body",
            category: .cardio,
            instructions: "Jump feet apart, arms overhead. Jump back together.",
            sets: 3, reps: 30,
            correctForm: ["Land softly on balls of feet", "Full arm extension overhead", "Keep core engaged", "Maintain rhythm"],
            commonMistakes: ["Landing flat-footed", "Arms not reaching full overhead", "Hunching shoulders", "Going too slow"],
            breathingTip: "Inhale arms up, exhale arms down — keep it rhythmic"
        ),
        ExerciseModel(
            name: "High Knees", icon: "figure.run",
            duration: 45, calories: 14, difficulty: .intermediate, muscleGroup: "Legs",
            category: .cardio,
            instructions: "Run in place, lifting knees as high as possible.",
            sets: 3, reps: 30,
            correctForm: ["Knees to hip level", "Pump arms opposite to legs", "Stay on balls of feet", "Keep chest upright"],
            commonMistakes: ["Knees not high enough", "Leaning too far back", "Flat-footed landing", "Arms not moving"],
            breathingTip: "Quick breaths — exhale every two steps"
        ),
        ExerciseModel(
            name: "Burpees", icon: "figure.jumprope",
            duration: 45, calories: 15, difficulty: .advanced, muscleGroup: "Full Body",
            category: .cardio,
            instructions: "Squat, jump feet back, push-up, jump feet forward, jump up.",
            sets: 3, reps: 10,
            correctForm: ["Full push-up at bottom", "Explosive jump at top", "Land softly in squat", "Smooth transitions"],
            commonMistakes: ["Skipping the push-up", "Not jumping high enough", "Landing with locked knees", "Arching back in plank"],
            breathingTip: "Exhale on the jump up, inhale on the way down"
        ),
        ExerciseModel(
            name: "Mountain Climbers", icon: "figure.run",
            duration: 45, calories: 12, difficulty: .intermediate, muscleGroup: "Core",
            category: .cardio,
            instructions: "In plank position, alternate bringing knees to chest.",
            sets: 3, reps: 20,
            correctForm: ["Hands under shoulders", "Core tight, hips level", "Drive knees to chest", "Stay on balls of feet"],
            commonMistakes: ["Hips bouncing up", "Not bringing knees far enough", "Head dropping", "Shifting weight backward"],
            breathingTip: "Exhale each time a knee drives forward"
        ),
        ExerciseModel(
            name: "Jump Squats", icon: "figure.jumprope",
            duration: 45, calories: 15, difficulty: .advanced, muscleGroup: "Legs",
            category: .cardio,
            instructions: "Squat down, then explode upward into a jump.",
            sets: 3, reps: 12,
            correctForm: ["Full squat depth before jump", "Arms swing for momentum", "Land softly with bent knees", "Chest stays upright"],
            commonMistakes: ["Landing with straight legs", "Not squatting deep enough", "Leaning forward", "Landing too heavily"],
            breathingTip: "Inhale in the squat, exhale explosively on the jump"
        ),
        
        // ─── Stretching ───
        ExerciseModel(
            name: "Wall Sit", icon: "figure.strengthtraining.functional",
            duration: 45, calories: 7, difficulty: .intermediate, muscleGroup: "Legs",
            category: .stretching,
            instructions: "Lean against wall with knees at 90 degrees. Hold.",
            sets: 3, reps: 1,
            correctForm: ["Back flat against wall", "Thighs parallel to floor", "Knees at 90° angle", "Feet shoulder-width apart"],
            commonMistakes: ["Sliding down too low", "Knees past toes", "Pushing off with hands", "Holding breath"],
            breathingTip: "Breathe deeply and steadily throughout the hold"
        ),
        ExerciseModel(
            name: "Bicycle Crunches", icon: "figure.core.training",
            duration: 45, calories: 9, difficulty: .intermediate, muscleGroup: "Core",
            category: .stretching,
            instructions: "Lie on back, alternate touching elbow to opposite knee.",
            sets: 3, reps: 20,
            correctForm: ["Hands behind head lightly", "Shoulder blades off floor", "Rotate torso fully", "Extend opposite leg straight"],
            commonMistakes: ["Pulling on neck", "Just moving elbows", "Not extending legs fully", "Going too fast"],
            breathingTip: "Exhale as you twist to each side"
        ),
        ExerciseModel(
            name: "Leg Raises", icon: "figure.core.training",
            duration: 45, calories: 8, difficulty: .intermediate, muscleGroup: "Core",
            category: .stretching,
            instructions: "Lie on back, raise straight legs to 90 degrees.",
            sets: 3, reps: 15,
            correctForm: ["Keep legs straight", "Lower back pressed into floor", "Controlled descent", "Stop just before floor"],
            commonMistakes: ["Arching lower back", "Bending knees", "Using momentum", "Dropping legs too fast"],
            breathingTip: "Exhale as you raise legs, inhale as you lower"
        ),
    ]
}

// MARK: - Yoga Model
struct YogaModel: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let sanskritName: String
    let icon: String
    let holdTime: Int // seconds
    let difficulty: ExerciseDifficulty
    let benefits: [String]
    let instructions: String
    let correctForm: [String]
    let contraindications: [String]
    let chakra: String?
    
    static let poses: [YogaModel] = [
        YogaModel(
            name: "Mountain Pose", sanskritName: "Tadasana",
            icon: "figure.stand", holdTime: 30, difficulty: .beginner,
            benefits: ["Posture", "Balance", "Focus"],
            instructions: "Stand tall, feet together, arms at sides. Press feet into floor.",
            correctForm: ["Weight even on both feet", "Shoulders relaxed and back", "Crown of head reaching up", "Arms active by sides"],
            contraindications: ["Headache", "Low blood pressure"],
            chakra: "Root (Muladhara)"
        ),
        YogaModel(
            name: "Warrior I", sanskritName: "Virabhadrasana I",
            icon: "figure.martial.arts", holdTime: 30, difficulty: .beginner,
            benefits: ["Strength", "Flexibility", "Stamina"],
            instructions: "Step one foot back, bend front knee 90°, arms overhead.",
            correctForm: ["Front knee over ankle", "Hips face forward", "Arms reach straight up", "Back foot at 45° angle"],
            contraindications: ["Heart problems", "High blood pressure", "Shoulder injury"],
            chakra: "Solar Plexus (Manipura)"
        ),
        YogaModel(
            name: "Warrior II", sanskritName: "Virabhadrasana II",
            icon: "figure.martial.arts", holdTime: 30, difficulty: .beginner,
            benefits: ["Legs", "Core", "Focus"],
            instructions: "Wide stance, front knee bent, arms extended to sides.",
            correctForm: ["Front knee at 90°", "Arms parallel to floor", "Gaze over front hand", "Torso centered between legs"],
            contraindications: ["Neck injury (don't turn head)", "Diarrhea"],
            chakra: "Sacral (Svadhisthana)"
        ),
        YogaModel(
            name: "Tree Pose", sanskritName: "Vrksasana",
            icon: "figure.stand", holdTime: 30, difficulty: .beginner,
            benefits: ["Balance", "Focus", "Leg Strength"],
            instructions: "Stand on one leg, other foot on inner thigh, hands in prayer.",
            correctForm: ["Foot above or below knee, never on knee", "Hips level and square", "Standing leg firm", "Core engaged for balance"],
            contraindications: ["Low blood pressure", "Insomnia"],
            chakra: "Root (Muladhara)"
        ),
        YogaModel(
            name: "Downward Dog", sanskritName: "Adho Mukha Svanasana",
            icon: "figure.flexibility", holdTime: 45, difficulty: .beginner,
            benefits: ["Stretch", "Strength", "Calm"],
            instructions: "Hands and feet on floor, hips high, body in inverted V.",
            correctForm: ["Hands shoulder-width apart", "Feet hip-width apart", "Spine long and straight", "Heels press toward floor"],
            contraindications: ["Carpal tunnel syndrome", "Late-term pregnancy", "Severe wrist injury"],
            chakra: "Third Eye (Ajna)"
        ),
        YogaModel(
            name: "Cobra Pose", sanskritName: "Bhujangasana",
            icon: "figure.flexibility", holdTime: 20, difficulty: .beginner,
            benefits: ["Spine Strength", "Flexibility", "Chest Opening"],
            instructions: "Lie face down, press hands into floor, lift chest up.",
            correctForm: ["Elbows slightly bent", "Shoulders away from ears", "Pubic bone pressed to floor", "Gaze slightly upward"],
            contraindications: ["Severe back injury", "Pregnancy", "Carpal tunnel syndrome"],
            chakra: "Heart (Anahata)"
        ),
        YogaModel(
            name: "Child's Pose", sanskritName: "Balasana",
            icon: "figure.flexibility", holdTime: 60, difficulty: .beginner,
            benefits: ["Relaxation", "Stretch", "Stress Relief"],
            instructions: "Kneel, sit on heels, stretch arms forward on floor.",
            correctForm: ["Forehead rests on floor", "Arms extended or by sides", "Hips sink to heels", "Breathe into lower back"],
            contraindications: ["Knee injury", "Pregnancy (use wide-knee variation)", "Diarrhea"],
            chakra: "Third Eye (Ajna)"
        ),
        YogaModel(
            name: "Triangle Pose", sanskritName: "Trikonasana",
            icon: "figure.flexibility", holdTime: 30, difficulty: .intermediate,
            benefits: ["Stretch", "Balance", "Core"],
            instructions: "Wide stance, reach one hand to ankle, other to sky.",
            correctForm: ["Both legs straight", "Torso extends sideways", "Top arm straight up", "Gaze upward to top hand"],
            contraindications: ["Low blood pressure", "Headache", "Heart condition"],
            chakra: "Sacral (Svadhisthana)"
        ),
        YogaModel(
            name: "Crow Pose", sanskritName: "Bakasana",
            icon: "figure.strengthtraining.functional", holdTime: 15, difficulty: .advanced,
            benefits: ["Arm Strength", "Balance", "Core"],
            instructions: "Balance on hands with knees resting on upper arms.",
            correctForm: ["Fingers spread wide", "Gaze forward (not down)", "Elbows slightly bent", "Core fully engaged"],
            contraindications: ["Wrist injury", "Carpal tunnel", "Pregnancy"],
            chakra: "Solar Plexus (Manipura)"
        ),
        YogaModel(
            name: "Pigeon Pose", sanskritName: "Eka Pada Rajakapotasana",
            icon: "figure.flexibility", holdTime: 45, difficulty: .intermediate,
            benefits: ["Hip Flexibility", "Relaxation", "Stretch"],
            instructions: "One leg bent forward, other extended back. Fold forward.",
            correctForm: ["Front shin parallel to mat edge", "Back leg straight behind", "Hips level and square", "Fold forward with flat back"],
            contraindications: ["Knee injury", "Sacroiliac injury", "Tight hips (use modification)"],
            chakra: "Sacral (Svadhisthana)"
        ),
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
