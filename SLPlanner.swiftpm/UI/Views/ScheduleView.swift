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

                VStack(spacing: 0) {
                    // Segmented Picker at the top
                    segmentedPicker

                    TabView(selection: $selectedTab) {
                        // Slide 0: Timetable
                        TimetableView()
                            .tag(0)

                        // Slide 1: Calendar
                        CalendarView(selectedDate: $selectedDate)
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: selectedTab)
                }

                // Show FAB only on Calendar tab
                if selectedTab == 1 {
                    Button(action: {
                        showAddEvent = true
                        HapticManager.impact(.medium)
                    }) {
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
                            NotificationCenter.default.post(
                                name: NSNotification.Name("ResetCalendarMonth"), object: nil)
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

    // MARK: - Segmented Picker
    private var segmentedPicker: some View {
        HStack(spacing: 4) {
            segmentButton(
                title: "Timetable", icon: "clock.fill", index: 0, color: AppTheme.studyBlue)
            segmentButton(
                title: "Calendar", icon: "calendar", index: 1, color: AppTheme.primaryPurple)
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private func segmentButton(title: String, icon: String, index: Int, color: Color) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = index
            }
            HapticManager.selection()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(selectedTab == index ? .white : AppTheme.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if selectedTab == index {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(color.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: color.opacity(0.3), radius: 8, y: 2)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}
