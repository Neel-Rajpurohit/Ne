import SwiftUI
import UserNotifications

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject private var profileManager = ProfileManager.shared
    @StateObject private var themeManager = AppThemeManager.shared
    @StateObject private var storage = StorageManager.shared
    @StateObject private var game = GameEngineManager.shared
    @State private var showResetAlert = false
    @State private var showResetOptions = false
    @State private var appeared = false
    
    // Reset option toggles
    @State private var resetStudy = false
    @State private var resetHealthXP = false
    @State private var resetCalendar = false
    @State private var resetEverything = false
    
    // Editable profile fields
    @State private var name: String = ""
    @State private var age: Int = 16

    @State private var schoolStart = Date()
    @State private var schoolEnd = Date()
    @State private var hasTuition = false
    @State private var tuitionStart = Date()
    @State private var tuitionEnd = Date()
    @State private var breakfastTime = Date()
    @State private var lunchTime = Date()
    @State private var dinnerTime = Date()
    @State private var subjectInput = ""
    @State private var subjects: [String] = []
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // MARK: - Profile
                VStack(alignment: .leading, spacing: 14) {
                    sectionHeader(icon: "person.fill", title: "Profile", color: AppTheme.studyBlue)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill").foregroundStyle(AppTheme.studyGradient)
                        TextField("Name", text: $name)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .onChange(of: name) { _ in profileManager.profile.name = name }
                    }
                    .padding(14).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack {
                        Image(systemName: "number").foregroundStyle(AppTheme.neonCyan)
                        Text("Age: \(age)").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Stepper("", value: $age, in: 10...30)
                            .onChange(of: age) { _ in profileManager.profile.age = age }
                    }
                    .padding(14).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // MARK: - Schedule
                VStack(alignment: .leading, spacing: 14) {
                    sectionHeader(icon: "calendar", title: "Schedule", color: AppTheme.warmOrange)
                    
                    timePicker(label: "School Start", icon: "building.columns.fill", color: AppTheme.studyBlue, time: $schoolStart)
                    timePicker(label: "School End", icon: "building.columns", color: AppTheme.studyBlue, time: $schoolEnd)
                    
                    Toggle(isOn: $hasTuition) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill").foregroundStyle(AppTheme.primaryPurple)
                            Text("Tuition").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                    .tint(AppTheme.primaryPurple)
                    .onChange(of: hasTuition) { _ in profileManager.profile.hasTuition = hasTuition }
                    
                    if hasTuition {
                        timePicker(label: "Tuition Start", icon: "clock.fill", color: AppTheme.primaryPurple, time: $tuitionStart)
                            .onChange(of: tuitionStart) { _ in
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: tuitionStart)
                                profileManager.profile.tuitionStartHour = comps.hour ?? 16
                                profileManager.profile.tuitionStartMinute = comps.minute ?? 0
                            }
                        timePicker(label: "Tuition End", icon: "clock", color: AppTheme.primaryPurple, time: $tuitionEnd)
                            .onChange(of: tuitionEnd) { _ in
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: tuitionEnd)
                                profileManager.profile.tuitionEndHour = comps.hour ?? 17
                                profileManager.profile.tuitionEndMinute = comps.minute ?? 0
                            }
                    }
                    
                    Divider().overlay(AppTheme.cardBorder)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Meal Times").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.warmOrange)
                    }
                    timePicker(label: "Breakfast", icon: "sunrise.fill", color: AppTheme.warmOrange, time: $breakfastTime)
                    timePicker(label: "Lunch", icon: "fork.knife", color: AppTheme.warmOrange, time: $lunchTime)
                    timePicker(label: "Dinner", icon: "moon.fill", color: AppTheme.warmOrange, time: $dinnerTime)
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // MARK: - Subjects
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(icon: "book.fill", title: "Subjects", color: AppTheme.studyBlue)
                    
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
                            ForEach(subjects, id: \.self) { s in
                                HStack(spacing: 6) {
                                    Text(s).font(.system(.caption, design: .rounded, weight: .semibold)).foregroundStyle(.white)
                                    Button(action: { subjects.removeAll { $0 == s }; profileManager.profile.subjects = subjects }) {
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
                .opacity(appeared ? 1 : 0)
                
                // MARK: - Goals (Auto by Age)
                VStack(alignment: .leading, spacing: 14) {
                    sectionHeader(icon: "target", title: "Daily Goals", color: AppTheme.healthGreen)
                    Text("Auto-set based on age (\(profileManager.profile.age))").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                    
                    HStack(spacing: 14) {
                        VStack(spacing: 6) {
                            Image(systemName: "figure.walk").font(.title2).foregroundStyle(AppTheme.healthGreen)
                            Text("\(profileManager.profile.stepGoal.formatted())").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                            Text("Steps").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity).padding(14)
                        .background(AppTheme.healthGreen.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        VStack(spacing: 6) {
                            Image(systemName: "drop.fill").font(.title2).foregroundStyle(AppTheme.neonCyan)
                            Text(profileManager.profile.waterGoal.asLiters).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                            Text("Water").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity).padding(14)
                        .background(AppTheme.neonCyan.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // MARK: - App Info
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(icon: "info.circle.fill", title: "App", color: AppTheme.neonCyan)
                    
                    HStack {
                        Text("Version").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text("2.0").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textTertiary)
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // MARK: - Danger Zone
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(AppTheme.dangerRed)
                        Text("Danger Zone").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.dangerRed)
                    }
                    
                    Button(action: {
                        resetStudy = false
                        resetHealthXP = false
                        resetCalendar = false
                        resetEverything = false
                        showResetOptions = true
                        HapticManager.impact(.medium)
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.dangerRed.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(AppTheme.dangerRed)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Reset App Progress")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(AppTheme.dangerRed)
                                Text("Clear all data and start from beginning.")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppTheme.dangerRed.opacity(0.5))
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppTheme.dangerRed.opacity(0.4), lineWidth: 1)
                                .background(AppTheme.dangerRed.opacity(0.06).clipShape(RoundedRectangle(cornerRadius: 14)))
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                Spacer(minLength: 60)
            }
            .padding(.horizontal, 20).padding(.top, 10)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showResetOptions) {
            resetOptionsSheet
        }
        .alert("Reset App?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm Reset", role: .destructive) {
                performReset()
            }
        } message: {
            Text("This will delete all progress, events, and history. This action cannot be undone.")
        }
        .onAppear {
            loadProfile()
            withAnimation(.spring(response: 0.6)) { appeared = true }
        }
    }
    
    // MARK: - Helpers
    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(color)
            Text(title).font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
        }
    }
    
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
        let s = subjectInput.trimmingCharacters(in: .whitespaces)
        guard !s.isEmpty, !subjects.contains(s) else { return }
        subjects.append(s)
        profileManager.profile.subjects = subjects
        subjectInput = ""
        HapticManager.impact(.light)
    }
    
    private func loadProfile() {
        let p = profileManager.profile
        name = p.name; age = p.age
        hasTuition = p.hasTuition
        subjects = p.subjects
        breakfastTime = p.breakfastDate
        lunchTime = p.lunchDate
        dinnerTime = p.dinnerDate
        tuitionStart = p.tuitionStartDate
        tuitionEnd = p.tuitionEndDate
        subjects = p.subjects
        schoolStart = p.schoolStartDate; schoolEnd = p.schoolEndDate
    }
    
    // MARK: - Reset Options Sheet
    private var resetOptionsSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Warning Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.dangerRed.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(AppTheme.dangerRed)
                }
                .padding(.top, 10)
                
                Text("What would you like to reset?")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Select what to clear. Health steps from Apple won't be deleted.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // Options
                VStack(spacing: 12) {
                    resetToggle(icon: "book.fill", label: "Study Data", sublabel: "Sessions, study time", color: AppTheme.studyBlue, isOn: $resetStudy)
                    resetToggle(icon: "star.fill", label: "XP, Level & Streak", sublabel: "XP, level, streak, brain score", color: AppTheme.warmOrange, isOn: $resetHealthXP)
                    resetToggle(icon: "calendar", label: "Calendar & Events", sublabel: "All events and reminders", color: AppTheme.quizPink, isOn: $resetCalendar)
                    
                    Divider().overlay(Color.white.opacity(0.1)).padding(.vertical, 4)
                    
                    resetToggle(icon: "trash.fill", label: "Reset Everything", sublabel: "All of the above + profile", color: AppTheme.dangerRed, isOn: $resetEverything)
                        .onChange(of: resetEverything) { newVal in
                            if newVal {
                                resetStudy = true
                                resetHealthXP = true
                                resetCalendar = true
                            }
                        }
                }
                .padding(20).glassBackground()
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Confirm Button
                Button(action: {
                    showResetOptions = false
                    // Delay slightly so sheet dismisses before alert shows
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showResetAlert = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Continue to Reset")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        (resetStudy || resetHealthXP || resetCalendar) ? AppTheme.dangerRed : Color.gray.opacity(0.3)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!(resetStudy || resetHealthXP || resetCalendar))
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Reset Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showResetOptions = false }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private func resetToggle(icon: String, label: String, sublabel: String, color: Color, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundStyle(color).frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                Text(sublabel).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
            }
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(color)
        }
    }
    
    // MARK: - Perform Reset
    private func performReset() {
        let defaults = UserDefaults.standard
        
        // Step 1: Clear Study Data
        if resetStudy {
            defaults.removeObject(forKey: "studySessions")
            defaults.removeObject(forKey: "quizResults")
            defaults.removeObject(forKey: "personalQuizzes")
            QuizManager.shared.results = []
        }
        
        // Step 2: Clear XP, Level & Streak
        if resetHealthXP {
            game.resetProfile()
            defaults.removeObject(forKey: "brainScoreToday")
            defaults.removeObject(forKey: "brainScoreDate")
            storage.streakData = .empty
            defaults.removeObject(forKey: AppConstants.streakKey)
            
            // Set reset date so HealthKit steps only count from now
            defaults.set(Date(), forKey: "appResetDate")
        }
        
        // Step 3: Clear Calendar & Events
        if resetCalendar {
            defaults.removeObject(forKey: "calendarEvents")
            CalendarEventManager.shared.events = []
        }
        
        // Step 4: Cancel all notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Step 5: Clear daily tasks
        defaults.removeObject(forKey: "dailyTasks")
        defaults.removeObject(forKey: "lastTaskDate")
        defaults.removeObject(forKey: "lastSleepCompletedDate")
        defaults.removeObject(forKey: "lastWakeCompletedDate")
        
        // Step 6: Full reset extras
        if resetEverything {
            storage.resetAllData()
            defaults.removeObject(forKey: "userProfile")
        }
        
        // Step 7: Navigate to onboarding
        profileManager.hasOnboarded = false
        
        // Step 8: Haptic + done
        HapticManager.notification(.warning)
    }
}
