import Foundation

extension Double {
    /// Convert mL to Liters formatted string (e.g., "1.5L")
    var asLiters: String {
        let liters = self / 1000.0
        if liters >= 1.0 {
            return String(format: "%.1fL", liters)
        } else {
            return "\(Int(self))ml"
        }
    }
    
    /// Format as distance in km (e.g., "3.2 km")
    var asKilometers: String {
        String(format: "%.1f km", self)
    }
    
    /// Format as percentage (e.g., "75%")
    var asPercent: String {
        "\(Int(min(self * 100, 100)))%"
    }
    
    /// Clamped between 0 and 1
    var clamped01: Double {
        min(max(self, 0), 1)
    }
}

extension Int {
    /// Format step count (e.g., 8200 → "8.2K", 800 → "800")
    var formattedSteps: String {
        if self >= 1000 {
            let thousands = Double(self) / 1000.0
            return String(format: "%.1fK", thousands)
        }
        return "\(self)"
    }
    
    /// Format with comma separator (e.g., 8200 → "8,200")
    var withCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
