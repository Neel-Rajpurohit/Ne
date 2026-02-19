import SwiftUI

@MainActor
class IntroductionViewModel: ObservableObject {
    @Published var currentSlideIndex: Int = 0
    @Published var slideProgress: CGFloat = 0
    let totalSlides = 3
    private var timer: Timer?
    private let slideDuration: TimeInterval = 6.0
    
    func startAutoAdvance(onFinish: @escaping @Sendable () -> Void) {
        timer?.invalidate()
        slideProgress = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                withAnimation(.linear(duration: 0.05)) {
                    self.slideProgress += 0.05 / self.slideDuration
                }
                
                if self.slideProgress >= 1.0 {
                    if self.currentSlideIndex < self.totalSlides - 1 {
                        self.nextSlide()
                        self.slideProgress = 0
                    } else {
                        self.timer?.invalidate()
                        onFinish()
                    }
                }
            }
        }
    }
    
    func stopAutoAdvance() {
        timer?.invalidate()
    }
    
    func nextSlide() {
        if currentSlideIndex < totalSlides - 1 {
            withAnimation(.spring()) {
                currentSlideIndex += 1
                slideProgress = 0
            }
        }
    }
    
    func previousSlide() {
        if currentSlideIndex > 0 {
            withAnimation(.spring()) {
                currentSlideIndex -= 1
                slideProgress = 0
            }
        }
    }
}
