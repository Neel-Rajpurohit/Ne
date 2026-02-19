import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme = .light
    
    enum Theme {
        case light
        case dark
    }
}
