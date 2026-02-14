import Foundation

class ExerciseProvider {
    
    static func getExercises() -> [Exercise] {
        return getFitnessExercises() + getYogaExercisesAsExercise() + getBreathingExercisesAsExercise()
    }
    
    // MARK: - Fitness Exercises
    
    static func getFitnessExercises() -> [Exercise] {
        return [
            Exercise(
                name: "Jumping Jacks",
                description: "Full-body cardio exercise that increases heart rate and warms up muscles.",
                duration: "5 min",
                category: .fitness,
                iconName: "figure.run"
            ),
            Exercise(
                name: "Push-ups",
                description: "Upper body strength exercise targeting chest, shoulders, and triceps.",
                duration: "3 sets of 10",
                category: .fitness,
                iconName: "figure.strengthtraining.traditional"
            ),
            Exercise(
                name: "Squats",
                description: "Lower body exercise that strengthens legs and glutes.",
                duration: "3 sets of 15",
                category: .fitness,
                iconName: "figure.jumprope"
            ),
            Exercise(
                name: "Plank Hold",
                description: "Core strengthening exercise that improves posture and stability.",
                duration: "3 sets of 30 sec",
                category: .fitness,
                iconName: "figure.core.training"
            ),
            Exercise(
                name: "High Knees",
                description: "Cardio exercise that boosts energy and improves coordination.",
                duration: "2 min",
                category: .fitness,
                iconName: "figure.walk"
            )
        ]
    }
    
    // MARK: - Yoga Poses
    
    static func getYogaPoses() -> [YogaPose] {
        return [
            YogaPose(
                name: "Mountain Pose",
                sanskritName: "Tadasana",
                description: "Stand tall with feet together, arms at sides. Foundation pose for all standing poses.",
                benefits: "Improves posture, balance, and focus. Strengthens thighs and ankles.",
                duration: "1-2 min",
                difficulty: .beginner,
                iconName: "figure.stand"
            ),
            YogaPose(
                name: "Child's Pose",
                sanskritName: "Balasana",
                description: "Kneel and sit on heels, extend arms forward with forehead on ground. Resting pose.",
                benefits: "Relieves stress, stretches hips and thighs, calms the mind.",
                duration: "2-3 min",
                difficulty: .beginner,
                iconName: "figure.flexibility"
            ),
            YogaPose(
                name: "Downward Dog",
                sanskritName: "Adho Mukha Svanasana",
                description: "Form an inverted V-shape with hands and feet on ground, hips raised.",
                benefits: "Stretches hamstrings, strengthens arms and legs, energizes body.",
                duration: "1-2 min",
                difficulty: .beginner,
                iconName: "figure.yoga"
            ),
            YogaPose(
                name: "Warrior I",
                sanskritName: "Virabhadrasana I",
                description: "Lunge position with back foot angled, arms raised overhead.",
                benefits: "Strengthens legs, opens hips and chest, improves focus and confidence.",
                duration: "30 sec each side",
                difficulty: .intermediate,
                iconName: "figure.mind.and.body"
            ),
            YogaPose(
                name: "Tree Pose",
                sanskritName: "Vrksasana",
                description: "Stand on one leg, place other foot on inner thigh, hands in prayer position.",
                benefits: "Improves balance, strengthens legs and core, enhances concentration.",
                duration: "30-60 sec each side",
                difficulty: .intermediate,
                iconName: "figure.stand"
            ),
            YogaPose(
                name: "Cobra Pose",
                sanskritName: "Bhujangasana",
                description: "Lie on stomach, lift chest using back muscles, arms supporting gently.",
                benefits: "Strengthens spine, opens chest, improves flexibility.",
                duration: "30-60 sec",
                difficulty: .beginner,
                iconName: "figure.flexibility"
            ),
            YogaPose(
                name: "Seated Forward Bend",
                sanskritName: "Paschimottanasana",
                description: "Sit with legs extended, fold forward from hips to reach toes.",
                benefits: "Stretches spine and hamstrings, calms mind, aids digestion.",
                duration: "1-3 min",
                difficulty: .intermediate,
                iconName: "figure.flexibility"
            ),
            YogaPose(
                name: "Bridge Pose",
                sanskritName: "Setu Bandhasana",
                description: "Lie on back, lift hips while keeping shoulders on ground.",
                benefits: "Strengthens back and glutes, opens chest, relieves stress.",
                duration: "30-60 sec",
                difficulty: .beginner,
                iconName: "figure.strengthtraining.functional"
            )
        ]
    }
    
    static func getYogaExercisesAsExercise() -> [Exercise] {
        return getYogaPoses().map { pose in
            Exercise(
                name: pose.name,
                description: pose.description + " Benefits: " + pose.benefits,
                duration: pose.duration,
                category: .yoga,
                iconName: pose.iconName
            )
        }
    }
    
    // MARK: - Breathing Exercises
    
    static func getBreathingExercises() -> [BreathingExercise] {
        return [
            BreathingExercise(
                name: "Box Breathing",
                description: "Equal-part breathing technique used by Navy SEALs for stress relief.",
                benefits: "Reduces anxiety, improves focus, regulates nervous system.",
                pattern: BreathingPattern(inhale: 4, hold: 4, exhale: 4, holdAfterExhale: 4),
                totalCycles: 5,
                iconName: "square"
            ),
            BreathingExercise(
                name: "4-7-8 Breathing",
                description: "Dr. Andrew Weil's relaxation technique for better sleep.",
                benefits: "Promotes relaxation, reduces stress, helps with sleep.",
                pattern: BreathingPattern(inhale: 4, hold: 7, exhale: 8),
                totalCycles: 4,
                iconName: "moon.zzz"
            ),
            BreathingExercise(
                name: "Deep Belly Breathing",
                description: "Diaphragmatic breathing that fully engages the lungs.",
                benefits: "Lowers heart rate, reduces blood pressure, promotes calm.",
                pattern: BreathingPattern(inhale: 5, hold: 2, exhale: 5),
                totalCycles: 6,
                iconName: "wind"
            ),
            BreathingExercise(
                name: "Energizing Breath",
                description: "Quick breathing technique to boost energy and alertness.",
                benefits: "Increases energy, improves alertness, enhances focus.",
                pattern: BreathingPattern(inhale: 2, hold: 1, exhale: 2),
                totalCycles: 10,
                iconName: "bolt.fill"
            ),
            BreathingExercise(
                name: "Alternate Nostril",
                description: "Yogic breathing (Nadi Shodhana) that balances left and right brain.",
                benefits: "Balances energy, improves concentration, reduces tension.",
                pattern: BreathingPattern(inhale: 4, hold: 4, exhale: 4),
                totalCycles: 5,
                iconName: "arrow.left.arrow.right"
            )
        ]
    }
    
    static func getBreathingExercisesAsExercise() -> [Exercise] {
        return getBreathingExercises().map { breathing in
            Exercise(
                name: breathing.name,
                description: breathing.description + " Benefits: " + breathing.benefits,
                duration: "\(breathing.totalCycles) cycles",
                category: .breathing,
                iconName: breathing.iconName
            )
        }
    }
    
    // MARK: - Convenience Methods
    
    static func getExercisesBy(category: ExerciseCategory) -> [Exercise] {
        return getExercises().filter { $0.category == category }
    }
}
