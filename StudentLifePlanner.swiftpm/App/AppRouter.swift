import SwiftUI

@MainActor
class AppRouter: ObservableObject {
    @Published var currentRoot: AppRoute = .introduction
    
    enum AppRoute {
        case introduction
        case onboarding
        case mainTab
    }
    
    func navigate(to route: AppRoute) {
        withAnimation(.spring()) {
            currentRoot = route
        }
    }
}
