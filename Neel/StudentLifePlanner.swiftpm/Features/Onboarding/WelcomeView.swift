import SwiftUI

struct WelcomeView: View {
    @StateObject var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            AppBackground()
            
            Group {
                if viewModel.currentStep == 0 {
                    welcomeContent
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else if viewModel.currentStep == 1 {
                    AgeView(viewModel: viewModel)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    ClassView(viewModel: viewModel)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .animation(.easeInOut, value: viewModel.currentStep)
        }
    }
    
    private var welcomeContent: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "graduationcap.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.appPrimary)
            
            VStack(spacing: 10) {
                Text("Welcome to\nStudentLife Planner")
                    .font(.appTitle)
                    .multilineTextAlignment(.center)
                
                Text("Achieve academic excellence and maintain a healthy lifestyle with ease.")
                    .font(.appBody)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            PrimaryButton(title: "Get Started") {
                viewModel.nextStep()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
}
