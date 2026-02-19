import Foundation

struct UserProfile: Codable {
    var name: String
    var educationType: EducationType
    var isOnboardingComplete: Bool
    
    enum EducationType: String, Codable, CaseIterable {
        case school = "School"
        case college = "College"
        case university = "University"
    }
}
