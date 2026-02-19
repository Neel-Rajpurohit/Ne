import SwiftUI

struct PointsDetailView: View {
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 20) {
                // Total Points Header
                InfoCard {
                    VStack(spacing: 10) {
                        Text("Total Points")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.points.balance)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Keep up the discipline!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                // History List
                VStack(alignment: .leading, spacing: 15) {
                    Text("Points History")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            if viewModel.points.history.isEmpty {
                                Text("No transactions yet")
                                    .foregroundColor(AppColors.textPrimary.opacity(0.6))
                                    .padding()
                            } else {
                                ForEach(viewModel.points.history.sorted(by: { $0.timestamp > $1.timestamp })) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle("Your Points")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TransactionRow: View {
    let transaction: Points.PointTransaction
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.reason)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Text(transaction.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary.opacity(0.5))
            }
            
            Spacer()
            
            Text(transaction.amount >= 0 ? "+\(transaction.amount)" : "\(transaction.amount)")
                .font(.headline)
                .foregroundColor(transaction.amount >= 0 ? .green : .red)
        }
        .padding()
        .background(
            ZStack {
                BlurView(style: colorScheme == .dark ? .systemThinMaterialDark : .systemThinMaterialLight)
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            }
        )
        .cornerRadius(16)
    }
}
