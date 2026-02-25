import SwiftUI

// MARK: - Step Progress Card
struct StepProgressCard: View {
    let steps: Int
    let goal: Int
    let distance: Double
    var onTap: (() -> Void)? = nil
    
    @State private var isPressed = false
    
    private var progress: Double {
        Double(steps) / Double(goal)
    }
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            onTap?()
        }) {
            HStack(spacing: 16) {
                // Progress Ring
                CircularProgressView(
                    progress: progress,
                    lineWidth: 10,
                    size: 90,
                    gradient: AppColors.stepsGradient,
                    icon: "figure.walk",
                    label: steps.formattedSteps,
                    sublabel: "steps"
                )
                
                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .font(.title3)
                            .foregroundStyle(AppColors.stepsGradient)
                        Text("Steps")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppColors.primaryText)
                    }
                    
                    Text("\(steps.withCommas) / \(goal.withCommas)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppColors.secondaryText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundStyle(AppColors.stepsColor.opacity(0.8))
                        Text(distance.asKilometers)
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    
                    // Progress percentage
                    Text(min(progress, 1.0).asPercent + " of goal")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(progress >= 1.0 ? AppColors.successColor : AppColors.stepsColor)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColors.tertiaryText)
            }
            .padding(20)
            .glassBackground()
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
