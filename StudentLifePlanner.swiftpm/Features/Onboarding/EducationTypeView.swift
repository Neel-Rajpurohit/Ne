import SwiftUI

struct EducationTypeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(viewModel.educationType.rawValue) Timings")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("When does your typically \(viewModel.educationType.rawValue.lowercased()) start and end?")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            InfoCard {
                VStack(spacing: 15) {
                    CustomTimePicker(title: "Start Time", selection: $viewModel.schoolStartTime)
                    Divider()
                    CustomTimePicker(title: "End Time", selection: $viewModel.schoolEndTime)
                }
            }
        }
    }
}
