import Charts
import SwiftUI

// MARK: - Weekly Chart View
struct WeeklyChartView: View {
    let data: [ChartDataPoint]
    let goal: Double
    let accentColor: Color
    let gradient: LinearGradient
    let title: String
    let unit: String

    @State private var selectedPoint: ChartDataPoint?
    @State private var animateChart = false

    init(
        data: [ChartDataPoint],
        goal: Double,
        accentColor: Color = AppColors.runColor,
        gradient: LinearGradient = AppColors.runGradient,
        title: String = "Weekly Activity",
        unit: String = "KM"
    ) {
        self.data = data
        self.goal = goal
        self.accentColor = accentColor
        self.gradient = gradient
        self.title = title
        self.unit = unit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
                if let selected = selectedPoint {
                    Text("\(Int(selected.value)) \(unit)")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(accentColor)
                }
            }

            // Chart
            Chart {
                // Goal Rule Mark
                RuleMark(y: .value("Goal", goal))
                    .foregroundStyle(AppColors.tertiaryText)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Goal")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(AppColors.tertiaryText)
                    }

                ForEach(data) { point in
                    BarMark(
                        x: .value("Day", point.label),
                        y: .value("Value", animateChart ? point.value : 0)
                    )
                    .foregroundStyle(
                        point.value >= goal
                            ? AnyShapeStyle(gradient)
                            : AnyShapeStyle(accentColor.opacity(0.6))
                    )
                    .cornerRadius(6)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let intVal = value.as(Int.self) {
                            Text(intVal.formattedSteps)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(AppColors.tertiaryText)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                }
            }
            .frame(height: 200)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                    animateChart = true
                }
            }
        }
        .padding(20)
        .glassBackground()
    }
}
