import SwiftUI

struct TimetableInputView: View {
    @StateObject var viewModel = TimetableViewModel()
    @State private var showingAddSheet = false
    @State private var editingSlot: TimeSlot?
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack {
                //Day selector
                Picker("Day", selection: $viewModel.selectedDay) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        Text(day.rawValue).tag(day)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Time slots list
                if viewModel.getSlotsForSelectedDay().isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.appTextSecondary.opacity(0.5))
                        
                        Text("No schedule for this day")
                            .font(.appHeadline)
                            .foregroundColor(.appTextSecondary)
                        
                        Text("Tap + to add your classes")
                            .font(.appCaption)
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.getSlotsForSelectedDay()) { slot in
                                TimeSlotCard(slot: slot) {
                                    viewModel.removeTimeSlot(slot)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Timetable")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTimeSlotSheet(viewModel: viewModel, isPresented: $showingAddSheet)
        }
        .alert("Conflict Detected", isPresented: $viewModel.hasConflicts) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct TimeSlotCard: View {
    let slot: TimeSlot
    let onDelete: () -> Void
    
    var body: some View {
        InfoCard {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(slot.subject)
                        .font(.appHeadline)
                        .foregroundColor(.appText)
                    
                    HStack {
                        Label(slot.location, systemImage: "mappin.circle.fill")
                            .font(.appCaption)
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                        
                        Text(TimeFormatter.formatTimeRange(start: slot.startTime, end: slot.endTime))
                            .font(.appCaption)
                            .foregroundColor(.appPrimary)
                    }
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.appError)
                }
            }
        }
    }
}

struct AddTimeSlotSheet: View {
    @ObservedObject var viewModel: TimetableViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedSection: ScheduleSection = .school
    @State private var subject = ""
    @State private var schoolType: String = "School"
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var showError = false
    @State private var errorMessage = ""
    
    enum ScheduleSection: String, CaseIterable {
        case school = "School/College"
        case tuition = "Tuition/Classes"
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Section Selector
                Section {
                    Picker("Schedule Type", selection: $selectedSection) {
                        ForEach(ScheduleSection.allCases, id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // School/College Section
                if selectedSection == .school {
                    Section(header: Text("School/College Details")) {
                        Picker("Institution Type", selection: $schoolType) {
                            Text("School").tag("School")
                            Text("College").tag("College")
                        }
                        
                        TextField("Subject/Class Name", text: $subject)
                            .autocapitalization(.words)
                    }
                    
                    Section(header: Text("School/College Timing")) {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        
                        // Show duration
                        if endTime > startTime {
                            HStack {
                                Text("Duration")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatDuration())
                                    .foregroundColor(.appPrimary)
                            }
                        }
                    }
                }
                
                // Tuition/Classes Section
                if selectedSection == .tuition {
                    Section(header: Text("Tuition/Classes Details")) {
                        TextField("Subject/Class Name", text: $subject)
                            .autocapitalization(.words)
                        
                        TextField("Tuition Center (Optional)", text: .constant(""))
                            .foregroundColor(.secondary)
                    }
                    
                    Section(header: Text("Tuition Timing")) {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        
                        // Show duration
                        if endTime > startTime {
                            HStack {
                                Text("Duration")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatDuration())
                                    .foregroundColor(.appPrimary)
                            }
                        }
                    }
                }
                
                // Instructions
                Section {
                    Text("Tap Save to add this time slot to your timetable. The app will check for conflicts automatically.")
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .navigationTitle("Add Time Slot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTimeSlot()
                    }
                    .disabled(!isValid())
                }
            }
            .alert("Invalid Entry", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func isValid() -> Bool {
        return !subject.isEmpty && endTime > startTime
    }
    
    private func saveTimeSlot() {
        // Validate
        guard endTime > startTime else {
            errorMessage = "End time must be after start time"
            showError = true
            return
        }
        
        guard !subject.isEmpty else {
            errorMessage = "Please enter a subject name"
            showError = true
            return
        }
        
        // Determine location based on section
        let location: String
        if selectedSection == .school {
            location = schoolType
        } else {
            location = "Tuition"
        }
        
        // Add the time slot
        viewModel.addTimeSlot(
            day: viewModel.selectedDay,
            startTime: startTime,
            endTime: endTime,
            subject: subject,
            location: location
        )
        
        // Check if there was a conflict
        if viewModel.hasConflicts {
            errorMessage = viewModel.errorMessage
            showError = true
        } else {
            isPresented = false
        }
    }
    
    private func formatDuration() -> String {
        let duration = endTime.timeIntervalSince(startTime)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            }
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        }
        return ""
    }
}
