import SwiftUI

struct InfoCard<Content: View>: View {
    let title: String?
    let icon: String?
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    
    init(title: String? = nil, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if title != nil || icon != nil {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundColor(AppColors.secondary)
                    }
                    if let title = title {
                        Text(title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            
            content
        }
        .padding()
        .background(
            ZStack {
                BlurView(style: colorScheme == .dark ? .systemThinMaterialDark : .systemThinMaterialLight)
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primary, AppColors.secondary, AppColors.accent]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            }
        )
        .cornerRadius(20)
        .shadow(color: AppColors.primary.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 10, x: 0, y: 5)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
