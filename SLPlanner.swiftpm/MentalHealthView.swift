import SwiftUI

// MARK: - Mental Health View
struct MentalHealthView: View {
    @StateObject private var vm = MentalHealthViewModel()
    @State private var selectedMood: MoodType = .neutral
    @State private var stressLevel: Double = 5
    @State private var journalText: String = ""
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Insight Card
                HStack(spacing: 12) {
                    Text(vm.todayMood?.emoji ?? "🧠").font(.largeTitle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vm.todayMood?.rawValue ?? "Check In").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                        Text(vm.moodInsight).font(.system(.caption, design: .rounded)).foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding(16).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Mood Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("How are you feeling?").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(MoodType.allCases, id: \.self) { mood in
                            Button(action: { selectedMood = mood; HapticManager.selection() }) {
                                VStack(spacing: 6) {
                                    Text(mood.emoji).font(.title2)
                                    Text(mood.rawValue).font(.system(.caption2, design: .rounded, weight: .medium))
                                        .foregroundStyle(selectedMood == mood ? .white : AppTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(selectedMood == mood ? mood.color : mood.color.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Stress Slider
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Stress Level").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text("\(Int(stressLevel))/10").font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(stressLevel > 7 ? AppTheme.dangerRed : stressLevel > 4 ? AppTheme.warmOrange : AppTheme.healthGreen)
                    }
                    Slider(value: $stressLevel, in: 1...10, step: 1)
                        .tint(stressLevel > 7 ? AppTheme.dangerRed : stressLevel > 4 ? AppTheme.warmOrange : AppTheme.healthGreen)
                    HStack {
                        Text("😌 Low").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                        Spacer()
                        Text("High 😰").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                    }
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Journal
                VStack(alignment: .leading, spacing: 10) {
                    Text("Quick Journal").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                    ZStack(alignment: .topLeading) {
                        if journalText.isEmpty {
                            Text("What's on your mind...")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(AppTheme.textTertiary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                        }
                        TextEditor(text: $journalText)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 80, maxHeight: 120)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                    }
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20).glassBackground()
                .opacity(appeared ? 1 : 0)
                
                // Log Button
                Button(action: {
                    vm.logMood(mood: selectedMood, stress: Int(stressLevel), journal: journalText)
                    journalText = ""
                    HapticManager.notification(.success)
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Log Check-In").font(.system(.headline, design: .rounded, weight: .bold))
                    }
                    .foregroundStyle(.white).frame(maxWidth: .infinity).padding(16)
                    .background(AppTheme.mentalGradient).clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(ScaleButtonStyle())
                .opacity(appeared ? 1 : 0)
                
                // Recent Moods
                if !vm.recentLogs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Check-Ins").font(.system(.headline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                        ForEach(vm.recentLogs) { log in
                            HStack(spacing: 12) {
                                Text(log.mood.emoji).font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(log.mood.rawValue).font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                                    Text("Stress: \(log.stressLevel)/10").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                                }
                                Spacer()
                                Text(log.date.formattedDate).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
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
        .onAppear { withAnimation(.spring(response: 0.6)) { appeared = true } }
    }
}
