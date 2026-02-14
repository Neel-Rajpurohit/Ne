import SwiftUI

struct FocusSessionView: View {
    @ObservedObject var viewModel: StudyTimerViewModel
    
    var body: some View {
        ZStack {
            AppBackground(style: .study)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Today's stats
                    InfoCard {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Today's Focus Time")
                                        .font(.appHeadline)
                                        .foregroundColor(.appText)
                                    
                                    Text(viewModel.getTodayFocusTime())
                                        .font(.appTimer)
                                        .foregroundColor(.appPrimary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.appSuccess)
                            }
                            
                            Divider()
                            
                            HStack {
                                Label("\(viewModel.sessionsCompleted) sessions", systemImage: "flame.fill")
                                    .font(.appBody)
                                    .foregroundColor(.appTextSecondary)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Recent sessions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Sessions")
                            .font(.appTitle2)
                            .foregroundColor(.appText)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.getRecentSessions(), id: \.id) { session in
                            InfoCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(DateHelper.formatDateWithDay(session.date))
                                            .font(.appHeadline)
                                            .foregroundColor(.appText)
                                        
                                        Text("\(session.sessionsCompleted) session(s) • \(TimeFormatter.formatDuration(session.totalFocusTime))")
                                            .font(.appCaption)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.appSuccess)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Focus Sessions")
        .navigationBarTitleDisplayMode(.inline)
    }
}
