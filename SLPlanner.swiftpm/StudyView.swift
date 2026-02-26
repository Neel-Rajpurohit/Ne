import SwiftUI

// MARK: - Study View
struct StudyView: View {
    @StateObject private var vm = StudyViewModel()
    @State private var showTimer = false
    @State private var selectedSubject: Subject?
    @State private var newSubjectName = ""
    @State private var newSubjectColor = "3B82F6"
    @State private var newAssignmentTitle = ""
    @State private var newAssignmentDue = Date()
    @State private var newAssignmentPriority: AssignmentPriority = .medium
    @State private var newAssignmentSubjectId: UUID?
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Stats
                    statsRow
                    
                    // Study Timer Button
                    Button(action: { showTimer = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "timer")
                                .font(.title2)
                            Text("Start 60-min Pomodoro")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(18)
                        .background(AppTheme.studyGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppTheme.studyBlue.opacity(0.4), radius: 10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .opacity(appeared ? 1 : 0)
                    
                    // Subjects
                    subjectSection
                    
                    // Assignments
                    assignmentSection
                    
                    // Recent Sessions
                    recentSessionsSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Study")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { vm.showAddSubject = true }) {
                            Label("Add Subject", systemImage: "plus.rectangle.fill")
                        }
                        Button(action: { vm.showAddAssignment = true }) {
                            Label("Add Assignment", systemImage: "doc.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.studyGradient)
                    }
                }
            }
            .sheet(isPresented: $showTimer) {
                StudyTimerView(subjects: vm.subjects) { subjectId, minutes in
                    vm.recordSession(subjectId: subjectId, durationMinutes: minutes)
                }
            }
            .alert("Add Subject", isPresented: $vm.showAddSubject) {
                TextField("Subject Name", text: $newSubjectName)
                Button("Add") {
                    if !newSubjectName.isEmpty {
                        vm.addSubject(Subject(name: newSubjectName, colorHex: ["3B82F6","8B5CF6","10B981","F59E0B","EC4899"].randomElement()!))
                        newSubjectName = ""
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Add Assignment", isPresented: $vm.showAddAssignment) {
                TextField("Assignment Title", text: $newAssignmentTitle)
                Button("Add") {
                    if !newAssignmentTitle.isEmpty, let subId = vm.subjects.first?.id {
                        vm.addAssignment(Assignment(title: newAssignmentTitle, subjectId: subId, dueDate: Date().addingTimeInterval(86400 * 3)))
                        newAssignmentTitle = ""
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appeared = true }
            }
        }
    }
    
    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(icon: "clock.fill", label: "Today", value: "\(vm.totalStudyMinutesToday)m", color: AppTheme.studyBlue)
            statCard(icon: "calendar", label: "This Week", value: "\(vm.totalStudyMinutesThisWeek / 60)h", color: AppTheme.primaryPurple)
            statCard(icon: "brain.head.profile", label: "Focus", value: vm.averageFocusScore > 0 ? "\(vm.averageFocusScore)%" : "—", color: AppTheme.neonCyan)
        }
        .opacity(appeared ? 1 : 0)
    }
    
    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16).glassBackground(cornerRadius: 16)
    }
    
    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subjects").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
            
            ForEach(vm.subjects) { subject in
                HStack(spacing: 12) {
                    Circle().fill(subject.color).frame(width: 12, height: 12)
                    Text(subject.name).font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text("\(subject.totalStudyMinutes)m").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.vertical, 6)
            }
        }
        .padding(20).glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    private var assignmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Assignments").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("\(vm.pendingAssignments.count) pending").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
            }
            
            if vm.pendingAssignments.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill").font(.largeTitle).foregroundStyle(AppTheme.healthGreen)
                        Text("All caught up!").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                    }.padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(vm.pendingAssignments) { assignment in
                    HStack(spacing: 12) {
                        Button(action: { vm.toggleAssignment(assignment.id); HapticManager.impact(.light) }) {
                            Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(assignment.isCompleted ? AppTheme.healthGreen : AppTheme.textTertiary)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(assignment.title).font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                                .strikethrough(assignment.isCompleted)
                            HStack(spacing: 8) {
                                if let subj = vm.subject(for: assignment.subjectId) {
                                    Text(subj.name).font(.system(.caption2, design: .rounded)).foregroundStyle(subj.color)
                                }
                                Text("Due \(assignment.dueDate.formattedDate)").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                        Spacer()
                        Image(systemName: assignment.priority.icon).foregroundStyle(assignment.priority.color).font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(20).glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    // MARK: - Recent Sessions
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath").foregroundStyle(AppTheme.neonCyan)
                Text("Recent Sessions")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
            }
            
            let sessions = loadRecentSessions()
            if sessions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "book.closed.fill").font(.largeTitle).foregroundStyle(AppTheme.textTertiary)
                        Text("No sessions yet").font(.system(.subheadline, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                        Text("Start a Pomodoro to see stats").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                    }.padding(.vertical, 16)
                    Spacer()
                }
            } else {
                ForEach(sessions.prefix(5)) { session in
                    HStack(spacing: 12) {
                        Circle().fill(session.subjectColor).frame(width: 10, height: 10)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.subjectName)
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("\(session.totalStudyMinutes)m study · \(session.cyclesCompleted) cycles")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill").font(.caption2).foregroundStyle(AppTheme.warmOrange)
                                Text("+\(session.xpEarned)").font(.system(.caption2, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.warmOrange)
                            }
                            Text(session.completedDate.formattedDate)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(20).glassBackground()
        .opacity(appeared ? 1 : 0)
    }
    
    private func loadRecentSessions() -> [PomodoroSession] {
        let key = "pomodoroSessions"
        guard let data = UserDefaults.standard.data(forKey: key),
              let sessions = try? JSONDecoder().decode([PomodoroSession].self, from: data) else {
            return []
        }
        return sessions.sorted { $0.completedDate > $1.completedDate }
    }
}
