import Foundation

@MainActor
class LocalStorageService {
    static let shared = LocalStorageService()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let userProfile = "user_profile"
        static let institutionSchedule = "institution_schedule"
        static let tuitionSchedule = "tuition_schedule"
        static let extraClassSchedule = "extra_class_schedule"
        static let dailyPlans = "daily_plans"
        static let points = "points"
        static let mealSchedule = "meal_schedule"
        static let weeklyTimetable = "weekly_timetable"
    }
    
    // MARK: - User Profile
    func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            defaults.set(encoded, forKey: Keys.userProfile)
        }
    }
    
    func loadUserProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: Keys.userProfile) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    // MARK: - Schedules
    func saveInstitutionSchedule(_ schedule: InstitutionSchedule) {
        if let encoded = try? JSONEncoder().encode(schedule) {
            defaults.set(encoded, forKey: Keys.institutionSchedule)
        }
    }
    
    func loadInstitutionSchedule() -> InstitutionSchedule? {
        guard let data = defaults.data(forKey: Keys.institutionSchedule) else { return nil }
        return try? JSONDecoder().decode(InstitutionSchedule.self, from: data)
    }
    
    func saveTuitionSchedule(_ schedule: TuitionSchedule) {
        if let encoded = try? JSONEncoder().encode(schedule) {
            defaults.set(encoded, forKey: Keys.tuitionSchedule)
        }
    }
    
    func loadTuitionSchedule() -> TuitionSchedule? {
        guard let data = defaults.data(forKey: Keys.tuitionSchedule) else { return nil }
        return try? JSONDecoder().decode(TuitionSchedule.self, from: data)
    }
    
    func saveExtraClassSchedule(_ schedule: ExtraClassSchedule) {
        if let encoded = try? JSONEncoder().encode(schedule) {
            defaults.set(encoded, forKey: Keys.extraClassSchedule)
        }
    }
    
    func loadExtraClassSchedule() -> ExtraClassSchedule? {
        guard let data = defaults.data(forKey: Keys.extraClassSchedule) else { return nil }
        return try? JSONDecoder().decode(ExtraClassSchedule.self, from: data)
    }
    
    // MARK: - Daily Plans
    func saveDailyPlans(_ plans: [DailyPlan]) {
        if let encoded = try? JSONEncoder().encode(plans) {
            defaults.set(encoded, forKey: Keys.dailyPlans)
        }
    }
    
    func loadDailyPlans() -> [DailyPlan] {
        guard let data = defaults.data(forKey: Keys.dailyPlans) else { return [] }
        return (try? JSONDecoder().decode([DailyPlan].self, from: data)) ?? []
    }
    
    // MARK: - Points
    func savePoints(_ points: Points) {
        if let encoded = try? JSONEncoder().encode(points) {
            defaults.set(encoded, forKey: Keys.points)
        }
    }
    
    func loadPoints() -> Points {
        guard let data = defaults.data(forKey: Keys.points) else {
            return Points(balance: 10, history: [])
        }
        return (try? JSONDecoder().decode(Points.self, from: data)) ?? Points(balance: 10, history: [])
    }
    
    // MARK: - Meals
    func saveMealSchedule(_ schedule: MealSchedule) {
        if let encoded = try? JSONEncoder().encode(schedule) {
            defaults.set(encoded, forKey: Keys.mealSchedule)
        }
    }
    
    func loadMealSchedule() -> MealSchedule? {
        guard let data = defaults.data(forKey: Keys.mealSchedule) else { return nil }
        return try? JSONDecoder().decode(MealSchedule.self, from: data)
    }
    
    // MARK: - Weekly Timetable
    func saveWeeklyTimetable(_ timetable: WeeklyTimetable) {
        if let encoded = try? JSONEncoder().encode(timetable) {
            defaults.set(encoded, forKey: Keys.weeklyTimetable)
        }
    }
    
    func loadWeeklyTimetable() -> WeeklyTimetable? {
        guard let data = defaults.data(forKey: Keys.weeklyTimetable) else { return nil }
        return try? JSONDecoder().decode(WeeklyTimetable.self, from: data)
    }
}
