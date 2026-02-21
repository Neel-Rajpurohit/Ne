import SwiftUI

// MARK: - Calendar View
struct CalendarView: View {
    @StateObject private var planner = PlannerEngine.shared
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var appeared = false
    
    private var calendar: Calendar { Calendar.current }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Month Header
                    monthHeader.opacity(appeared ? 1 : 0)
                    
                    // Calendar Grid
                    calendarGrid.opacity(appeared ? 1 : 0)
                    
                    // Selected Day Detail
                    dayDetail.opacity(appeared ? 1 : 0)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20).padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
        }
    }
    
    // MARK: - Month Header
    private var monthHeader: some View {
        HStack {
            Button(action: { changeMonth(-1) }) {
                Image(systemName: "chevron.left").foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Button(action: { changeMonth(1) }) {
                Image(systemName: "chevron.right").foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(16).glassBackground()
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Day labels
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { d in
                    Text(d).font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        dayCell(date: date)
                    } else {
                        Text("").frame(height: 40)
                    }
                }
            }
        }
        .padding(16).glassBackground()
    }
    
    private func dayCell(date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        
        return Button(action: { selectedDate = date; HapticManager.selection() }) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(.subheadline, design: .rounded, weight: isToday || isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : isToday ? AppTheme.neonCyan : AppTheme.textPrimary)
                
                // Activity dots
                HStack(spacing: 2) {
                    Circle().fill(AppTheme.studyBlue).frame(width: 4, height: 4)
                    if calendar.isDateInToday(date) {
                        Circle().fill(AppTheme.healthGreen).frame(width: 4, height: 4)
                    }
                }
            }
            .frame(maxWidth: .infinity).frame(height: 44)
            .background(isSelected ? AppTheme.studyBlue : isToday ? AppTheme.studyBlue.opacity(0.15) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    // MARK: - Day Detail
    private var dayDetail: some View {
        let routine = planner.generateRoutine(for: selectedDate, profile: ProfileManager.shared.profile)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            
            if routine.blocks.isEmpty {
                Text("No events").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
            } else {
                ForEach(routine.blocks) { block in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 2).fill(block.type.lightColor).frame(width: 4, height: 36)
                        Image(systemName: block.type.icon).foregroundStyle(block.type.lightColor).font(.caption)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(block.displayTitle)
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("\(block.startTime) — \(block.endTime)")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(20).glassBackground()
    }
    
    // MARK: - Helpers
    private func changeMonth(_ by: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: by, to: currentMonth) {
            currentMonth = newMonth
            HapticManager.selection()
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let weekday = calendar.component(.weekday, from: firstDay) - 1
        
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
}
