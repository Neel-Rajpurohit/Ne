import SwiftUI

struct ClassView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 40) {
                VStack(spacing: 10) {
                    Text("What's your education level?")
                        .font(.appTitle)
                    
                    Text("This helps us structure your study sessions.")
                        .font(.appBody)
                        .foregroundColor(.appTextSecondary)
                }
                
                VStack(spacing: 15) {
                    ForEach(viewModel.educationLevels, id: \.self) { level in
                        Button(action: {
                            viewModel.educationLevel = level
                        }) {
                            HStack {
                                Text(level)
                                    .font(.appHeadline)
                                Spacer()
                                if viewModel.educationLevel == level {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.appPrimary)
                                }
                            }
                            .padding()
                            .background(Color.appCardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.educationLevel == level ? Color.appPrimary : Color.clear, lineWidth: 2)
                            )
                        }
                        .foregroundColor(.appText)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                PrimaryButton(title: "Complete Setup") {
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
