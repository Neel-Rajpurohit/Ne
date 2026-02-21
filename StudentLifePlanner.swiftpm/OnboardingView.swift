import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @ObservedObject private var profileManager = ProfileManager.shared
    @State private var currentSlide = 0
    @State private var showForm = false
    
    // Form fields
    @State private var name = ""
    @State private var age = 16
    @State private var schoolStart = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var schoolEnd = Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: Date()) ?? Date()
    @State private var hasTuition = false
    @State private var tuitionStart = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var tuitionEnd = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()

    @State private var subjectInput = ""
    @State private var subjects: [String] = ["Math", "Science", "English"]
    @State private var breakfastTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var lunchTime = Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var dinnerTime = Calendar.current.date(bySettingHour: 19, minute: 30, second: 0, of: Date()) ?? Date()
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if !showForm {
                introSlides
            } else {
                userDetailForm
            }
        }
    }
    
    // MARK: - Intro Slides
    private var introSlides: some View {
        VStack(spacing: 30) {
            Spacer()
            
            TabView(selection: $currentSlide) {
                slideView(icon: "calendar.badge.clock", title: "Organize Your\nStudent Life", subtitle: "Smart timetable that adapts to your schedule", color: AppTheme.studyBlue).tag(0)
                slideView(icon: "timer", title: "Study Smarter\nwith 25-5 Timer", subtitle: "Pomodoro focus sessions with fun break games", color: AppTheme.primaryPurple).tag(1)
                slideView(icon: "heart.fill", title: "Balance Health\nStudy & Growth", subtitle: "Track steps, water, exercise & mental wellness", color: AppTheme.healthGreen).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 380)
            
            // Page Dots
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(i == currentSlide ? AppTheme.neonCyan : Color.white.opacity(0.3))
                        .frame(width: i == currentSlide ? 10 : 6, height: i == currentSlide ? 10 : 6)
                        .animation(.spring(response: 0.3), value: currentSlide)
                }
            }
            
            Spacer()
            
            // CTA Button
            Button(action: {
                if currentSlide < 2 {
                    withAnimation { currentSlide += 1 }
                } else {
                    withAnimation(.spring(response: 0.5)) { showForm = true }
                }
                HapticManager.impact(.medium)
            }) {
                Text(currentSlide < 2 ? "Next" : "Get Started")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(18)
                    .background(AppTheme.studyGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: AppTheme.studyBlue.opacity(0.4), radius: 10)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    private func slideView(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 140, height: 140)
                Image(systemName: icon).font(.system(size: 60)).foregroundStyle(color)
            }
            Text(title)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - User Detail Form
    private var userDetailForm: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Name + Age
                    VStack(alignment: .leading, spacing: 14) {
                        Text("About You").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill").foregroundStyle(AppTheme.studyGradient)
                            TextField("Your Name", text: $name)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        .padding(14).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        HStack {
                            Image(systemName: "number").foregroundStyle(AppTheme.neonCyan)
                            Text("Age").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Picker("Age", selection: $age) {
                                ForEach(10...30, id: \.self) { Text("\($0)").tag($0) }
                            }
                            .tint(AppTheme.neonCyan)
                        }
                        .padding(14).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(20).glassBackground()
                    
                    // Schedule
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Your Schedule").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                        
                        timePicker(label: "School Start", icon: "building.columns.fill", color: AppTheme.studyBlue, time: $schoolStart)
                        timePicker(label: "School End", icon: "building.columns", color: AppTheme.studyBlue, time: $schoolEnd)
                        
                        Divider().overlay(AppTheme.cardBorder)
                        
                        Toggle(isOn: $hasTuition) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill").foregroundStyle(AppTheme.primaryPurple)
                                Text("Tuition / Extra Class").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textPrimary)
                            }
                        }
                        .tint(AppTheme.primaryPurple)
                        
                        if hasTuition {
                            timePicker(label: "Tuition Start", icon: "clock.fill", color: AppTheme.primaryPurple, time: $tuitionStart)
                            timePicker(label: "Tuition End", icon: "clock", color: AppTheme.primaryPurple, time: $tuitionEnd)
                        }
                        
                        Divider().overlay(AppTheme.cardBorder)
                        
                        // Meal Times
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Meal Times").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.warmOrange)
                        }
                        timePicker(label: "Breakfast", icon: "sunrise.fill", color: AppTheme.warmOrange, time: $breakfastTime)
                        timePicker(label: "Lunch", icon: "fork.knife", color: AppTheme.warmOrange, time: $lunchTime)
                        timePicker(label: "Dinner", icon: "moon.fill", color: AppTheme.warmOrange, time: $dinnerTime)
                    }
                    .padding(20).glassBackground()
                    
                    // Subjects
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Subjects").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                        
                        HStack {
                            TextField("Add subject...", text: $subjectInput)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                                .padding(12).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
                            Button(action: addSubject) {
                                Image(systemName: "plus.circle.fill").font(.title2).foregroundStyle(AppTheme.studyGradient)
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(subjects, id: \.self) { subj in
                                    HStack(spacing: 6) {
                                        Text(subj).font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(.white)
                                        Button(action: { subjects.removeAll { $0 == subj } }) {
                                            Image(systemName: "xmark.circle.fill").font(.caption).foregroundStyle(.white.opacity(0.7))
                                        }
                                    }
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .background(AppTheme.studyBlue).clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(20).glassBackground()
                    
                    // Auto Goals (read-only, based on age)
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Your Daily Goals").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                        Text("Auto-set based on your age").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                        
                        let tempProfile = UserProfile.default
                        let steps = age <= 8 ? 12000 : age <= 13 ? 11000 : age <= 18 ? 9000 : 8000
                        let waterML = age <= 8 ? 1300.0 : age <= 13 ? 1800.0 : age <= 18 ? 2300.0 : 2700.0
                        
                        HStack(spacing: 14) {
                            VStack(spacing: 6) {
                                Image(systemName: "figure.walk").font(.title2).foregroundStyle(AppTheme.healthGreen)
                                Text("\(steps.formatted())").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                                Text("Steps").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity).padding(14)
                            .background(AppTheme.healthGreen.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            VStack(spacing: 6) {
                                Image(systemName: "drop.fill").font(.title2).foregroundStyle(AppTheme.neonCyan)
                                Text(waterML.asLiters).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                                Text("Water").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity).padding(14)
                            .background(AppTheme.neonCyan.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        let _ = tempProfile // suppress
                    }
                    .padding(20).glassBackground()
                    
                    // Complete
                    Button(action: completeOnboarding) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Start My Journey").font(.system(.headline, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(.white).frame(maxWidth: .infinity).padding(18)
                        .background(AppTheme.studyGradient).clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: AppTheme.studyBlue.opacity(0.4), radius: 10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.5 : 1)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20).padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    // MARK: - Helpers
    private func timePicker(label: String, icon: String, color: Color, time: Binding<Date>) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(color)
            Text(label).font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textPrimary)
            Spacer()
            DatePicker("", selection: time, displayedComponents: .hourAndMinute).labelsHidden().colorScheme(.dark).tint(color)
        }
        .padding(14).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func addSubject() {
        let trimmed = subjectInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !subjects.contains(trimmed) else { return }
        subjects.append(trimmed)
        subjectInput = ""
        HapticManager.impact(.light)
    }
    
    private func completeOnboarding() {
        let cal = Calendar.current
        let profile = UserProfile(
            name: name, age: age,
            schoolStartHour: cal.component(.hour, from: schoolStart),
            schoolStartMinute: cal.component(.minute, from: schoolStart),
            schoolEndHour: cal.component(.hour, from: schoolEnd),
            schoolEndMinute: cal.component(.minute, from: schoolEnd),
            hasTuition: hasTuition,
            tuitionStartHour: cal.component(.hour, from: tuitionStart),
            tuitionStartMinute: cal.component(.minute, from: tuitionStart),
            tuitionEndHour: cal.component(.hour, from: tuitionEnd),
            tuitionEndMinute: cal.component(.minute, from: tuitionEnd),
            breakfastHour: cal.component(.hour, from: breakfastTime),
            breakfastMinute: cal.component(.minute, from: breakfastTime),
            lunchHour: cal.component(.hour, from: lunchTime),
            lunchMinute: cal.component(.minute, from: lunchTime),
            dinnerHour: cal.component(.hour, from: dinnerTime),
            dinnerMinute: cal.component(.minute, from: dinnerTime),
            subjects: subjects
        )
        profileManager.completeOnboarding(profile: profile)
        PlannerEngine.shared.generateToday()
        HapticManager.notification(.success)
    }
}
