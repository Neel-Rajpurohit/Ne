import SwiftUI

// MARK: - Daily Tasks View
struct DailyTasksView: View {
    @StateObject private var taskManager = TaskCompletionManager.shared
    @StateObject private var storage = StorageManager.shared
    @State private var selectedSegment = 0
    @State private var showAddSheet = false
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Completion Ring
                completionHeader
                
                // Segment Picker
                Picker("Tasks", selection: $selectedSegment) {
                    Text("Health (\(taskManager.dailyTaskSet.autoTasks.count))").tag(0)
                    Text("My Tasks (\(taskManager.dailyTaskSet.manualTasks.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 4)
                
                // Task Cards
                let tasks = selectedSegment == 0
                    ? taskManager.dailyTaskSet.autoTasks
                    : taskManager.dailyTaskSet.manualTasks
                
                if tasks.isEmpty {
                    emptyState
                } else {
                    ForEach(tasks) { task in
                        taskCard(task)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                
                // Analytics Summary
                analyticsCard
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationTitle("Daily Tasks")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.neonCyan)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTaskSheet()
        }
        .onAppear {
            taskManager.checkHealthTasks()
            withAnimation(.spring(response: 0.6)) { appeared = true }
        }
    }
    
    // MARK: - Completion Header
    private var completionHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: taskManager.dailyTaskSet.completionRate)
                    .stroke(
                        LinearGradient(
                            colors: [AppTheme.healthGreen, AppTheme.neonCyan],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8), value: taskManager.dailyTaskSet.completionRate)
                
                // Center text
                VStack(spacing: 2) {
                    Text("\(taskManager.dailyTaskSet.completionPercent)%")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("\(taskManager.dailyTaskSet.completedCount)/\(taskManager.dailyTaskSet.totalCount)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            
            HStack(spacing: 16) {
                statPill(icon: "star.fill", value: "\(taskManager.dailyTaskSet.totalXPEarned)", label: "XP Earned", color: AppTheme.warmOrange)
                statPill(icon: "flame.fill", value: "\(storage.streakData.currentStreak)", label: "Streak", color: Color(hex: "EF4444"))
            }
        }
        .padding(20)
        .glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    private func statPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.caption).foregroundStyle(color)
            Text(value).font(.system(.subheadline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassBackground(cornerRadius: 12)
    }
    
    // MARK: - Task Card
    private func taskCard(_ task: DailyTask) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(task.isCompleted ? AppTheme.healthGreen.opacity(0.2) : task.category.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : task.category.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(task.isCompleted ? AppTheme.healthGreen : task.category.color)
                }
                
                // Title & Progress
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(task.isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary)
                        .strikethrough(task.isCompleted, color: AppTheme.textTertiary)
                    
                    if task.goalValue > 0 && !task.category.unit.isEmpty {
                        Text("\(task.currentDisplay) / \(task.goalDisplay) \(task.category.unit)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                // Status / Action
                if task.isCompleted {
                    XPBadgeView(xp: task.rewardXP)
                } else if task.canCompleteManually {
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            taskManager.completeManualTask(id: task.id)
                        }
                    }) {
                        Text("Complete")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.healthGreen)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                } else if task.type == .auto {
                    // Auto tasks show progress %
                    Text("\(task.progressPercent)%")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(task.category.color)
                }
            }
            
            // Progress bar
            if task.goalValue > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                task.isCompleted
                                    ? LinearGradient(colors: [AppTheme.healthGreen, AppTheme.neonCyan], startPoint: .leading, endPoint: .trailing)
                                    : task.category.gradient
                            )
                            .frame(width: geo.size.width * task.progress)
                            .animation(.spring(response: 0.5), value: task.progress)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .glassBackground(cornerRadius: 16)
        .taskCompletedGlow(isCompleted: task.isCompleted, color: task.category.color)
        .opacity(appeared ? 1 : 0)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: selectedSegment == 0 ? "heart.fill" : "checklist")
                .font(.system(size: 40))
                .foregroundStyle(AppTheme.textTertiary)
            Text(selectedSegment == 0 ? "No health tasks" : "No custom tasks yet")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
            if selectedSegment == 1 {
                Text("Tap + to add a task")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .padding(40)
    }
    
    // MARK: - Analytics Card
    private var analyticsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill").foregroundStyle(AppTheme.primaryPurple)
                Text("Task Analytics")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                analyticsPill(
                    label: "Completion",
                    value: "\(taskManager.completionRate)%",
                    icon: "checkmark.circle",
                    color: AppTheme.healthGreen
                )
                analyticsPill(
                    label: "Consistency",
                    value: "\(taskManager.consistencyScore())%",
                    icon: "calendar.badge.checkmark",
                    color: AppTheme.studyBlue
                )
                
                let trend = taskManager.performanceTrend()
                analyticsPill(
                    label: "Trend",
                    value: trend.rawValue,
                    icon: trend.icon,
                    color: trend.color
                )
            }
        }
        .padding(20)
        .glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    private func analyticsPill(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.caption).foregroundStyle(color)
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .glassBackground(cornerRadius: 12)
    }
}

// MARK: - Add Task Sheet
struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedCategory: TaskCategory = .custom
    @State private var goalValue = ""
    
    private let manualCategories: [TaskCategory] = [.homework, .study, .meditation, .gym, .custom]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Name") {
                    TextField("e.g. Read 30 pages", text: $title)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(manualCategories, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if selectedCategory.usesTimer || selectedCategory == .custom {
                    Section("Goal (\(selectedCategory.unit.isEmpty ? "times" : selectedCategory.unit))") {
                        TextField("e.g. 30", text: $goalValue)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let goal = Double(goalValue) ?? 1.0
                        TaskCompletionManager.shared.addCustomTask(
                            title: title.isEmpty ? selectedCategory.rawValue : title,
                            category: selectedCategory,
                            goalValue: goal
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty && selectedCategory == .custom)
                }
            }
        }
        .presentationDetents([.medium])
    }
}


