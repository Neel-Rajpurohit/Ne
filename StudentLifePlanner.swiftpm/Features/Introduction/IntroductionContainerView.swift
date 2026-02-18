import SwiftUI

struct IntroductionContainerView: View {
    @StateObject private var viewModel = IntroductionViewModel()
    var onFinish: @Sendable () -> Void
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack {
                // Progress Bars (Slide Show Style)
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.totalSlides, id: \.self) { index in
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(AppColors.secondary.opacity(0.1))
                                
                                Capsule()
                                    .fill(AppColors.primary)
                                    .frame(width: index < viewModel.currentSlideIndex ? geometry.size.width : 
                                           (index == viewModel.currentSlideIndex ? geometry.size.width * viewModel.slideProgress : 0))
                            }
                        }
                        .frame(height: 4)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                TabView(selection: $viewModel.currentSlideIndex) {
                    IntroSlide1View().tag(0)
                    IntroSlide2View().tag(1)
                    IntroSlide3View().tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Button(action: {
                    if viewModel.currentSlideIndex == viewModel.totalSlides - 1 {
                        onFinish()
                    } else {
                        viewModel.nextSlide()
                    }
                }) {
                    Text(viewModel.currentSlideIndex == viewModel.totalSlides - 1 ? "Start Onboarding" : "Next")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
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
        .onAppear {
            viewModel.startAutoAdvance(onFinish: onFinish)
        }
        .onDisappear {
            viewModel.stopAutoAdvance()
        }
    }
}
