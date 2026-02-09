import Foundation

struct StudentProfile: Codable {
    var age: Int
    var educationLevel: String
    var isOnboardingComplete: Bool
    
    static let defaultProfile = StudentProfile(age: 18, educationLevel: "University", isOnboardingComplete: false)
}
