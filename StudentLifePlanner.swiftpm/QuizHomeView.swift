import SwiftUI

// MARK: - Quiz Home View
struct QuizHomeView: View {
    @StateObject private var quizManager = QuizManager.shared
    @StateObject private var personalManager = PersonalQuizManager.shared
    @State private var selectedCategory: QuizCategory?
    @State private var showQuiz = false
    @State private var showCreator = false
    @State private var selectedPersonalQuiz: PersonalQuiz?
    @State private var showPersonalPlay = false
    @State private var showYesNo = false
    @State private var showDragMatch = false
    @State private var quizTypeForPersonal: String = "mcq"
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Stats Header
                    HStack(spacing: 12) {
                        statBubble(icon: "brain.head.profile", value: "\(quizManager.totalQuizzesTaken)", label: "Quizzes", color: AppTheme.quizPink)
                        statBubble(icon: "target", value: quizManager.averageAccuracy > 0 ? "\(Int(quizManager.averageAccuracy * 100))%" : "—", label: "Accuracy", color: AppTheme.neonCyan)
                        statBubble(icon: "star.fill", value: "\(quizManager.results.reduce(0) { $0 + $1.xpEarned })", label: "Total XP", color: AppTheme.warmOrange)
                    }
                    .opacity(appeared ? 1 : 0)
                    
                    // MARK: - My Quizzes (Personal)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "doc.text.fill").foregroundStyle(AppTheme.quizGradient)
                            Text("My Quizzes").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Button(action: { showCreator = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create").font(.system(.caption, design: .rounded, weight: .bold))
                                }
                                .foregroundStyle(AppTheme.quizPink)
                            }
                        }
                        
                        // Create from PDF
                        Button(action: { showCreator = true }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10).fill(AppTheme.quizPink.opacity(0.15)).frame(width: 44, height: 44)
                                    Image(systemName: "doc.badge.plus").foregroundStyle(AppTheme.quizGradient)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Import PDF & Create Quiz").font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                                    Text("Upload notes, auto-generate questions").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary).lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundStyle(AppTheme.textTertiary)
                            }
                            .padding(14).glassBackground()
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Saved Personal Quizzes
                        if !personalManager.quizzes.isEmpty {
                            ForEach(personalManager.quizzes) { quiz in
                                personalQuizRow(quiz)
                            }
                        }
                    }
                    .padding(20).glassBackground()
                    .opacity(appeared ? 1 : 0)
                    
                    // MARK: - GK Quiz Categories
                    VStack(alignment: .leading, spacing: 14) {
                        Text("GK Quiz").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                        
                        Button(action: { selectedCategory = nil; showQuiz = true }) {
                            categoryRow(icon: "sparkles", name: "All Categories", count: quizManager.questionBank.count)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        ForEach(QuizCategory.allCases, id: \.self) { cat in
                            Button(action: { selectedCategory = cat; showQuiz = true }) {
                                let count = quizManager.questionBank.filter { $0.category == cat }.count
                                categoryRow(icon: cat.icon, name: cat.rawValue, count: count)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    
                    // Recent Results
                    if !quizManager.results.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Results").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                            ForEach(quizManager.results.prefix(5)) { result in
                                HStack(spacing: 12) {
                                    Image(systemName: result.category.icon).foregroundStyle(AppTheme.quizPink)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.category.rawValue).font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                                        Text(result.date.formattedDate).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(result.score).font(.system(.subheadline, design: .rounded, weight: .bold)).foregroundStyle(result.accuracy >= 0.7 ? AppTheme.healthGreen : AppTheme.warmOrange)
                                        Text("+\(result.xpEarned) XP").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.warmOrange)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(20).glassBackground()
                        .opacity(appeared ? 1 : 0)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20).padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(isPresented: $showQuiz) { QuizPlayView(category: selectedCategory) }
            .fullScreenCover(isPresented: $showCreator) { PersonalQuizCreatorView() }
            .fullScreenCover(isPresented: $showPersonalPlay) {
                if let q = selectedPersonalQuiz, !q.questions.isEmpty { PersonalQuizPlayView(quiz: q) }
            }
            .fullScreenCover(isPresented: $showYesNo) {
                if let q = selectedPersonalQuiz, !q.questions.isEmpty { YesNoQuizView(questions: q.questions) }
            }
            .fullScreenCover(isPresented: $showDragMatch) {
                if let q = selectedPersonalQuiz, !q.questions.isEmpty { DragQuizView(questions: q.questions) }
            }
            .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
        }
    }
    
    // MARK: - Personal Quiz Row with Type Selector
    private func personalQuizRow(_ quiz: PersonalQuiz) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(AppTheme.quizPink.opacity(0.15)).frame(width: 40, height: 40)
                    Text("📝").font(.title3)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(quiz.title).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                    Text("\(quiz.questionCount) questions").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
            }
            
            // Quiz Type Buttons
            HStack(spacing: 8) {
                quizTypeButton(label: "MCQ", icon: "list.bullet", quiz: quiz) {
                    selectedPersonalQuiz = quiz; showPersonalPlay = true
                }
                quizTypeButton(label: "Yes/No", icon: "checkmark.circle", quiz: quiz) {
                    selectedPersonalQuiz = quiz; showYesNo = true
                }
                quizTypeButton(label: "Match", icon: "arrow.triangle.swap", quiz: quiz) {
                    selectedPersonalQuiz = quiz; showDragMatch = true
                }
            }
        }
        .padding(12)
    }
    
    private func quizTypeButton(label: String, icon: String, quiz: PersonalQuiz, action: @escaping () -> Void) -> some View {
        Button(action: { action(); HapticManager.impact(.light) }) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.caption).foregroundStyle(AppTheme.quizPink)
                Text(label).font(.system(.caption2, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(AppTheme.quizPink.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func statBubble(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Text(label).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16).glassBackground(cornerRadius: 16)
    }
    
    private func categoryRow(icon: String, name: String, count: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(AppTheme.quizPink.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).foregroundStyle(AppTheme.quizGradient)
            }
            Text(name).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Text("\(count) Qs").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(AppTheme.textTertiary)
        }
        .padding(14).glassBackground()
    }
}
