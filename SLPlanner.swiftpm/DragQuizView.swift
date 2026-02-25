import SwiftUI

// MARK: - Drag & Match Quiz View
struct DragQuizView: View {
    let questions: [PersonalQuestion]
    
    @State private var terms: [String] = []
    @State private var definitions: [String] = []
    @State private var matches: [String: String] = [:]      // term -> selected definition
    @State private var correctMap: [String: String] = [:]    // term -> correct definition
    @State private var selectedTerm: String?
    @State private var showResult = false
    @State private var appeared = false
    @Environment(\.dismiss) private var dismiss
    
    var correctCount: Int {
        matches.filter { correctMap[$0.key] == $0.value }.count
    }
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if showResult {
                resultView
            } else {
                matchView
            }
        }
        .onAppear { setupPairs() }
    }
    
    // MARK: - Match View
    private var matchView: some View {
        VStack(spacing: 20) {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(AppTheme.textTertiary)
                }
                Spacer()
                Text("Match Terms").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("\(matches.count)/\(terms.count)")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.neonCyan)
            }
            .padding(.horizontal, 20).padding(.top, 20)
            
            Text("Tap a term, then tap its match")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
            
            // Terms & Definitions side by side
            HStack(alignment: .top, spacing: 12) {
                // Terms column
                VStack(spacing: 10) {
                    Text("Terms").font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.studyBlue)
                    ForEach(terms, id: \.self) { term in
                        Button(action: { selectTerm(term) }) {
                            Text(term)
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundStyle(termColor(term))
                                .frame(maxWidth: .infinity).padding(12)
                                .background(termBG(term))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(termBorder(term), lineWidth: 2))
                        }
                        .disabled(matches[term] != nil)
                    }
                }
                
                // Definitions column
                VStack(spacing: 10) {
                    Text("Definitions").font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.healthGreen)
                    ForEach(definitions, id: \.self) { def in
                        Button(action: { selectDefinition(def) }) {
                            Text(def)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(defColor(def))
                                .frame(maxWidth: .infinity).padding(12)
                                .background(defBG(def))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(defBorder(def), lineWidth: 2))
                        }
                        .disabled(matches.values.contains(def))
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Check Button
            if matches.count == terms.count {
                Button(action: { showResult = true; awardXP() }) {
                    Text("Check Answers").font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white).frame(maxWidth: .infinity).padding(16)
                        .background(AppTheme.quizGradient).clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)
            }
            
            // Reset
            if !matches.isEmpty {
                Button(action: { matches.removeAll(); selectedTerm = nil }) {
                    Text("Reset").font(.system(.caption, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.dangerRed)
                }
            }
            
            Spacer(minLength: 30)
        }
    }
    
    // MARK: - Result
    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: correctCount == terms.count ? "trophy.fill" : "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(correctCount == terms.count ? AppTheme.warmOrange : AppTheme.quizPink)
            Text("\(correctCount)/\(terms.count) Matched")
                .font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            
            // Show correct matches
            VStack(alignment: .leading, spacing: 10) {
                ForEach(terms, id: \.self) { term in
                    let userDef = matches[term] ?? ""
                    let correct = correctMap[term] == userDef
                    HStack(spacing: 8) {
                        Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(correct ? AppTheme.healthGreen : AppTheme.dangerRed)
                        Text(term).font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        Image(systemName: "arrow.right").font(.caption2).foregroundStyle(AppTheme.textTertiary)
                        Text(correctMap[term] ?? "").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary).lineLimit(1)
                    }
                }
            }
            .padding(20).glassBackground().padding(.horizontal, 20)
            
            Spacer()
            Button(action: { dismiss() }) {
                Text("Done").font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(16).background(AppTheme.quizGradient).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20).padding(.bottom, 40)
        }
    }
    
    // MARK: - Logic
    private func setupPairs() {
        // Use questions: term = correct answer, definition = question text
        let subset = Array(questions.shuffled().prefix(6))
        for q in subset {
            let term = q.options[q.correctIndex]
            let def = q.question.replacingOccurrences(of: "______", with: "?")
            terms.append(term)
            definitions.append(def)
            correctMap[term] = def
        }
        definitions.shuffle()
    }
    
    private func selectTerm(_ term: String) {
        selectedTerm = term; HapticManager.selection()
    }
    
    private func selectDefinition(_ def: String) {
        guard let term = selectedTerm else { return }
        matches[term] = def
        selectedTerm = nil
        HapticManager.impact(.light)
    }
    
    private func awardXP() {
        let xp = correctCount * GameEngineManager.xpQuizCorrect
        GameEngineManager.shared.awardXP(amount: xp, source: "Drag & Match", icon: "arrow.triangle.swap")
        HapticManager.notification(.success)
    }
    
    // MARK: - Colors
    private func termColor(_ t: String) -> Color { selectedTerm == t ? .white : matches[t] != nil ? AppTheme.textTertiary : AppTheme.textPrimary }
    private func termBG(_ t: String) -> Color { selectedTerm == t ? AppTheme.studyBlue : matches[t] != nil ? Color.white.opacity(0.03) : Color.white.opacity(0.08) }
    private func termBorder(_ t: String) -> Color { selectedTerm == t ? AppTheme.studyBlue : Color.clear }
    private func defColor(_ d: String) -> Color { matches.values.contains(d) ? AppTheme.textTertiary : AppTheme.textPrimary }
    private func defBG(_ d: String) -> Color { matches.values.contains(d) ? Color.white.opacity(0.03) : Color.white.opacity(0.08) }
    private func defBorder(_ d: String) -> Color { selectedTerm != nil && !matches.values.contains(d) ? AppTheme.healthGreen.opacity(0.5) : Color.clear }
}
