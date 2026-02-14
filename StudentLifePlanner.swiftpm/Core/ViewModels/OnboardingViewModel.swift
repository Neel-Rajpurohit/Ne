import SwiftUI
import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var age: Int = 18
    @Published var educationLevel: String = "University"
    @Published var currentStep: Int = 0
    @Published var isOnboardingComplete: Bool = false
    
    let educationLevels = ["Middle School", "High School", "College", "University", "Professional"]
    
    func nextStep() {
        if currentStep < 2 {
            currentStep += 1
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        let profile = StudentProfile(age: age, educationLevel: educationLevel, isOnboardingComplete: true)
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "user_profile")
        }
        isOnboardingComplete = true
    }
}
