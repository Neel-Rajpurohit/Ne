import SwiftUI

// MARK: - Timetable View
struct TimetableView: View {
    @StateObject private var planner = PlannerEngine.shared
    @StateObject private var profile = ProfileManager.shared
    @StateObject private var taskManager = TaskCompletionManager.shared
    @State private var appeared = false
    @State private var selectedBlock: TimeBlock?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Today Header
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Date().formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                            Text("\(planner.todayRoutine.completedCount)/\(planner.todayRoutine.blocks.count) completed")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                        Spacer()
                        // Completion percentage ring
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 4)
                                .frame(width: 44, height: 44)
                            Circle()
                                .trim(from: 0, to: planner.todayRoutine.completionPercentage)
                                .stroke(AppTheme.healthGradient, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 44, height: 44)
                                .rotationEffect(.degrees(-90))
                            Text("\(Int(planner.todayRoutine.completionPercentage * 100))%")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(AppTheme.healthGreen)
                        }
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
        .background(Color.clear) // Parent handles background
        .fullScreenCover(item: $selectedBlock) { block in
            PomodoroView(
                subject: block.subject ?? "Study",
                totalCycles: block.cycles,
                studyDuration: block.studyDuration,
                breakDuration: block.breakDuration,
                blockId: block.id
            )
        }
        .onAppear {
            planner.generateToday()
            taskManager.startMonitoring()
            withAnimation(.spring(response: 0.6)) { appeared = true }
        }
    }
    
    private func timelineBlock(block: TimeBlock, index: Int) -> some View {
        HStack(spacing: 14) {
            // Time label
            VStack(spacing: 2) {
                Text(block.startTime)
                    .font(.system(.caption2, design: .monospaced, weight: .medium))
                    .foregroundStyle(block.isCompleted ? AppTheme.healthGreen : AppTheme.textTertiary)
                
                // Completion line indicator
                RoundedRectangle(cornerRadius: 1)
                    .fill(block.isCompleted ? AppTheme.healthGreen : block.type.lightColor.opacity(0.4))
                    .frame(width: 2, height: max(CGFloat(block.durationMinutes) * 0.5, 20))
                
                Text(block.endTime)
                    .font(.system(.caption2, design: .monospaced, weight: .medium))
                    .foregroundStyle(block.isCompleted ? AppTheme.healthGreen : AppTheme.textTertiary)
            }
            .frame(width: 42)
            
            // Block Card
            Button(action: {
                if block.isCompleted { return }
                if block.type == .study {
                    selectedBlock = block
                    HapticManager.impact(.medium)
                } else if block.type.canCompleteManually {
                    // Manual tap to complete
                    if let idx = planner.todayRoutine.blocks.firstIndex(where: { $0.id == block.id }) {
                        withAnimation(.spring(response: 0.3)) {
                            planner.todayRoutine.blocks[idx].isCompleted = true
                            planner.objectWillChange.send()
                        }
                        HapticManager.notification(.success)
                        GameEngineManager.shared.awardXP(amount: 5, source: block.displayTitle, icon: "checkmark.circle.fill")
                    }
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(block.isCompleted ? AppTheme.healthGreen.opacity(0.2) : block.type.lightColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: block.isCompleted ? "checkmark.circle.fill" : block.type.icon)
                            .font(.body)
                            .foregroundStyle(block.isCompleted ? AppTheme.healthGreen : block.type.lightColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(block.displayTitle)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(block.isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary)
                            .strikethrough(block.isCompleted, color: AppTheme.textTertiary)
                        HStack(spacing: 6) {
                            if block.isCompleted {
                                Text("Completed ✓")
                                    .font(.system(.caption2, design: .rounded, weight: .medium))
                                    .foregroundStyle(AppTheme.healthGreen)
                            } else {
                                Text("\(block.durationMinutes) min")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(AppTheme.textTertiary)
                                if block.type == .study {
                                    Text("• \(block.sessionDescription)")
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundStyle(AppTheme.primaryPurple)
                                } else if block.type.canCompleteManually {
                                    Text("• Tap to complete")
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundStyle(block.type.lightColor.opacity(0.7))
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if block.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.healthGreen)
                    } else if block.type == .study {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(block.type.lightColor)
                    } else if block.type.canCompleteManually {
                        Image(systemName: "circle")
                            .font(.title3)
                            .foregroundStyle(block.type.lightColor.opacity(0.5))
                    }
                }
                .padding(14)
                .background(block.isCompleted ? AppTheme.healthGreen.opacity(0.04) : Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(block.isCompleted ? AppTheme.healthGreen.opacity(0.3) : block.type.lightColor.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(block.isCompleted)
        }
        .padding(.vertical, 4)
    }
}
