import SwiftUI

struct StatCard: View {
    @Environment(\.theme) private var theme

    let icon: String
    let label: String
    let value: String
    let trend: Trend?

    enum Trend {
        case up(String)
        case down(String)
        case neutral(String)

        var color: Color {
            switch self {
            case .up: return Color(hex: "3FB950")
            case .down: return Color(hex: "F85149")
            case .neutral: return .gray
            }
        }

        var text: String {
            switch self {
            case .up(let value), .down(let value), .neutral(let value):
                return value
            }
        }
    }

    init(icon: String, label: String, value: String, trend: Trend? = nil) {
        self.icon = icon
        self.label = label
        self.value = value
        self.trend = trend
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)

                Text(label)
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()

                Spacer()

                if let trend = trend {
                    Text(trend.text)
                        .font(Typography.caption())
                        .foregroundStyle(trend.color)
                        .responsiveText()
                }
            }

            Text(value)
                .font(Typography.title())
                .foregroundStyle(theme.text)
                .contentTransition(.numericText())
                .responsiveText()
        }
        .padding(Spacing.lg)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
    }
}
