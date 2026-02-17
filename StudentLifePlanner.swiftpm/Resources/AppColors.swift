import SwiftUI

struct AppColors {
    static let primary = Color(hex: "D946EF") // Magenta Pink
    static let secondary = Color(hex: "06B6D4") // Turquoise
    static let accent = Color(hex: "F59E0B") // Saffron Orange
    static let glass = Color.white.opacity(0.4)
    
    static let backgroundStart = Color(hex: "FFFBEB") // Soft Cream
    static let backgroundEnd = Color(hex: "FEF3C7") // Pale Saffron
    
    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [backgroundStart, backgroundEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
}
