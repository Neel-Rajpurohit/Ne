import SwiftUI

// MARK: - Calendar View

struct CalendarView: View {
    @StateObject private var eventManager = CalendarEventManager.shared
    @StateObject private var planner = PlannerEngine.shared
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var appeared = false
    @State private var showAddEvent = false
    
    private var calendar: Calendar { Calendar.current }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Month Header
                        monthHeader
                            .opacity(appeared ? 1 : 0)
                        
                        // Calendar Grid
                        calendarGrid
                            .opacity(appeared ? 1 : 0)
                        
                        // Selected Day Events
                        dayEventsSection
                            .opacity(appeared ? 1 : 0)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20).padding(.top, 10)
                }
                
                // FAB — Add Event
                Button(action: { showAddEvent = true; HapticManager.impact(.medium) }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.studyBlue, AppTheme.primaryPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: AppTheme.studyBlue.opacity(0.4), radius: 12, y: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        selectedDate = Date()
                        currentMonth = Date()
                        HapticManager.selection()
                    }) {
                        Text("Today")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppTheme.studyBlue)
                    }
                }
            }
            .sheet(isPresented: $showAddEvent) {
                AddEventSheet(preselectedDate: selectedDate)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6)) { appeared = true }
                NotificationManager.shared.setupDailyNotifications()
            }
        }
    }
    
    // MARK: - Month Header
    
    private var monthHeader: some View {
        HStack {
            Button(action: { changeMonth(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(currentMonth.formatted(.dateTime.month(.wide)))
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(currentMonth.formatted(.dateTime.year()))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            Spacer()
            
            Button(action: { changeMonth(1) }) {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(16).glassBackground()
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: 10) {
            // Weekday labels
            HStack {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { d in
                    Text(d)
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Day cells
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        dayCell(date: date)
                    } else {
                        Color.clear.frame(height: 52)
                    }
                }
            }
        }
        .padding(16).glassBackground()
    }
    
    // MARK: - Day Cell
    
    private func dayCell(date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let categories = eventManager.eventCategories(on: date)
        // Also check if timetable has blocks for this date
        let routine = planner.generateRoutine(for: date, profile: ProfileManager.shared.profile)
        let studyBlocks = routine.blocks.filter { $0.type == .study }
        let hasStudy = !studyBlocks.isEmpty
        
        return Button(action: {
            withAnimation(.spring(response: 0.3)) { selectedDate = date }
            HapticManager.selection()
        }) {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(.subheadline, design: .rounded, weight: isToday || isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : isToday ? AppTheme.studyBlue : AppTheme.textPrimary)
                
                // Dot indicators
                HStack(spacing: 3) {
                    // Study dot (Blue)
                    if hasStudy || categories.contains(.study) {
                        Circle().fill(AppTheme.studyBlue).frame(width: 5, height: 5)
                    }
                    // Health dot (Purple)
                    if categories.contains(.health) {
                        Circle().fill(AppTheme.primaryPurple).frame(width: 5, height: 5)
                    }
                    // Special Day (Yellow)
                    if categories.contains(.specialDay) {
                        Circle().fill(AppTheme.warmOrange).frame(width: 5, height: 5)
                    }
                    // Work/Personal (Green)
                    if categories.contains(.work) || categories.contains(.personal) {
                        Circle().fill(AppTheme.healthGreen).frame(width: 5, height: 5)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity).frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AppTheme.studyBlue : isToday ? AppTheme.studyBlue.opacity(0.12) : Color.clear)
            )
        }
    }
    
    // MARK: - Day Events Section
    
    private var dayEventsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Date header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(selectedDate.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppTheme.textTertiary)
                }
                Spacer()
                
                // Event count badge
                let totalCount = mergedEvents.count
                if totalCount > 0 {
                    Text("\(totalCount) event\(totalCount == 1 ? "" : "s")")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppTheme.studyBlue)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(AppTheme.studyBlue.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            if mergedEvents.isEmpty {
                // Empty state
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 36))
                        .foregroundStyle(AppTheme.textTertiary)
                    Text("No events")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppTheme.textTertiary)
                    Button("Add Event") {
                        showAddEvent = true
                    }
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.studyBlue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(mergedEvents) { item in
                    eventRow(item)
                }
            }
        }
        .padding(20).glassBackground()
    }
    
    // MARK: - Merged Events (Timetable + Calendar Events)
    
    private var mergedEvents: [DisplayEvent] {
        var items: [DisplayEvent] = []
        
        // Calendar events
        let calEvents = eventManager.events(for: selectedDate)
        for ev in calEvents {
            items.append(DisplayEvent(
                id: ev.id,
                title: ev.title,
                time: ev.timeString,
                icon: ev.category.icon,
                color: ev.category.color,
                isCompleted: ev.isCompleted,
                isCalendarEvent: true,
                sortDate: ev.isAllDay ? calendar.startOfDay(for: ev.date) : ev.date
            ))
        }
        
        // Timetable blocks
        let routine = planner.generateRoutine(for: selectedDate, profile: ProfileManager.shared.profile)
        for block in routine.blocks {
            let blockSortDate = calendar.date(bySettingHour: block.startHour, minute: block.startMinute, second: 0, of: selectedDate) ?? calendar.startOfDay(for: selectedDate)
            items.append(DisplayEvent(
                id: block.id,
                title: block.displayTitle,
                time: "\(block.startTime) — \(block.endTime)",
                icon: block.type.icon,
                color: block.type.lightColor,
                isCompleted: false,
                isCalendarEvent: false,
                sortDate: blockSortDate
            ))
        }
        
        return items.sorted { $0.sortDate < $1.sortDate }
    }
    
    // MARK: - Event Row
    
    private func eventRow(_ event: DisplayEvent) -> some View {
        HStack(spacing: 12) {
            // Color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 4, height: 40)
            
            // Icon
            Image(systemName: event.icon)
                .font(.caption)
                .foregroundStyle(event.color)
                .frame(width: 28, height: 28)
                .background(event.color.opacity(0.15))
                .clipShape(Circle())
            
            // Title & time
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(event.isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary)
                    .strikethrough(event.isCompleted)
                Text(event.time)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            Spacer()
            
            // Complete button (calendar events only)
            if event.isCalendarEvent {
                Button(action: {
                    eventManager.toggleComplete(id: event.id)
                    HapticManager.impact(.light)
                }) {
                    Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(event.isCompleted ? AppTheme.healthGreen : AppTheme.textTertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Helpers
    
    private func changeMonth(_ by: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: by, to: currentMonth) {
            withAnimation(.spring(response: 0.3)) { currentMonth = newMonth }
            HapticManager.selection()
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        // Adjust for Monday start (1=Sun, 2=Mon... 7=Sat)
        var weekdayValue = calendar.component(.weekday, from: firstDayOfMonth) - 2
        if weekdayValue < 0 { weekdayValue += 7 }
        
        var days: [Date?] = Array(repeating: nil, count: weekdayValue)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        return days
    }
}

// MARK: - Display Event (Unified type for timetable + calendar events)

private struct DisplayEvent: Identifiable {
    let id: UUID
    let title: String
    let time: String
    let icon: String
    let color: Color
    let isCompleted: Bool
    let isCalendarEvent: Bool
    let sortDate: Date
}
