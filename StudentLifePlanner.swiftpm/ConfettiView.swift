import SwiftUI

// MARK: - Confetti Particle
struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var scale: CGFloat
    var color: Color
    var shape: ConfettiShape
    var speed: Double
    var wobble: Double
    
    enum ConfettiShape: CaseIterable {
        case circle, rectangle, triangle, star
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []
    @State private var animationTimer: Timer?
    
    private let colors: [Color] = [
        Color(hex: "F59E0B"), Color(hex: "EF4444"), Color(hex: "10B981"),
        Color(hex: "3B82F6"), Color(hex: "8B5CF6"), Color(hex: "EC4899"),
        Color(hex: "06B6D4"), Color(hex: "FFD200"), Color(hex: "FF6B6B")
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    confettiPiece(particle)
                }
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    spawnConfetti(in: geo.size)
                } else {
                    particles.removeAll()
                    animationTimer?.invalidate()
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
    
    private func confettiPiece(_ particle: ConfettiParticle) -> some View {
        Group {
            switch particle.shape {
            case .circle:
                Circle().fill(particle.color)
            case .rectangle:
                Rectangle().fill(particle.color)
            case .triangle:
                Triangle().fill(particle.color)
            case .star:
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(particle.color)
            }
        }
        .frame(width: 8 * particle.scale, height: 8 * particle.scale)
        .rotationEffect(.degrees(particle.rotation))
        .position(x: particle.x, y: particle.y)
    }
    
    private func spawnConfetti(in size: CGSize) {
        particles = (0..<60).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -50...(-10)),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.6...1.5),
                color: colors.randomElement()!,
                shape: ConfettiParticle.ConfettiShape.allCases.randomElement()!,
                speed: Double.random(in: 2...6),
                wobble: Double.random(in: -2...2)
            )
        }
        
        // Animate falling
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.linear(duration: 0.016)) {
                    for i in particles.indices {
                        particles[i].y += particles[i].speed
                        particles[i].x += particles[i].wobble
                        particles[i].rotation += Double.random(in: -5...5)
                        particles[i].wobble += Double.random(in: -0.3...0.3)
                    }
                }
                // Remove off-screen particles
                particles.removeAll { $0.y > UIScreen.main.bounds.height + 50 }
                if particles.isEmpty {
                    animationTimer?.invalidate()
                }
            }
        }
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

// MARK: - Task Completed Glow Modifier
struct TaskCompletedGlow: ViewModifier {
    let isCompleted: Bool
    let color: Color
    @State private var glowOpacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(color, lineWidth: isCompleted ? 2 : 0)
                    .opacity(glowOpacity)
            )
            .shadow(color: isCompleted ? color.opacity(0.4) : .clear, radius: isCompleted ? 8 : 0)
            .onChange(of: isCompleted) { completed in
                if completed {
                    withAnimation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true)) {
                        glowOpacity = 1.0
                    }
                    // Settle at a subtle glow
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            glowOpacity = 0.5
                        }
                    }
                } else {
                    glowOpacity = 0
                }
            }
    }
}

extension View {
    func taskCompletedGlow(isCompleted: Bool, color: Color = AppTheme.healthGreen) -> some View {
        modifier(TaskCompletedGlow(isCompleted: isCompleted, color: color))
    }
}

// MARK: - XP Badge View
struct XPBadgeView: View {
    let xp: Int
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundStyle(AppTheme.warmOrange)
            Text("+\(xp) XP")
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.warmOrange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppTheme.warmOrange.opacity(0.15))
        .clipShape(Capsule())
        .scaleEffect(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                appeared = true
            }
        }
    }
}

// MARK: - Streak Flame View
struct StreakFlameView: View {
    let streak: Int
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundStyle(
                    streak >= 7 ? Color(hex: "EF4444") :
                    streak >= 3 ? Color(hex: "F59E0B") :
                    Color(hex: "9CA3AF")
                )
            Text("\(streak)")
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}

// MARK: - Task Completion Toast
struct TaskCompletionToast: View {
    let task: DailyTask
    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(AppTheme.healthGreen)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Completed! +\(task.rewardXP) XP")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.warmOrange)
            }
            
            Spacer()
            
            Image(systemName: task.category.icon)
                .foregroundStyle(task.category.color)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AppTheme.healthGreen.opacity(0.3), radius: 10)
        .padding(.horizontal, 20)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = 0
                opacity = 1
            }
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = -100
                    opacity = 0
                }
            }
        }
    }
}
