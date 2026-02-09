import SwiftUI

struct AgeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 40) {
                VStack(spacing: 10) {
                    Text("How old are you?")
                        .font(.appTitle)
                    
                    Text("Select your age to personalize your routine.")
                        .font(.appBody)
                        .foregroundColor(.appTextSecondary)
                }
                
                Picker("Age", selection: $viewModel.age) {
                    ForEach(10...30, id: \.self) { age in
                        Text("\(age)").tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)
                .background(Color.appCardBackground)
                .cornerRadius(16)
                .padding(.horizontal, 30)
                
                Spacer()
                
                PrimaryButton(title: "Continue") {
                    viewModel.nextStep()
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
            .padding(.top, 50)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
