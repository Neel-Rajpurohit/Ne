import SwiftUI

struct HealthDashboardView: View {
    @StateObject var viewModel = HealthViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground(style: .health)
                
                VStack {
                    // Category selector
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Recommendation card with glassmorphism
                    if let recommended = viewModel.getRecommendedExercise() {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(LinearGradient.accentGradient)
                                    
                                    Text("Recommended for You")
                                        .font(.appHeadline)
                                        .foregroundColor(.appText)
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [recommended.category.color.opacity(0.3), recommended.category.color.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: recommended.iconName)
                                            .font(.title)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [recommended.category.color, recommended.category.color.opacity(0.7)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(recommended.name)
                                            .font(.appHeadline)
                                            .foregroundColor(.appText)
                                        
                                        Text(recommended.duration)
                                            .font(.appBody)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Exercise list based on category
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.getFilteredExercises().enumerated()), id: \.element.id) { index, exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseCard(exercise: exercise)
                                        .staggeredAppearance(index: index, total: viewModel.getFilteredExercises().count)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Health & Wellness")
        }
    }
}

struct ExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [exercise.category.color.opacity(0.3), exercise.category.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: exercise.iconName)
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [exercise.category.color, exercise.category.color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise.name)
                        .font(.appHeadline)
                        .foregroundColor(.appText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(exercise.duration)
                            .font(.appBody)
                    }
                    .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .bounceEffect()
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        ZStack {
            AppBackground(style: .health)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Icon
                    HStack {
                        Spacer()
                        
                        Image(systemName: exercise.iconName)
                            .font(.system(size: 80))
                            .foregroundColor(exercise.category.color)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // Details
                    InfoCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.appHeadline)
                                .foregroundColor(.appText)
                            
                            Text(exercise.description)
                                .font(.appBody)
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    
                    InfoCard {
                        HStack {
                            Label(exercise.duration, systemImage: "clock")
                                .font(.appBody)
                                .foregroundColor(.appPrimary)
                            
                            Spacer()
                            
                            Label(exercise.category.rawValue, systemImage: "tag.fill")
                                .font(.appBody)
                                .foregroundColor(exercise.category.color)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
