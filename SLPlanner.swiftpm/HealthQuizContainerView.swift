import SwiftUI

// MARK: - Health & Quiz Container View
struct HealthQuizContainerView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.mainGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segmented Picker at the top
                    segmentedPicker

                    TabView(selection: $selectedTab) {
                        // Slide 0: Health
                        HealthOverviewView()
                            .tag(0)

                        // Slide 1: Quiz & Games
                        QuizHomeView()
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: selectedTab)
                }
            }
            .navigationTitle(selectedTab == 0 ? "Health" : "Quiz & Games")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Segmented Picker
    private var segmentedPicker: some View {
        HStack(spacing: 4) {
            segmentButton(
                title: "Health", icon: "heart.fill", index: 0, color: AppTheme.healthGreen)
            segmentButton(
                title: "Quiz & Games", icon: "gamecontroller.fill", index: 1,
                color: AppTheme.quizPink)
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private func segmentButton(title: String, icon: String, index: Int, color: Color) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = index
            }
            HapticManager.selection()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(selectedTab == index ? .white : AppTheme.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if selectedTab == index {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(color.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: color.opacity(0.3), radius: 8, y: 2)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}
