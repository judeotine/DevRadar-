import SwiftUI

struct InfoCard: View {
    @Environment(\.theme) private var theme
    
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(iconColor)
                
                Spacer()
            }
            
            Text(title)
                .font(Typography.caption())
                .foregroundStyle(theme.secondaryText)
                .responsiveText()
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Text(value)
                .font(Typography.headline())
                .foregroundStyle(theme.text)
                .responsiveText()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(Spacing.md)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
    }
}

