import SwiftUI

struct PromotionalCard: View {
    @Environment(\.theme) private var theme
    
    let icon: String
    let title: String
    let description: String
    let footnote: String
    let buttonText: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(Typography.headline())
                    .foregroundStyle(.white)
                    .responsiveText()
            }
            
            Text(description)
                .font(Typography.body())
                .foregroundStyle(.white.opacity(0.9))
                .responsiveText()
                .fixedSize(horizontal: false, vertical: true)
            
            Text(footnote)
                .font(Typography.caption())
                .foregroundStyle(.white.opacity(0.7))
                .responsiveText()
            
            Button(action: action) {
                Text(buttonText)
                    .font(Typography.body())
                    .foregroundStyle(theme.primary)
                    .responsiveText()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, Spacing.sm)
        }
        .padding(Spacing.xl)
        .background(
            LinearGradient(
                colors: [theme.primary, theme.primary.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

