import SwiftUI
import PDFKit

// MARK: - Personal Quiz Creator View
struct PersonalQuizCreatorView: View {
    @StateObject private var manager = PersonalQuizManager.shared
    @State private var quizTitle: String = ""
    @State private var questions: [PersonalQuestion] = []
    @State private var showAddQuestion = false
    @State private var showPDFImporter = false
    @State private var pdfText: String = ""
    @State private var isProcessing = false
    @State private var appeared = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Title Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quiz Title").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                        TextField("e.g. Biology Chapter 3", text: $quizTitle)
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(20).glassBackground()
                    .opacity(appeared ? 1 : 0)
                    
                    // Import PDF
                    VStack(spacing: 14) {
                        Button(action: { showPDFImporter = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.fill").font(.title2).foregroundStyle(AppTheme.quizGradient)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Import PDF").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                                    Text("Auto-generate questions from your notes").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.doc.fill").foregroundStyle(AppTheme.quizPink)
                            }
                            .padding(16).glassBackground()
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        if isProcessing {
                            HStack(spacing: 10) {
                                ProgressView().tint(AppTheme.quizPink)
                                Text("Generating questions...").font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        
                        if !pdfText.isEmpty && questions.isEmpty {
                            Button(action: generateFromPDF) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Generate Quiz from PDF").font(.system(.subheadline, design: .rounded, weight: .bold))
                                }
                                .foregroundStyle(.white).frame(maxWidth: .infinity).padding(14)
                                .background(AppTheme.quizGradient).clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    
                    // Divider
                    HStack {
                        Rectangle().fill(AppTheme.cardBorder).frame(height: 1)
                        Text("OR").font(.system(.caption2, design: .rounded, weight: .bold)).foregroundStyle(AppTheme.textTertiary)
                        Rectangle().fill(AppTheme.cardBorder).frame(height: 1)
                    }
                    
                    // Manual Add
                    Button(action: { showAddQuestion = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Question Manually").font(.system(.subheadline, design: .rounded, weight: .semibold))
                        }
                        .foregroundStyle(AppTheme.quizPink).frame(maxWidth: .infinity).padding(14)
                        .background(AppTheme.quizPink.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .opacity(appeared ? 1 : 0)
                    
                    // Questions List
                    if !questions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(questions.count) Questions").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                            
                            ForEach(questions.indices, id: \.self) { idx in
                                HStack(spacing: 12) {
                                    Text("\(idx + 1)").font(.system(.caption, design: .rounded, weight: .bold))
                                        .frame(width: 28, height: 28).background(AppTheme.quizPink.opacity(0.2)).foregroundStyle(AppTheme.quizPink)
                                        .clipShape(Circle())
                                    
                                    Text(questions[idx].question)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(AppTheme.textPrimary)
                                        .lineLimit(2)
                                    
                                    Spacer()
                                    
                                    Button(action: { questions.remove(at: idx) }) {
                                        Image(systemName: "trash").font(.caption).foregroundStyle(AppTheme.dangerRed)
                                    }
                                }
                                .padding(.vertical, 6)
                                if idx < questions.count - 1 {
                                    Divider().overlay(AppTheme.cardBorder)
                                }
                            }
                        }
                        .padding(20).glassBackground()
                    }
                    
                    // Save Button
                    if !questions.isEmpty {
                        Button(action: saveQuiz) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Quiz (\(questions.count) Qs)").font(.system(.headline, design: .rounded, weight: .bold))
                            }
                            .foregroundStyle(.white).frame(maxWidth: .infinity).padding(16)
                            .background(AppTheme.quizGradient).clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: AppTheme.quizPink.opacity(0.3), radius: 10)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20).padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Create Quiz")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary)
                }
            }
            .sheet(isPresented: $showAddQuestion) {
                AddQuestionSheet(onSave: { q in questions.append(q) })
            }
            .fileImporter(isPresented: $showPDFImporter, allowedContentTypes: [.pdf]) { result in
                handlePDF(result)
            }
            .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
        }
    }
    
    // MARK: - PDF Handling
    private func handlePDF(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            if let pdf = PDFDocument(url: url) {
                var text = ""
                for i in 0..<pdf.pageCount {
                    if let page = pdf.page(at: i), let content = page.string {
                        text += content + " "
                    }
                }
                pdfText = text
                if quizTitle.isEmpty {
                    quizTitle = url.deletingPathExtension().lastPathComponent
                }
                HapticManager.notification(.success)
            }
        case .failure:
            HapticManager.notification(.error)
        }
    }
    
    private func generateFromPDF() {
        isProcessing = true
        // Small delay for animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            questions = PersonalQuizManager.generateQuestions(from: pdfText, count: 10)
            isProcessing = false
            HapticManager.notification(.success)
        }
    }
    
    private func saveQuiz() {
        let title = quizTitle.isEmpty ? "My Quiz" : quizTitle
        let quiz = PersonalQuiz(title: title, questions: questions)
        manager.addQuiz(quiz)
        HapticManager.notification(.success)
        dismiss()
    }
}

// MARK: - Add Question Sheet
struct AddQuestionSheet: View {
    var onSave: (PersonalQuestion) -> Void
    
    @State private var questionText = ""
    @State private var optionA = ""
    @State private var optionB = ""
    @State private var optionC = ""
    @State private var optionD = ""
    @State private var correctOption = 0
    @Environment(\.dismiss) private var dismiss
    
    var isValid: Bool {
        !questionText.isEmpty && !optionA.isEmpty && !optionB.isEmpty && !optionC.isEmpty && !optionD.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Question
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Question").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                        TextField("Type your question...", text: $questionText)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(14).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(20).glassBackground()
                    
                    // Options
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Options").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                        
                        optionField(letter: "A", text: $optionA, index: 0)
                        optionField(letter: "B", text: $optionB, index: 1)
                        optionField(letter: "C", text: $optionC, index: 2)
                        optionField(letter: "D", text: $optionD, index: 3)
                        
                        Text("Tap the letter to mark correct answer").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(20).glassBackground()
                    
                    // Save
                    Button(action: save) {
                        Text("Add Question").font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white).frame(maxWidth: .infinity).padding(16)
                            .background(isValid ? AnyShapeStyle(AppTheme.quizGradient) : AnyShapeStyle(Color.gray.opacity(0.3)))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!isValid)
                    .buttonStyle(ScaleButtonStyle())
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20).padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Add Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
    
    private func optionField(letter: String, text: Binding<String>, index: Int) -> some View {
        HStack(spacing: 12) {
            Button(action: { correctOption = index; HapticManager.selection() }) {
                Text(letter).font(.system(.caption, design: .rounded, weight: .bold))
                    .frame(width: 32, height: 32)
                    .background(correctOption == index ? AppTheme.healthGreen : Color.white.opacity(0.15))
                    .foregroundStyle(correctOption == index ? .white : AppTheme.textSecondary)
                    .clipShape(Circle())
            }
            TextField("Option \(letter)", text: text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(12).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private func save() {
        let q = PersonalQuestion(question: questionText, options: [optionA, optionB, optionC, optionD], correctIndex: correctOption)
        onSave(q)
        dismiss()
    }
}
