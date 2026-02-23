import SwiftUI
import Charts

// MARK: - Sleep View
struct SleepView: View {
    @StateObject private var vm = SleepViewModel()
    @State private var selectedQuality: SleepQuality = .good
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Sleep Ring
                CircularProgressView(
                    progress: min(vm.sleepHours / 8.0, 1.0),
                    lineWidth: 16, size: 180,
                    gradient: AppTheme.sleepGradient,
                    icon: "bed.double.fill",
                    label: String(format: "%.1fh", vm.sleepHours),
                    sublabel: "of 8h goal"
                )
                .padding(.top, 10)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)
                
                // Time Pickers
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "moon.fill").foregroundStyle(AppTheme.sleepGradient)
                        Text("Bedtime").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        DatePicker("", selection: $vm.bedtime, displayedComponents: .hourAndMinute)
                            .labelsHidden().colorScheme(.dark).tint(AppTheme.sleepIndigo)
                    }
                    Divider().overlay(AppTheme.cardBorder)
                    HStack {
                        Image(systemName: "sun.horizon.fill").foregroundStyle(AppTheme.warmOrange)
                        Text("Wake Time").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        DatePicker("", selection: $vm.wakeTime, displayedComponents: .hourAndMinute)
                            .labelsHidden().colorScheme(.dark).tint(AppTheme.warmOrange)
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Quality Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sleep Quality").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                    HStack(spacing: 12) {
                        ForEach([SleepQuality.poor, .fair, .good, .excellent], id: \.self) { quality in
                            Button(action: { selectedQuality = quality; HapticManager.selection() }) {
                                VStack(spacing: 6) {
                                    Text(quality.icon).font(.title2)
                                    Text(quality.rawValue).font(.system(.caption2, design: .rounded, weight: .medium))
                                        .foregroundStyle(selectedQuality == quality ? .white : AppTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(selectedQuality == quality ? AnyShapeStyle(quality.color) : AnyShapeStyle(quality.color.opacity(0.15)))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    
                    Button(action: { vm.logSleep(quality: selectedQuality); HapticManager.notification(.success) }) {
                        Text("Log Sleep").font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white).frame(maxWidth: .infinity).padding(14)
                            .background(AppTheme.sleepGradient).clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Weekly Chart
                WeeklyChartView(data: vm.chartData, goal: 8, accentColor: AppTheme.sleepIndigo, gradient: AppTheme.sleepGradient, title: "Weekly Sleep", unit: "hours")
                    .opacity(appeared ? 1 : 0)
                
                // Average
                HStack {
                    Image(systemName: "chart.bar.fill").foregroundStyle(AppTheme.sleepGradient)
                    Text("Weekly Average: \(String(format: "%.1f", vm.weeklyAverage))h")
                        .font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                }
                .padding(16).glassBackground()
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .onAppear { withAnimation(.spring(response: 0.7)) { appeared = true } }
    }
}
