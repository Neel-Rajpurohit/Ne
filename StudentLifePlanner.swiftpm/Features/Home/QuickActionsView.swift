import SwiftUI

struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.appTitle2)
                .foregroundColor(.appText)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                NavigationLink(destination: StudyTimerView()) {
                    ActionButton(
                        title: "Study Timer",
                        icon: "timer",
                        color: .appPrimary,
                        action: {}
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: HealthDashboardView()) {
                    ActionButton(
                        title: "Exercise",
                        icon: "figure.walk",
                        color: .appSuccess,
                        action: {}
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: CalendarView()) {
                    ActionButton(
                        title: "Calendar",
                        icon: "calendar",
                        color: .appSecondary,
                        action: {}
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: TimetableInputView()) {
                    ActionButton(
                        title: "Timetable",
                        icon: "clock",
                        color: .appAccent,
                        action: {}
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
        }
    }
}
