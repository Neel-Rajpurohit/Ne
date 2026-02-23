import SwiftUI

// MARK: - Exercise Card Component
struct ExerciseCard: View {
    let exercise: ExerciseModel
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(exercise.category.color.opacity(0.15)).frame(width: 50, height: 50)
                Image(systemName: exercise.icon).font(.title3).foregroundStyle(exercise.category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                HStack(spacing: 8) {
                    Label("\(exercise.duration)s", systemImage: "clock").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                    Label("\(exercise.calories) cal", systemImage: "flame").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                    Text(exercise.muscleGroup).font(.system(.caption2, design: .rounded)).foregroundStyle(exercise.category.color.opacity(0.8))
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(0..<exercise.difficulty.dots, id: \.self) { _ in
                        Circle().fill(exercise.difficulty.color).frame(width: 6, height: 6)
                    }
                }
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(AppTheme.textTertiary)
            }
        }
        .padding(16).glassBackground()
    }
}

// MARK: - Yoga Card Component
struct YogaCard: View {
    let yoga: YogaModel
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(AppTheme.yogaTeal.opacity(0.15)).frame(width: 50, height: 50)
                Image(systemName: yoga.icon).font(.title3).foregroundStyle(AppTheme.yogaGradient)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(yoga.name).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                Text(yoga.sanskritName).font(.system(.caption2, design: .serif)).italic().foregroundStyle(AppTheme.yogaTeal.opacity(0.7))
                HStack(spacing: 8) {
                    Label("\(yoga.holdTime)s hold", systemImage: "timer").font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.textTertiary)
                    Text(yoga.benefits.prefix(2).joined(separator: " • ")).font(.system(.caption2, design: .rounded)).foregroundStyle(AppTheme.yogaTeal.opacity(0.8)).lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(0..<yoga.difficulty.dots, id: \.self) { _ in
                        Circle().fill(yoga.difficulty.color).frame(width: 6, height: 6)
                    }
                }
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(AppTheme.textTertiary)
            }
        }
        .padding(16).glassBackground()
    }
}
