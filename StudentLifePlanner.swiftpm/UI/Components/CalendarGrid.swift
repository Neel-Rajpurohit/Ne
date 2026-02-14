import SwiftUI

struct CalendarGrid: View {
    let days: [Date]
    let isCompleted: (Date) -> Bool
    let isToday: (Date) -> Bool
    let isFuture: (Date) -> Bool
    let onSelectDate: (Date) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Week day headers
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar days
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(days, id: \.self) { date in
                    CalendarDayCell(
                        date: date,
                        isCompleted: isCompleted(date),
                        isToday: isToday(date),
                        isFuture: isFuture(date)
                    )
                    .onTapGesture {
                        onSelectDate(date)
                    }
                }
            }
        }
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    let isFuture: Bool
    
    private var dayNumber: String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
    
    private var backgroundColor: Color {
        if isToday {
            return .appPrimary.opacity(0.2)
        } else if isCompleted {
            return .appSuccess.opacity(0.2)
        } else {
            return .appCardBackground
        }
    }
    
    private var foregroundColor: Color {
        if isFuture {
            return .appTextSecondary.opacity(0.5)
        } else if isToday {
            return .appPrimary
        } else if isCompleted {
            return .appSuccess
        } else {
            return .appText
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
            
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(foregroundColor)
                
                if isCompleted && !isFuture {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.appSuccess)
                }
            }
        }
        .frame(height: 50)
    }
}
