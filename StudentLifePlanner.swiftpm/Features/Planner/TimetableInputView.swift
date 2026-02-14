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
    
    @State private var subject = ""
    @State private var location = ""
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Subject/Class Name", text: $subject)
                    
                    Picker("Location", selection: $location) {
                        Text("School").tag("School")
                        Text("College").tag("College")
                        Text("Tuition").tag("Tuition")
                        Text("Other").tag("Other")
                    }
                }
                
                Section("Timing") {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
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
                        viewModel.addTimeSlot(
                            day: viewModel.selectedDay,
                            startTime: startTime,
                            endTime: endTime,
                            subject: subject,
                            location: location
                        )
                        isPresented = false
                    }
                    .disabled(subject.isEmpty || location.isEmpty)
                }
            }
        }
    }
}
