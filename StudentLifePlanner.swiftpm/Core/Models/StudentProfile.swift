import Foundation

struct StudentProfile: Codable {
    var age: Int
    var educationLevel: String
    var isOnboardingComplete: Bool
    var hasTimetable: Bool
    var notificationsEnabled: Bool
    var name: String?
    
    init(age: Int, educationLevel: String, isOnboardingComplete: Bool, hasTimetable: Bool = false, notificationsEnabled: Bool = true, name: String? = nil) {
        self.age = age
        self.educationLevel = educationLevel
        self.isOnboardingComplete = isOnboardingComplete
        self.hasTimetable = hasTimetable
        self.notificationsEnabled = notificationsEnabled
        self.name = name
    }
    
    static let defaultProfile = StudentProfile(age: 18, educationLevel: "University", isOnboardingComplete: false)
}
