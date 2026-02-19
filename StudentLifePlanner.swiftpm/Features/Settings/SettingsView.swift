import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Academic Section
                            SettingsSection(title: "Academic") {
                                VStack(spacing: 0) {
                                    HStack {
                                        Text("Mode")
                                        Spacer()
                                        Picker("Mode", selection: $viewModel.academicMode) {
                                            ForEach(viewModel.academicModes, id: \.self) { mode in
                                                Text(mode).tag(mode)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                    }
                                    .padding(.vertical, 8)
                                    
                                    Divider()
                                    
                                    NavigationLink(destination: WeeklyTimetableEditorView(viewModel: viewModel)) {
                                        HStack {
                                            Text("Adjust Timetable")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                        }
                                        .padding(.vertical, 12)
                                    }
                                    .foregroundColor(.primary)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Visuals Section
                            SettingsSection(title: "Visuals") {
                                Toggle("Dark Mode", isOn: $appState.isDarkMode)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                            
                            // Security Section
                            SettingsSection(title: "Security") {
                                Toggle("Privacy Lock", isOn: $viewModel.isPrivacyLockEnabled)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                            
                            // Support Section
                            SettingsSection(title: "Support") {
                                VStack(spacing: 0) {
                                    NavigationLink(destination: AboutView()) {
                                        HStack {
                                            Text("About LifePlanner")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                        }
                                        .padding(.vertical, 12)
                                    }
                                    .foregroundColor(.primary)
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text("Version")
                                        Spacer()
                                        Text("1.0.0")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 12)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.bold())
                .foregroundColor(AppColors.textPrimary.opacity(0.6))
                .padding(.leading, 8)
            
            InfoCard {
                content
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary)
                    .padding()
                
                Text("LifePlanner")
                    .font(.largeTitle.bold())
                
                Text("Your AI-Powered Student Life Assistant")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("LifePlanner is designed to help students balance academics, health, and leisure through intelligent scheduling and wellness tracking.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState.shared)
}

struct WeeklyTimetableEditorView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    private let days = [
        (1, "Sunday"), (2, "Monday"), (3, "Tuesday"), (4, "Wednesday"),
        (5, "Thursday"), (6, "Friday"), (7, "Saturday")
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Select Day")) {
                Picker("Day of the Week", selection: $viewModel.selectedDay) {
                    ForEach(days, id: \.0) { day in
                        Text(day.1).tag(day.0)
                    }
                }
                .pickerStyle(.menu)
                
                Toggle("Is Academic Day", isOn: dayBinding.isActive)
            }
            
            if viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.isActive == true {
                Section(header: Text("Institution (School/College)")) {
                    DatePicker("Start Time", selection: dayBinding.institution.startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: dayBinding.institution.endTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Tuition")) {
                    Toggle("Attend Tuition", isOn: dayBinding.tuition.hasTuition)
                    
                    if viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.tuition.hasTuition == true {
                        DatePicker("Start Time", selection: tuitionStartTimeBinding, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: tuitionEndTimeBinding, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("Extra Classes")) {
                    Toggle("Have Extra Classes", isOn: dayBinding.extraClass.hasExtraClasses)
                    
                    if viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.extraClass.hasExtraClasses == true {
                        DatePicker("Start Time", selection: extraStartTimeBinding, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: extraEndTimeBinding, displayedComponents: .hourAndMinute)
                    }
                }
            } else {
                Section {
                    Text("This day is marked as a holiday. No academic activities will be scheduled.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            
            Section {
                Button("Apply to All Days") {
                    if let current = viewModel.weeklyTimetable.schedules[viewModel.selectedDay] {
                        for day in 1...7 {
                            viewModel.weeklyTimetable.schedules[day] = current
                        }
                    }
                }
                .foregroundColor(.blue)
                
                Button("Save Weekly Schedule") {
                    viewModel.saveSchedules()
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .bold()
                .foregroundColor(.green)
            }
        }
        .navigationTitle("Weekly Timetable")
    }
    
    // MARK: - Helper Bindings
    private var dayBinding: Binding<DaySchedule> {
        Binding(
            get: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay] ?? WeeklyTimetable.defaultSchedule().schedules[2]! },
            set: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay] = $0 }
        )
    }
    private var tuitionStartTimeBinding: Binding<Date> {
        Binding(
            get: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.tuition.startTime ?? Date() },
            set: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.tuition.startTime = $0 }
        )
    }
    
    private var tuitionEndTimeBinding: Binding<Date> {
        Binding(
            get: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.tuition.endTime ?? Date() },
            set: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.tuition.endTime = $0 }
        )
    }
    
    private var extraStartTimeBinding: Binding<Date> {
        Binding(
            get: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.extraClass.startTime ?? Date() },
            set: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.extraClass.startTime = $0 }
        )
    }
    
    private var extraEndTimeBinding: Binding<Date> {
        Binding(
            get: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.extraClass.endTime ?? Date() },
            set: { viewModel.weeklyTimetable.schedules[viewModel.selectedDay]?.extraClass.endTime = $0 }
        )
    }
}
