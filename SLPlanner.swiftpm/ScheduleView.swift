import SwiftUI

// MARK: - Schedule Container View
struct ScheduleView: View {
    @State private var selectedTab = 0
    @State private var showAddEvent = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.mainGradient.ignoresSafeArea()
                
                TabView(selection: $selectedTab) {
                    // Slide 0: Timetable
                    TimetableView()
                        .tag(0)
                    
                    // Slide 1: Calendar
                    CalendarView(selectedDate: $selectedDate)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: selectedTab)
                
                // Show FAB only on Calendar tab
                if selectedTab == 1 {
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
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle(selectedTab == 0 ? "Timetable" : "Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if selectedTab == 1 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            selectedDate = Date()
                            HapticManager.selection()
                            NotificationCenter.default.post(name: NSNotification.Name("ResetCalendarMonth"), object: nil)
                        }) {
                            Text("Today")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(AppTheme.studyBlue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddEvent) {
                AddEventSheet(preselectedDate: selectedDate)
            }
        }
    }
}
