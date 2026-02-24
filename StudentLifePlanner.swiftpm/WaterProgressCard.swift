import SwiftUI

// MARK: - Water Progress Card
struct WaterProgressCard: View {
    let currentML: Double
    let goalML: Double
    var onTap: (() -> Void)? = nil
    var onQuickAdd: (() -> Void)? = nil
    
    private var progress: Double {
        (currentML / goalML).clamped01
    }
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            onTap?()
        }) {
            HStack(spacing: 16) {
                // Water Progress Ring
                CircularProgressView(
                    progress: progress,
                    lineWidth: 10,
                    size: 90,
                    gradient: AppColors.waterGradient,
                    icon: "drop.fill",
                    label: currentML.asLiters,
                    sublabel: "water"
                )
                
                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "drop.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.waterGradient)
                        Text("Water")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(AppColors.primaryText)
                    }
                    
                    Text("\(currentML.asLiters) / \(goalML.asLiters)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppColors.secondaryText)
                    
                    Text(progress.asPercent + " of goal")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(progress >= 1.0 ? AppColors.successColor : AppColors.waterColor)
                }
                
                Spacer()
                
                // Quick Add Button
                VStack(spacing: 8) {
                    Button(action: {
                        HapticManager.impact(.medium)
                        onQuickAdd?()
                    }) {
                        VStack(spacing: 2) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("250ml")
                                .font(.system(.caption2, design: .rounded, weight: .semibold))
                        }
                        .foregroundStyle(AppColors.waterGradient)
                        .padding(8)
                        .background(AppColors.waterColor.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }
            .padding(20)
            .glassBackground()
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
