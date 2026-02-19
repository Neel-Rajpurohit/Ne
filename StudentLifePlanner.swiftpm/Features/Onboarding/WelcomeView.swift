import SwiftUI

struct WelcomeView: View {
    @StateObject var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "sun.max.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(AppColors.accent)
                    .padding()
                    .background(
                        Circle()
                            .fill(AppColors.primary.opacity(0.1))
                            .overlay(Circle().stroke(AppColors.primary.opacity(0.3), lineWidth: 1))
                    )
                
                VStack(spacing: 8) {
                    Text("StudentLife")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.accent)
                    
                    Text("Planner")
                        .font(.system(size: 30, weight: .light, design: .rounded))
                        .foregroundColor(AppColors.secondary.opacity(0.8))
                }
                
                Text("Your smart academic and wellness companion. Let's get you set up.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.textPrimary.opacity(0.7))
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        viewModel.nextStep()
                    }
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.secondary.opacity(0.5), lineWidth: 0.5)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.currentStep != .welcome },
            set: { if !$0 { viewModel.currentStep = .welcome } }
        )) {
            OnboardingFlowView(viewModel: viewModel)
        }
    }
}

struct OnboardingFlowView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack {
                HStack {
                    Button(action: { /* Handle back or cancel */ }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Spacer()
                    Text("Step \(currentStepNumber) of 6")
                        .foregroundColor(AppColors.textPrimary.opacity(0.6))
                    Spacer()
                    Spacer().frame(width: 20)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        contentForStep
                    }
                    .padding()
                }
                
                Button(action: {
                    withAnimation {
                        viewModel.nextStep()
                    }
                }) {
                    Text(viewModel.currentStep == .completion ? "Finish" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.secondary.opacity(0.5), lineWidth: 0.5)
                        )
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    var contentForStep: some View {
        switch viewModel.currentStep {
        case .profile:
            VStack(alignment: .leading, spacing: 20) {
                Text("Tell us about yourself")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.textPrimary)
                
                InfoCard {
                    VStack(alignment: .leading, spacing: 15) {
                        TextField("Your Name", text: $viewModel.name)
                            .padding()
                            .background(Color.primary.opacity(0.05))
                            .cornerRadius(8)
                        
                        Text("What are you currently attending?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Education Type", selection: $viewModel.educationType) {
                            ForEach(UserProfile.EducationType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
        case .schoolTiming:
            EducationTypeView(viewModel: viewModel)
        case .tuitionTiming, .extraTiming, .mealTiming:
            TimetableInputView(viewModel: viewModel)
        case .completion:
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                
                Text("All Set!")
                    .font(.title.bold())
                    .foregroundColor(AppColors.textPrimary)
                
                Text("We've generated your smart plan based on your academic timings.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.textPrimary.opacity(0.8))
            }
            .padding(.top, 50)
        default:
            EmptyView()
        }
    }
    
    var currentStepNumber: Int {
        switch viewModel.currentStep {
        case .welcome: return 0
        case .profile: return 1
        case .schoolTiming: return 2
        case .tuitionTiming: return 3
        case .extraTiming: return 4
        case .mealTiming: return 5
        case .completion: return 6
        @unknown default: return 0
        }
    }
}
