import SwiftUI

// MARK: - Add Event Sheet

struct AddEventSheet: View {
    @ObservedObject private var eventManager = CalendarEventManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var category: EventCategory = .study
    @State private var date = Date()
    @State private var isAllDay = false
    @State private var repeatOption: RepeatOption = .none
    @State private var reminderTime: ReminderTime = .tenMinBefore
    @State private var notes = ""
    
    var preselectedDate: Date?
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        sectionLabel("Event Title")
                        TextField("e.g. Study Math, Neel Birthday", text: $title)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Category Picker
                    VStack(alignment: .leading, spacing: 8) {
                        sectionLabel("Category")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(EventCategory.allCases) { cat in
                                    Button(action: { category = cat; HapticManager.selection() }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.icon)
                                                .font(.caption)
                                            Text(cat.rawValue)
                                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                        }
                                        .foregroundStyle(category == cat ? .white : cat.color)
                                        .padding(.horizontal, 14).padding(.vertical, 10)
                                        .background(category == cat ? cat.color : cat.color.opacity(0.15))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    
                    // All Day Toggle
                    Toggle(isOn: $isAllDay) {
                        HStack(spacing: 8) {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(AppTheme.warmOrange)
                            Text("All Day")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                    .tint(AppTheme.warmOrange)
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Date & Time
                    VStack(alignment: .leading, spacing: 8) {
                        sectionLabel("Date & Time")
                        
                        DatePicker(
                            "Date",
                            selection: $date,
                            displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        .tint(category.color)
                        .colorScheme(.dark)
                        .padding(14)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // Repeat
                    VStack(alignment: .leading, spacing: 8) {
                        sectionLabel("Repeat")
                        HStack(spacing: 8) {
                            ForEach(RepeatOption.allCases) { opt in
                                Button(action: { repeatOption = opt; HapticManager.selection() }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: opt.icon)
                                            .font(.caption)
                                        Text(opt.rawValue)
                                            .font(.system(.caption2, design: .rounded, weight: .medium))
                                    }
                                    .foregroundStyle(repeatOption == opt ? .white : AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(repeatOption == opt ? category.color : Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    
                    // Reminder
                    if !isAllDay {
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Reminder")
                            HStack(spacing: 8) {
                                ForEach(ReminderTime.allCases) { rem in
                                    Button(action: { reminderTime = rem; HapticManager.selection() }) {
                                        Text(rem.rawValue)
                                            .font(.system(.caption2, design: .rounded, weight: .medium))
                                            .foregroundStyle(reminderTime == rem ? .white : AppTheme.textSecondary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(reminderTime == rem ? category.color : Color.white.opacity(0.06))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        sectionLabel("Notes (optional)")
                        TextField("Add notes...", text: $notes, axis: .vertical)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(3...6)
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveEvent) {
                        Text("Save")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(title.isEmpty ? AppTheme.textTertiary : category.color)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let preDate = preselectedDate {
                    date = preDate
                }
                NotificationManager.shared.requestPermission()
            }
        }
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(.subheadline, design: .rounded, weight: .medium))
            .foregroundStyle(AppTheme.textSecondary)
    }
    
    private func saveEvent() {
        let event = CalendarEvent(
            title: title.trimmingCharacters(in: .whitespaces),
            category: category,
            date: date,
            isAllDay: isAllDay,
            repeatOption: repeatOption,
            reminderTime: reminderTime,
            notes: notes
        )
        eventManager.addEvent(event)
        HapticManager.notification(.success)
        dismiss()
    }
}
