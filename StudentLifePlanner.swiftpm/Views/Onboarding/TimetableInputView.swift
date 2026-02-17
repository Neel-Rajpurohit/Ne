import SwiftUI

struct TimetableInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        if viewModel.currentStep == .tuitionTiming {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tuition Timing")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Toggle("Do you attend tuition?", isOn: $viewModel.hasTuition)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                
                if viewModel.hasTuition {
                    InfoCard {
                        VStack(spacing: 15) {
                            CustomTimePicker(title: "Start Time", selection: $viewModel.tuitionStartTime)
                            Divider()
                            CustomTimePicker(title: "End Time", selection: $viewModel.tuitionEndTime)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        } else if viewModel.currentStep == .extraTiming {
            VStack(alignment: .leading, spacing: 20) {
                Text("Extra Classes")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Toggle("Do you have extra classes?", isOn: $viewModel.hasExtraClasses)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                
                if viewModel.hasExtraClasses {
                    InfoCard {
                        VStack(spacing: 15) {
                            CustomTimePicker(title: "Start Time", selection: $viewModel.extraStartTime)
                            Divider()
                            CustomTimePicker(title: "End Time", selection: $viewModel.extraEndTime)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        } else if viewModel.currentStep == .mealTiming {
            VStack(alignment: .leading, spacing: 20) {
                Text("Meal Timings")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                InfoCard {
                    VStack(spacing: 15) {
                        CustomTimePicker(title: "Breakfast", selection: $viewModel.breakfastTime)
                        Divider()
                        CustomTimePicker(title: "Lunch", selection: $viewModel.lunchTime)
                        Divider()
                        CustomTimePicker(title: "Dinner", selection: $viewModel.dinnerTime)
                    }
                }
            }
        }
    }
}
