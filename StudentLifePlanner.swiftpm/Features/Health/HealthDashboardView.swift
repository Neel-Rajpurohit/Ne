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
                    
                    // Recommendation card
                    if let recommended = viewModel.getRecommendedExercise() {
                        InfoCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Recommended for You")
                                        .font(.appCaption)
                                        .foregroundColor(.appTextSecondary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.appAccent)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Image(systemName: recommended.iconName)
                                        .font(.title)
                                        .foregroundColor(recommended.category.color)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(recommended.name)
                                            .font(.appHeadline)
                                            .foregroundColor(.appText)
                                        
                                        Text(recommended.duration)
                                            .font(.appCaption)
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
                            ForEach(viewModel.getFilteredExercises()) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseCard(exercise: exercise)
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
        InfoCard {
            HStack(spacing: 15) {
                Image(systemName: exercise.iconName)
                    .font(.title)
                    .foregroundColor(exercise.category.color)
                    .frame(width: 50, height: 50)
                    .background(exercise.category.color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.appHeadline)
                        .foregroundColor(.appText)
                    
                    Text(exercise.duration)
                        .font(.appCaption)
                        .foregroundColor(exercise.category.color)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
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
