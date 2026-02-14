import SwiftUI

struct YogaView: View {
    @StateObject var viewModel = HealthViewModel()
    @State private var selectedDifficulty: YogaDifficulty = .beginner
    
    var body: some View {
        ZStack {
            AppBackground(style: .health)
            
            VStack {
                // Difficulty selector
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(YogaDifficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.getYogaPosesByDifficulty(selectedDifficulty)) { pose in
                            YogaPoseCard(pose: pose)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Yoga Poses")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct YogaPoseCard: View {
    let pose: YogaPose
    @State private var isExpanded = false
    
    var body: some View {
        InfoCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: pose.iconName)
                        .font(.title)
                        .foregroundColor(.healthYoga)
                        .frame(width: 50, height: 50)
                        .background(Color.healthYoga.opacity(0.1))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pose.name)
                            .font(.appHeadline)
                            .foregroundColor(.appText)
                        
                        Text(pose.sanskritName)
                            .font(.appCaption)
                            .foregroundColor(.appTextSecondary)
                            .italic()
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.appTextSecondary)
                }
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
                
                if isExpanded {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label(pose.duration, systemImage: "clock")
                            .font(.appCaption)
                            .foregroundColor(.appPrimary)
                        
                        Label(pose.difficulty.rawValue, systemImage: "chart.bar.fill")
                            .font(.appCaption)
                            .foregroundColor(.healthYoga)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to do it:")
                            .font(.appCaption)
                            .foregroundColor(.appText)
                            .bold()
                        
                        Text(pose.description)
                            .font(.appBody)
                            .foregroundColor(.appTextSecondary)
                        
                        Text("Benefits:")
                            .font(.appCaption)
                            .foregroundColor(.appText)
                            .bold()
                            .padding(.top, 4)
                        
                        Text(pose.benefits)
                            .font(.appBody)
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        }
    }
}
