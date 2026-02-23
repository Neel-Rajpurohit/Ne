import SwiftUI

// MARK: - Quiz & Games Home View
struct QuizHomeView: View {
    @StateObject private var quizManager = QuizManager.shared
    @StateObject private var personalManager = PersonalQuizManager.shared
    @StateObject private var brainScore = BrainScoreManager.shared
    @State private var selectedCategory: QuizCategory?
    @State private var showQuiz = false
    @State private var showCreator = false
    @State private var selectedPersonalQuiz: PersonalQuiz?
    @State private var showPersonalPlay = false
    @State private var showBrainMatch = false
    @State private var showMemoryCards = false
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Stats Header
                    HStack(spacing: 12) {
                        statBubble(icon: "brain.head.profile", value: "\(quizManager.totalQuizzesTaken)", label: "Quizzes", color: AppTheme.quizPink)
                        statBubble(icon: "target", value: quizManager.averageAccuracy > 0 ? "\(Int(quizManager.averageAccuracy * 100))%" : "—", label: "Accuracy", color: AppTheme.neonCyan)
                        statBubble(icon: "gamecontroller.fill", value: "\(brainScore.todayScore.gamesPlayed)", label: "Games", color: AppTheme.primaryPurple)
                    }
                    .opacity(appeared ? 1 : 0)
                    
                    // MARK: - 🎮 Brain Games
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "gamecontroller.fill").foregroundStyle(AppTheme.primaryPurple)
                            Text("Brain Games").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Text("🧠 \(brainScore.todayScore.performancePercent)%")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .foregroundStyle(AppTheme.neonCyan)
                        }
                        
                        
                        // Brain Match
                        Button(action: { showBrainMatch = true; HapticManager.impact(.light) }) {
                            gameRow(
                                icon: "square.grid.3x3.fill",
                                name: "Brain Match",
                                subtitle: "Match 3 shapes • Pattern recognition",
                                color: AppTheme.quizPink,
                                gradient: LinearGradient(colors: [AppTheme.quizPink, AppTheme.primaryPurple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                score: brainScore.todayScore.speedPoints
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Memory Cards
                        Button(action: { showMemoryCards = true; HapticManager.impact(.light) }) {
                            gameRow(
                                icon: "rectangle.on.rectangle.angled",
                                name: "Memory Cards",
                                subtitle: "Find matching pairs • Boost memory",
                                color: AppTheme.primaryPurple,
                                gradient: LinearGradient(colors: [AppTheme.primaryPurple, AppTheme.primaryIndigo], startPoint: .topLeading, endPoint: .bottomTrailing),
                                score: brainScore.todayScore.memoryPoints
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(20).glassBackground()
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
            .navigationTitle("Quiz & Games")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(isPresented: $showQuiz) { QuizPlayView(category: selectedCategory) }
            .fullScreenCover(isPresented: $showCreator) { PersonalQuizCreatorView() }
            .fullScreenCover(isPresented: $showPersonalPlay) {
                if let q = selectedPersonalQuiz, !q.questions.isEmpty { PersonalQuizPlayView(quiz: q) }
            }
            .fullScreenCover(isPresented: $showBrainMatch) { BrainMatchView() }
            .fullScreenCover(isPresented: $showMemoryCards) { CardFlipView() }
            .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
        }
    }
    
    // MARK: - Game Row
    private func gameRow(icon: String, name: String, subtitle: String, color: Color, gradient: LinearGradient, score: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(gradient)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            if score > 0 {
                Text("\(score) pts")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(color.opacity(0.12))
                    .clipShape(Capsule())
            }
            Image(systemName: "play.circle.fill")
                .font(.title3)
                .foregroundStyle(gradient)
        }
        .padding(14).glassBackground()
    }
    
    // MARK: - Personal Quiz Row
    private func personalQuizRow(_ quiz: PersonalQuiz) -> some View {
        Button(action: {
            selectedPersonalQuiz = quiz
            showPersonalPlay = true
            HapticManager.impact(.light)
        }) {
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
                Image(systemName: "play.circle.fill").font(.title3).foregroundStyle(AppTheme.quizPink)
            }
            .padding(14).glassBackground()
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
