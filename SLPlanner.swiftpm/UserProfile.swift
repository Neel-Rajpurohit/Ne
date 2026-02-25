import Foundation
import SwiftUI

// MARK: - User Profile Model
struct UserProfile: Codable {
    var name: String
    var age: Int
    var schoolStartHour: Int
    var schoolStartMinute: Int
    var schoolEndHour: Int
    var schoolEndMinute: Int
    var hasTuition: Bool
    var tuitionStartHour: Int
    var tuitionStartMinute: Int
    var tuitionEndHour: Int
    var tuitionEndMinute: Int
    // Three meal times
    var breakfastHour: Int
    var breakfastMinute: Int
    var lunchHour: Int
    var lunchMinute: Int
    var dinnerHour: Int
    var dinnerMinute: Int
    var subjects: [String]
    var selectedCharacter: String
    var profileImageData: Data?
    
    // MARK: - Computed
    var isTeenager: Bool { age >= 13 && age <= 19 }
    var isAdult: Bool { age > 19 }
    
    var recommendedStudyMinutes: Int {
        if age < 13 { return 25 }
        if age <= 16 { return 30 }
        return 45
    }
    
    var recommendedBreakMinutes: Int { 5 }
    
    var recommendedSteps: Int {
        if age <= 8 { return 12000 }
        if age <= 13 { return 11000 }
        if age <= 18 { return 9000 }
        return 8000
    }
    
    /// Daily water goal in mL, based on age
    var recommendedWaterML: Double {
        if age <= 8 { return 1300 }
        if age <= 13 { return 1800 }
        if age <= 18 { return 2300 }
        return 2700
    }
    
    /// Daily running goal in KM, based on age
    var recommendedRunKM: Double {
        if age <= 17 { return 2.0 }
        if age <= 25 { return 3.0 }
        if age <= 40 { return 2.5 }
        return 2.0
    }
    
    /// Daily yoga goal in minutes (all ages)
    var recommendedYogaMin: Double { 15.0 }
    
    /// Daily breathing goal in minutes (all ages)
    var recommendedBreathingMin: Double { 5.0 }
    
    /// Step goal (same as recommended, fixed by age)
    var stepGoal: Int { recommendedSteps }
    /// Water goal in mL (same as recommended, fixed by age)
    var waterGoal: Double { recommendedWaterML }
    
    var schoolStartDate: Date {
        Calendar.current.date(bySettingHour: schoolStartHour, minute: schoolStartMinute, second: 0, of: Date()) ?? Date()
    }
    var schoolEndDate: Date {
        Calendar.current.date(bySettingHour: schoolEndHour, minute: schoolEndMinute, second: 0, of: Date()) ?? Date()
    }
    var tuitionStartDate: Date {
        Calendar.current.date(bySettingHour: tuitionStartHour, minute: tuitionStartMinute, second: 0, of: Date()) ?? Date()
    }
    var tuitionEndDate: Date {
        Calendar.current.date(bySettingHour: tuitionEndHour, minute: tuitionEndMinute, second: 0, of: Date()) ?? Date()
    }
    var breakfastDate: Date {
        Calendar.current.date(bySettingHour: breakfastHour, minute: breakfastMinute, second: 0, of: Date()) ?? Date()
    }
    var lunchDate: Date {
        Calendar.current.date(bySettingHour: lunchHour, minute: lunchMinute, second: 0, of: Date()) ?? Date()
    }
    var dinnerDate: Date {
        Calendar.current.date(bySettingHour: dinnerHour, minute: dinnerMinute, second: 0, of: Date()) ?? Date()
    }
    
    static let `default` = UserProfile(
        name: "", age: 16,
        schoolStartHour: 8, schoolStartMinute: 0,
        schoolEndHour: 14, schoolEndMinute: 30,
        hasTuition: false,
        tuitionStartHour: 16, tuitionStartMinute: 0,
        tuitionEndHour: 17, tuitionEndMinute: 0,
        breakfastHour: 7, breakfastMinute: 0,
        lunchHour: 13, lunchMinute: 0,
        dinnerHour: 19, dinnerMinute: 30,
        subjects: ["Math", "Science", "English"],
        selectedCharacter: "🦊",
        profileImageData: nil
    )
}

// MARK: - Profile Manager
@MainActor
class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    
    @Published var profile: UserProfile {
        didSet { save() }
    }
    @Published var hasOnboarded: Bool {
        didSet { UserDefaults.standard.set(hasOnboarded, forKey: "hasOnboarded") }
    }
    
    private init() {
        self.hasOnboarded = UserDefaults.standard.bool(forKey: "hasOnboarded")
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = saved
        } else {
            self.profile = .default
        }
    }
    
    func completeOnboarding(profile: UserProfile) {
        self.profile = profile
        self.hasOnboarded = true
        StorageManager.shared.updateStepGoal(profile.stepGoal)
        StorageManager.shared.updateWaterGoal(profile.waterGoal)
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
    }
}
