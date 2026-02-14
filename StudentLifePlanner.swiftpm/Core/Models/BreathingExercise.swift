import Foundation

struct BreathingPattern: Codable {
    let inhale: Int // seconds
    let hold: Int // seconds
    let exhale: Int // seconds
    let holdAfterExhale: Int // seconds (optional, for box breathing)
    
    init(inhale: Int, hold: Int, exhale: Int, holdAfterExhale: Int = 0) {
        self.inhale = inhale
        self.hold = hold
        self.exhale = exhale
        self.holdAfterExhale = holdAfterExhale
    }
}

struct BreathingExercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let benefits: String
    let pattern: BreathingPattern
    let totalCycles: Int
    let iconName: String
    
    init(name: String, description: String, benefits: String, pattern: BreathingPattern, totalCycles: Int, iconName: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.benefits = benefits
        self.pattern = pattern
        self.totalCycles = totalCycles
        self.iconName = iconName
    }
}
