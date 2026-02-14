import SwiftUI

struct ExerciseYogaView: View {
    let exercises = ExerciseProvider.getExercises()
    @State private var selectedCategory: ExerciseCategory = .yoga
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground()
                
                VStack {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(exercises.filter { $0.category == selectedCategory }) { exercise in
                                InfoCard {
                                    HStack(spacing: 15) {
                                        Image(systemName: exercise.iconName)
                                            .font(.title)
                                            .foregroundColor(.appSecondary)
                                            .frame(width: 50, height: 50)
                                            .background(Color.appSecondary.opacity(0.1))
                                            .cornerRadius(10)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(exercise.name)
                                                .font(.appHeadline)
                                            
                                            Text(exercise.duration)
                                                .font(.appCaption)
                                                .foregroundColor(.appSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "play.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.appSecondary)
                                    }
                                    
                                    Text(exercise.description)
                                        .font(.appBody)
                                        .foregroundColor(.appTextSecondary)
                                        .padding(.top, 5)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Exercise & Yoga")
        }
    }
}
