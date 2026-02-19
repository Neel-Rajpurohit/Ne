import SwiftUI

struct AppColors {
    static let primary = Color(hex: "D946EF") // Magenta Pink
    static let secondary = Color(hex: "06B6D4") // Turquoise
    static let accent = Color(hex: "F59E0B") // Saffron Orange
    static let emerald = Color(hex: "10B981") // Emerald Green
    
    static let backgroundStart = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor(hex: "FFFBEB")
    })
    static let backgroundEnd = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "020617") : UIColor(hex: "FEF3C7")
    })
    
    static let cardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.withAlphaComponent(0.4) : UIColor.white.withAlphaComponent(0.4)
    })
    
    static let textPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor(hex: "1E293B")
    })
    
    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [backgroundStart, backgroundEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
}
