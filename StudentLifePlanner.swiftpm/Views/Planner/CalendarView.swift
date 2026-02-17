import SwiftUI

struct CalendarView: View {
    let days = DateHelper.getDaysInCurrentMonth()
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 20) {
                    Text("My Progress")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "1E293B"))
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                            ForEach(days, id: \.self) { day in
                                VStack(spacing: 8) {
                                    Text("\(Calendar.current.component(.day, from: day))")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(DateHelper.isToday(day) ? .white : Color(hex: "1E293B"))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            ZStack {
                                                Circle()
                                                    .fill(DateHelper.isToday(day) ? AppColors.primary : Color.white.opacity(0.5))
                                                if DateHelper.isToday(day) {
                                                    Circle().stroke(Color.white.opacity(0.5), lineWidth: 2)
                                                }
                                            }
                                        )
                                    
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 6, height: 6)
                                        .opacity(Double.random(in: 0...1) > 0.5 ? 1 : 0.1)
                                }
                            }
                        }
                        .padding()
                        .background(
                            ZStack {
                                BlurView(style: .systemThinMaterialLight)
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [AppColors.secondary, AppColors.accent]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            }
                        )
                        .cornerRadius(20)
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
