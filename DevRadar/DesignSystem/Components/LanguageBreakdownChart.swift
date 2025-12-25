import SwiftUI

struct LanguageBreakdownChart: View {
    @Environment(\.theme) private var theme

    let languages: [(language: Language, percentage: Double)]

    var body: some View {
        if languages.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("Languages")
                        .font(Typography.headline())
                        .foregroundStyle(theme.text)
                        .responsiveText()
                    
                    Spacer()
                    
                    Text("\(languages.count) \(languages.count == 1 ? "language" : "languages")")
                        .font(Typography.caption())
                        .foregroundStyle(theme.secondaryText)
                        .responsiveText()
                }
                
                VStack(spacing: Spacing.md) {
                    ForEach(Array(languages.enumerated()), id: \.offset) { index, item in
                        LanguageRow(
                            language: item.language,
                            percentage: item.percentage,
                            color: Color(hex: item.language.color ?? "#858585")
                        )
                    }
                }
                
                if languages.count > 1 {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Top Languages")
                            .font(Typography.caption())
                            .foregroundStyle(theme.secondaryText)
                            .responsiveText()
                        
                        FlowLayout(spacing: Spacing.sm) {
                            ForEach(Array(languages.prefix(8)), id: \.language.name) { item in
                                HStack(spacing: Spacing.xs) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(hex: item.language.color ?? "#858585"))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(item.language.name)
                                        .font(Typography.caption())
                                        .foregroundStyle(theme.text)
                                        .responsiveText()
                                    
                                    Text("\(Int(item.percentage))%")
                                        .font(Typography.caption())
                                        .foregroundStyle(theme.secondaryText)
                                        .responsiveText()
                                }
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(theme.tertiaryBackground)
                                .clipShape(Capsule())
                            }
                            
                            if languages.count > 8 {
                                Text("+\(languages.count - 8) more")
                                    .font(Typography.caption())
                                    .foregroundStyle(theme.tertiaryText)
                                    .responsiveText()
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(theme.tertiaryBackground)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct LanguageRow: View {
    @Environment(\.theme) private var theme
    let language: Language
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                HStack(spacing: Spacing.sm) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: 16, height: 16)
                    
                    Text(language.name)
                        .font(Typography.body())
                        .foregroundStyle(theme.text)
                        .responsiveText()
                }
                
                Spacer()
                
                Text("\(Int(percentage))%")
                    .font(Typography.body())
                    .foregroundStyle(theme.text)
                    .responsiveText()
                    .monospacedDigit()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.tertiaryBackground)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: percentage)
                }
            }
            .frame(height: 8)
        }
        .padding(Spacing.md)
        .background(theme.tertiaryBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
                maxX = max(maxX, currentX - spacing)
            }
            
            self.size = CGSize(width: maxX, height: currentY + lineHeight)
        }
    }
}

