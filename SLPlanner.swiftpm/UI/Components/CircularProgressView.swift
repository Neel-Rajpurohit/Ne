import SwiftUI

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let gradient: LinearGradient
    let icon: String?
    let label: String?
    let sublabel: String?

    @State private var animatedProgress: Double = 0

    init(
        progress: Double,
        lineWidth: CGFloat = 12,
        size: CGFloat = 120,
        gradient: LinearGradient = AppColors.runGradient,
        icon: String? = nil,
        label: String? = nil,
        sublabel: String? = nil
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.gradient = gradient
        self.icon = icon
        self.label = label
        self.sublabel = sublabel
    }

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: lineWidth
                )

            // Progress Arc
            Circle()
                .trim(from: 0, to: animatedProgress.clamped01)
                .stroke(
                    gradient,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: AppColors.runColor.opacity(0.4), radius: 6, x: 0, y: 0)

            // Center Content
            VStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size * 0.15))
                        .foregroundStyle(gradient)
                }
                if let label = label {
                    Text(label)
                        .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                }
                if let sublabel = sublabel {
                    Text(sublabel)
                        .font(.system(size: size * 0.1, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(
                .spring(
                    response: AppConstants.springResponse,
                    dampingFraction: AppConstants.springDamping
                ).delay(0.2)
            ) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _ in
            withAnimation(
                .spring(
                    response: AppConstants.springResponse,
                    dampingFraction: AppConstants.springDamping)
            ) {
                animatedProgress = progress
            }
        }
    }
}
