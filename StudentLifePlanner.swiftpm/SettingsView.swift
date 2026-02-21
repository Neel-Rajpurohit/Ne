import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @StateObject private var profileManager = ProfileManager.shared
    @StateObject private var themeManager = AppThemeManager.shared
    @StateObject private var storage = StorageManager.shared
    @StateObject private var game = GameEngineManager.shared
    @State private var showResetAlert = false
    @State private var appeared = false
    
    // Editable profile fields
    @State private var name: String = ""
    @State private var age: Int = 16

    @State private var schoolStart = Date()
    @State private var schoolEnd = Date()
    @State private var hasTuition = false
    @State private var breakfastTime = Date()
    @State private var lunchTime = Date()
    @State private var dinnerTime = Date()
    @State private var subjectInput = ""
    @State private var subjects: [String] = []
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // MARK: - Appearance
                VStack(alignment: .leading, spacing: 14) {
                    sectionHeader(icon: "paintbrush.fill", title: "Appearance", color: AppTheme.primaryPurple)
                    
                    HStack(spacing: 10) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Button(action: { themeManager.themeMode = mode; HapticManager.selection() }) {
                                VStack(spacing: 8) {
                                    Image(systemName: mode.icon)
                                        .font(.title3)
                                        .foregroundStyle(themeManager.themeMode == mode ? .white : AppTheme.textSecondary)
                                    Text(mode.rawValue)
                                        .font(.system(.caption2, design: .rounded, weight: .bold))
                                        .foregroundStyle(themeManager.themeMode == mode ? .white : AppTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .background(themeManager.themeMode == mode ? AppTheme.primaryPurple : Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // MARK: - Profile
                VStack(alignment: .leading, spacing: 14) {
                    sectionHeader(icon: "person.fill", title: "Profile", color: AppTheme.studyBlue)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill").foregroundStyle(AppTheme.studyGradient)
                        TextField("Name", text: $name)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .onChange(of: name) { profileManager.profile.name = name }
                    }
                    .padding(14).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack {
                        Image(systemName: "number").foregroundStyle(AppTheme.neonCyan)
                        Text("Age: \(age)").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Stepper("", value: $age, in: 10...30)
                            .onChange(of: age) { profileManager.profile.age = age }
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
                    .onChange(of: hasTuition) { profileManager.profile.hasTuition = hasTuition }
                    
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
                    
                    Divider().overlay(AppTheme.cardBorder)
                    
                    Button(action: { showResetAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise").foregroundStyle(AppTheme.dangerRed)
                            Text("Reset All Data").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.dangerRed)
                        }
                    }
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
        .alert("Reset Everything?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                game.resetProfile()
                profileManager.hasOnboarded = false
                HapticManager.notification(.warning)
            }
        } message: {
            Text("This will delete all your data including profile, study logs, quiz scores, and health data.")
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
        subjects = p.subjects
        schoolStart = p.schoolStartDate; schoolEnd = p.schoolEndDate
    }
}
