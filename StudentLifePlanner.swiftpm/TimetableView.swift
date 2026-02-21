import SwiftUI

// MARK: - Timetable View
struct TimetableView: View {
    @StateObject private var planner = PlannerEngine.shared
    @StateObject private var profile = ProfileManager.shared
    @State private var appeared = false
    @State private var selectedBlock: TimeBlock?
    @State private var showPomodoro = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Today Header
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Date().formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                            Text("\(planner.todayRoutine.blocks.count) blocks planned")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(planner.todayRoutine.totalStudyMinutes) min")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(AppTheme.studyBlue)
                            Text("study time")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    .padding(20).glassBackground()
                    .padding(.horizontal, 20).padding(.top, 10)
                    .opacity(appeared ? 1 : 0)
                    
                    // Timeline
                    VStack(spacing: 0) {
                        ForEach(Array(planner.todayRoutine.blocks.enumerated()), id: \.element.id) { idx, block in
                            timelineBlock(block: block, index: idx)
                                .opacity(appeared ? 1 : 0)
                                .animation(.spring(response: 0.5).delay(Double(idx) * 0.05), value: appeared)
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 16)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Timetable")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(isPresented: $showPomodoro) {
                if let block = selectedBlock {
                    PomodoroView(subject: block.subject ?? "Study", durationMinutes: block.durationMinutes)
                }
            }
            .onAppear {
                planner.generateToday()
                withAnimation(.spring(response: 0.6)) { appeared = true }
            }
        }
    }
    
    private func timelineBlock(block: TimeBlock, index: Int) -> some View {
        HStack(spacing: 14) {
            // Time label
            VStack(spacing: 2) {
                Text(block.startTime)
                    .font(.system(.caption2, design: .monospaced, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                RoundedRectangle(cornerRadius: 1).fill(block.type.lightColor.opacity(0.4))
                    .frame(width: 2, height: max(CGFloat(block.durationMinutes) * 0.5, 20))
                Text(block.endTime)
                    .font(.system(.caption2, design: .monospaced, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .frame(width: 42)
            
            // Block Card
            Button(action: {
                if block.type == .study {
                    selectedBlock = block
                    showPomodoro = true
                    HapticManager.impact(.medium)
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(block.type.lightColor.opacity(0.2)).frame(width: 40, height: 40)
                        Image(systemName: block.type.icon).font(.body).foregroundStyle(block.type.lightColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(block.displayTitle)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        HStack(spacing: 6) {
                            Text("\(block.durationMinutes) min")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(AppTheme.textTertiary)
                            if block.type == .study {
                                Text("• \(block.pomodoroCount) cycles")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(AppTheme.primaryPurple)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if block.type == .study {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(block.type.lightColor)
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(block.type.lightColor.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(block.type != .study)
        }
        .padding(.vertical, 4)
    }
}
