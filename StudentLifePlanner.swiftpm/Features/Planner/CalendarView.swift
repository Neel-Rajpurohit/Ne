import SwiftUI

struct CalendarView: View {
    @StateObject var viewModel = CalendarViewModel()
    
    var body: some View {
        ZStack {
            AppBackground(style: .default)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Month navigation
                    HStack {
                        Button(action: {
                            viewModel.previousMonth()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.appPrimary)
                        }
                        
                        Spacer()
                        
                        Text(viewModel.getMonthName())
                            .font(.appTitle2)
                            .foregroundColor(.appText)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.nextMonth()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.appPrimary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats cards
                    HStack(spacing: 12) {
                        InfoCard {
                            VStack(spacing: 4) {
                                Text("\(viewModel.getCurrentStreak())")
                                    .font(.appTitle)
                                    .foregroundColor(.appSuccess)
                                
                                Text("Current Streak")
                                    .font(.appCaption)
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                        
                        InfoCard {
                            VStack(spacing: 4) {
                                Text("\(Int(viewModel.getMonthlyCompletionRate() * 100))%")
                                    .font(.appTitle)
                                    .foregroundColor(.appPrimary)
                                
                                Text("This Month")
                                    .font(.appCaption)
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar grid
                    InfoCard {
                        CalendarGrid(
                            days: viewModel.daysInMonth,
                            isCompleted: { date in
                                viewModel.isDayCompleted(date)
                            },
                            isToday: { date in
                                viewModel.isToday(date)
                            },
                            isFuture: { date in
                                viewModel.isFutureDate(date)
                            },
                            onSelectDate: { date in
                                viewModel.selectDate(date)
                            }
                        )
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }
}
