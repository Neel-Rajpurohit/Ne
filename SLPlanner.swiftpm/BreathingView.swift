import SwiftUI

// MARK: - Breathing Animation View (Reusable Component)
struct BreathingAnimationView: View {
    @ObservedObject var animationManager: AnimationManager
    let gradient: LinearGradient

    var body: some View {
        ZStack {
            // Outer Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.breathingCyan.opacity(0.2), .clear],
                        center: .center, startRadius: 20, endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .scaleEffect(animationManager.circleScale)

            // Middle ring
            Circle()
                .stroke(AppTheme.breathingCyan.opacity(0.15), lineWidth: 2)
                .frame(width: 220, height: 220)
                .scaleEffect(animationManager.circleScale)

            // Main circle
            Circle()
                .fill(gradient.opacity(0.3))
                .frame(width: 180, height: 180)
                .scaleEffect(animationManager.circleScale)
                .overlay(
                    Circle()
                        .stroke(gradient, lineWidth: 3)
                        .frame(width: 180, height: 180)
                        .scaleEffect(animationManager.circleScale)
                )

            // Inner Content
            VStack(spacing: 8) {
                Text(animationManager.breathingPhase.rawValue)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                if animationManager.isActive {
                    Text("\(animationManager.phaseTimeRemaining)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.breathingCyan)
                }

                if animationManager.isActive {
                    Text(
                        "Cycle \(animationManager.cyclesCompleted + 1)/\(animationManager.totalCycles)"
                    )
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Breathing View
struct BreathingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var animManager = AnimationManager()
    @State private var selectedPreset: BreathingPreset?
    @State private var sessionComplete = false
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Animation Area
                    BreathingAnimationView(
                        animationManager: animManager, gradient: AppTheme.breathingGradient
                    )
                    .frame(height: 300)
                    .opacity(appeared ? 1 : 0)

                    if sessionComplete {
                        // Completion
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles").font(.system(size: 40)).foregroundStyle(
                                AppTheme.breathingGradient)
                            Text("Session Complete!").font(
                                .system(.title3, design: .rounded, weight: .bold)
                            ).foregroundStyle(AppTheme.textPrimary)
                            Text("+\(GameEngineManager.xpBreathingComplete) XP").font(
                                .system(.headline, design: .rounded)
                            ).foregroundStyle(AppTheme.warmOrange)
                            Text("You completed \(animManager.totalCycles) breathing cycles").font(
                                .system(.subheadline, design: .rounded)
                            ).foregroundStyle(AppTheme.textSecondary)

                            Button(action: { sessionComplete = false }) {
                                Text("Done").font(
                                    .system(.headline, design: .rounded, weight: .bold)
                                ).foregroundStyle(.white)
                                    .frame(maxWidth: .infinity).padding(14).background(
                                        AppTheme.breathingGradient
                                    ).clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(20).glassBackground()
                    } else if animManager.isActive {
                        // Active Controls
                        Button(action: { animManager.stop() }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop").font(
                                    .system(.headline, design: .rounded, weight: .bold))
                            }
                            .foregroundStyle(AppTheme.dangerRed).frame(maxWidth: .infinity).padding(
                                16
                            )
                            .background(AppTheme.dangerRed.opacity(0.15)).clipShape(
                                RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    } else {
                        // Presets
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose a Technique").font(
                                .system(.headline, design: .rounded, weight: .semibold)
                            ).foregroundStyle(AppTheme.textPrimary)

                            ForEach(BreathingPreset.presets) { preset in
                                Button(action: { startBreathing(preset) }) {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle().fill(AppTheme.breathingCyan.opacity(0.15))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: preset.icon).foregroundStyle(
                                                AppTheme.breathingGradient)
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(preset.name).font(
                                                .system(
                                                    .subheadline, design: .rounded,
                                                    weight: .semibold)
                                            ).foregroundStyle(AppTheme.textPrimary)
                                            Text(preset.description).font(
                                                .system(.caption2, design: .rounded)
                                            ).foregroundStyle(AppTheme.textSecondary).lineLimit(1)
                                        }
                                        Spacer()
                                        Text("\(preset.cycles) cycles").font(
                                            .system(.caption, design: .rounded)
                                        ).foregroundStyle(AppTheme.breathingCyan)
                                    }
                                    .padding(14).glassBackground()
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20).padding(.top, 10)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .navigationTitle("Breathing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.white.opacity(0.8))
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6)) { appeared = true }
                animManager.onSessionComplete = {
                    sessionComplete = true
                    GameEngineManager.shared.awardXP(
                        amount: GameEngineManager.xpBreathingComplete, source: "Breathing",
                        icon: "wind")
                    TaskCompletionManager.shared.completeExercise()

                    // Add accumulated exact minutes to WellnessDataStore
                    let totalSeconds =
                        selectedPreset != nil
                        ? Double(
                            selectedPreset!.cycles
                                * (selectedPreset!.inhale + selectedPreset!.holdIn
                                    + selectedPreset!.exhale + selectedPreset!.holdOut))
                        : Double(animManager.totalCycles * 15)

                    let exactMinutes = totalSeconds / 60.0
                    WellnessDataStore.shared.addBreathing(exactMinutes)
                }
            }
        }
    }

    private func startBreathing(_ preset: BreathingPreset) {
        selectedPreset = preset
        sessionComplete = false
        animManager.startBreathing(
            cycles: preset.cycles, inhale: preset.inhale, holdIn: preset.holdIn,
            exhale: preset.exhale, holdOut: preset.holdOut)
        HapticManager.impact(.medium)
    }
}
