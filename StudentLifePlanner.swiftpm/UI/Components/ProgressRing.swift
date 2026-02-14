import SwiftUI
import Foundation

struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    var color: Color = .appPrimary
    var size: CGFloat = 150
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.2)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text(String(format: "%.0f%%", min(self.progress, 1.0) * 100.0))
                .font(.appTitle)
                .bold()
        }
        .frame(width: size, height: size)
    }
}
