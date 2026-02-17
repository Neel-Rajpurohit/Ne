import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @AppStorage("isOnboardingComplete") var isOnboardingComplete: Bool = false
    
    // Data
    @Published var name: String = ""
    @Published var educationType: UserProfile.EducationType = .school
    
    @Published var schoolStartTime: Date = DateHelper.shared.createDate(hour: 8, minute: 0)
    @Published var schoolEndTime: Date = DateHelper.shared.createDate(hour: 14, minute: 0)
    
    @Published var hasTuition: Bool = false
    @Published var tuitionStartTime: Date = DateHelper.shared.createDate(hour: 16, minute: 0)
    @Published var tuitionEndTime: Date = DateHelper.shared.createDate(hour: 18, minute: 0)
    
    @Published var hasExtraClasses: Bool = false
    @Published var extraStartTime: Date = DateHelper.shared.createDate(hour: 19, minute: 0)
    @Published var extraEndTime: Date = DateHelper.shared.createDate(hour: 20, minute: 0)
    
    @Published var breakfastTime: Date = DateHelper.shared.createDate(hour: 8, minute: 0)
    @Published var lunchTime: Date = DateHelper.shared.createDate(hour: 13, minute: 0)
    @Published var dinnerTime: Date = DateHelper.shared.createDate(hour: 20, minute: 0)
    
    enum OnboardingStep {
        case welcome
        case profile
        case schoolTiming
        case tuitionTiming
        case extraTiming
        case mealTiming
        case completion
    }
    
    func nextStep() {
        switch currentStep {
        case .welcome: currentStep = .profile
        case .profile: currentStep = .schoolTiming
        case .schoolTiming: currentStep = .tuitionTiming
        case .tuitionTiming: currentStep = .extraTiming
        case .extraTiming: currentStep = .mealTiming
        case .mealTiming: currentStep = .completion
        case .completion: finishOnboarding()
        @unknown default: break
        }
    }
    
    func finishOnboarding() {
        let storage = LocalStorageService.shared
        
        let profile = UserProfile(name: name, educationType: educationType, isOnboardingComplete: true)
        storage.saveUserProfile(profile)
        
        let inst = InstitutionSchedule(startTime: schoolStartTime, endTime: schoolEndTime)
        storage.saveInstitutionSchedule(inst)
        
        let tuit = TuitionSchedule(hasTuition: hasTuition, startTime: hasTuition ? tuitionStartTime : nil, endTime: hasTuition ? tuitionEndTime : nil)
        storage.saveTuitionSchedule(tuit)
        
        let extra = ExtraClassSchedule(hasExtraClasses: hasExtraClasses, startTime: hasExtraClasses ? extraStartTime : nil, endTime: hasExtraClasses ? extraEndTime : nil)
        storage.saveExtraClassSchedule(extra)
        
        let meals = MealSchedule(breakfastTime: breakfastTime, lunchTime: lunchTime, dinnerTime: dinnerTime)
        storage.saveMealSchedule(meals)
        
        // Generate initial plan
        let plan = PlannerGeneratorService.shared.generatePlan(for: Date())
        storage.saveDailyPlans([plan])
        
        isOnboardingComplete = true
        
        // Trigger app state change (handled in App file)
        objectWillChange.send()
    }
}
