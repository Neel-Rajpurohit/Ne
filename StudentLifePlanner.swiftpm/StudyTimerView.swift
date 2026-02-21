import SwiftUI

// MARK: - Study Timer View
struct StudyTimerView: View {
    let subjects: [Subject]
    var onComplete: (UUID, Int) -> Void
    
    @StateObject private var timer = TimerManager()
    @State private var selectedSubjectId: UUID?
    @State private var selectedMinutes: Int = 25
    @State private var isStudying = false
    @State private var ringScale: CGFloat = 1.0
    @Environment(\.dismiss) private var dismiss
    
    let minuteOptions = [15, 25, 30, 45, 60, 90]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.mainGradient.ignoresSafeArea()
                
                if isStudying {
                    timerActiveView
                } else {
                    setupView
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Setup View
    private var setupView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.studyGradient)
            
            Text("Focus Session")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            // Subject Picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Subject").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(subjects) { subj in
                            Button(action: { selectedSubjectId = subj.id; HapticManager.selection() }) {
                                Text(subj.name)
                                    .font(.system(.caption, design: .rounded, weight: .semibold))
                                    .foregroundStyle(selectedSubjectId == subj.id ? .white : subj.color)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(selectedSubjectId == subj.id ? AnyShapeStyle(subj.color) : AnyShapeStyle(subj.color.opacity(0.15)))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Duration Picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Duration").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    ForEach(minuteOptions, id: \.self) { min in
                        Button(action: { selectedMinutes = min; HapticManager.selection() }) {
                            Text("\(min)m")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(selectedMinutes == min ? .white : AppTheme.studyBlue)
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .background(selectedMinutes == min ? AnyShapeStyle(AppTheme.studyGradient) : AnyShapeStyle(AppTheme.studyBlue.opacity(0.15)))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Start Button
            Button(action: startStudying) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text("Start Studying")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(18)
                .background(AppTheme.studyGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20)
            .disabled(selectedSubjectId == nil)
            .opacity(selectedSubjectId == nil ? 0.5 : 1)
            
            Spacer()
        }
    }
    
    // MARK: - Timer Active View
    private var timerActiveView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(AppTheme.studyGradient, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timer.progress)
                
                VStack(spacing: 8) {
                    Text(timer.formattedTime)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Focus Mode")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .scaleEffect(ringScale)
            
            // Controls
            HStack(spacing: 30) {
                Button(action: { timer.stop(); isStudying = false }) {
                    Image(systemName: "stop.fill")
                        .font(.title2).foregroundStyle(AppTheme.dangerRed)
                        .frame(width: 60, height: 60)
                        .background(AppTheme.dangerRed.opacity(0.15))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    if timer.isPaused { timer.resume() } else { timer.pause() }
                    HapticManager.impact(.medium)
                }) {
                    Image(systemName: timer.isPaused ? "play.fill" : "pause.fill")
                        .font(.title).foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(AppTheme.studyGradient)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.studyBlue.opacity(0.4), radius: 10)
                }
            }
            
            Spacer()
        }
        .onChange(of: timer.isCompleted) { _ in
            if timer.isCompleted { completeSession() }
        }
    }
    
    private func startStudying() {
        guard selectedSubjectId != nil else { return }
        isStudying = true
        timer.start(duration: selectedMinutes * 60)
        HapticManager.impact(.heavy)
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            ringScale = 1.02
        }
    }
    
    private func completeSession() {
        guard let subId = selectedSubjectId else { return }
        let actualMinutes = max(1, (timer.totalTime - timer.timeRemaining) / 60)
        onComplete(subId, actualMinutes)
        HapticManager.notification(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
    }
}
