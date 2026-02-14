import SwiftUI

struct GradientText: View {
    let text: String
    let gradient: LinearGradient
    var font: Font = .appTitle
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(gradient)
    }
}
