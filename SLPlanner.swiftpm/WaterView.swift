import SwiftUI

// MARK: - Water View
struct WaterView: View {
    @StateObject private var viewModel = WaterViewModel()
    @State private var showManualInput = false
    @State private var manualAmount: String = ""
    @State private var appeared = false
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - Water Level Visualization
                    waterLevelCard
                    
                    // MARK: - Quick Add Buttons
                    quickAddSection
                    
                    // MARK: - Insight
                    HStack(spacing: 12) {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(AppColors.waterGradient)
                        Text(viewModel.hydrationInsight)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(AppColors.primaryText)
                        Spacer()
                    }
                    .padding(16)
                    .glassBackground()
                    .opacity(appeared ? 1 : 0)
                    
                    // MARK: - Today's Log
                    todayLogSection
                    
                    // MARK: - Weekly Chart
                    WeeklyChartView(
                        data: viewModel.weeklyChartData,
                        goal: viewModel.waterGoal,
                        accentColor: AppColors.waterColor,
                        gradient: AppColors.waterGradient,
                        title: "Weekly Water",
                        unit: "ml"
                    )
                    .opacity(appeared ? 1 : 0)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Water")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        HapticManager.impact(.light)
                        showManualInput = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppColors.waterGradient)
                    }
                }
            }
            .alert("Add Water", isPresented: $showManualInput) {
                TextField("Amount in mL", text: $manualAmount)
                    .keyboardType(.numberPad)
                Button("Add") {
                    if let amount = Double(manualAmount), amount > 0 {
                        viewModel.addWater(amount)
                        HapticManager.notification(.success)
                    }
                    manualAmount = ""
                }
                Button("Cancel", role: .cancel) {
                    manualAmount = ""
                }
            } message: {
                Text("Enter the amount of water in milliliters")
            }
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
        }
    }
    
    // MARK: - Water Level Card
    private var waterLevelCard: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 200, height: 200)
                
                // Water fill
                Circle()
                    .fill(AppColors.waterColor.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .mask(
                        VStack {
                            Spacer(minLength: CGFloat(1.0 - viewModel.progress.clamped01) * 200)
                            Rectangle()
                        }
                        .frame(width: 200, height: 200)
                    )
                
                // Progress Ring
                CircularProgressView(
                    progress: viewModel.progress,
                    lineWidth: 14,
                    size: 200,
                    gradient: AppColors.waterGradient,
                    icon: "drop.fill",
                    label: viewModel.todayIntake.asLiters,
                    sublabel: "of \(viewModel.waterGoal.asLiters)"
                )
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.8)
            
            // Stats row
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(viewModel.todayIntake.asLiters)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(AppColors.waterColor)
                    Text("Consumed")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                Divider()
                    .frame(height: 30)
                    .overlay(AppColors.cardBorder)
                
                VStack(spacing: 4) {
                    Text(viewModel.remaining.asLiters)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(AppColors.primaryText)
                    Text("Remaining")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                Divider()
                    .frame(height: 30)
                    .overlay(AppColors.cardBorder)
                
                VStack(spacing: 4) {
                    Text(viewModel.progress.asPercent)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(viewModel.progress >= 1 ? AppColors.successColor : AppColors.waterColor)
                    Text("Progress")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .padding(.horizontal)
        }
        .padding(20)
        .glassBackground()
    }
    
    // MARK: - Quick Add Section
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)
            
            HStack(spacing: 12) {
                ForEach(AppConstants.waterIncrements, id: \.self) { amount in
                    Button(action: {
                        viewModel.addWater(amount)
                        HapticManager.impact(.medium)
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: amount <= 250 ? "drop.fill" : "drop.circle.fill")
                                .font(.title3)
                            Text("+\(Int(amount))ml")
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                        }
                        .foregroundStyle(AppColors.waterGradient)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.waterColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppColors.waterColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .padding(20)
        .glassBackground()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }
    
    // MARK: - Today's Log
    private var todayLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Log")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
                
                Spacer()
                
                if !viewModel.storage.todayWater.entries.isEmpty {
                    Button(action: {
                        viewModel.undoLast()
                        HapticManager.impact(.light)
                    }) {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(AppColors.waterColor)
                    }
                }
            }
            
            if viewModel.storage.todayWater.entries.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "drop.triangle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(AppColors.tertiaryText)
                        Text("No water logged yet")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppColors.tertiaryText)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(viewModel.storage.todayWater.entries.suffix(5).reversed()) { entry in
                    HStack {
                        Image(systemName: "drop.fill")
                            .font(.caption)
                            .foregroundStyle(AppColors.waterColor)
                        
                        Text("+\(Int(entry.amountML))ml")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(AppColors.primaryText)
                        
                        Spacer()
                        
                        Text(entry.timestamp, style: .time)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(20)
        .glassBackground()
        .opacity(appeared ? 1 : 0)
    }
}
