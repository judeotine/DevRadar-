import SwiftUI

struct LoadingView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .tint(theme.primary)

            Text("Loading...")
                .font(Typography.caption())
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }
}

struct SkeletonModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @State private var animationOffset: CGFloat = -200
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.2),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: animationOffset)
                .blur(radius: 20)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    animationOffset = 400
                }
            }
    }
}

extension View {
    func skeleton() -> some View {
        modifier(SkeletonModifier())
    }
}

struct SkeletonRectangle: View {
    @Environment(\.theme) private var theme
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat = CornerRadius.small) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(theme.tertiaryBackground)
            .frame(width: width, height: height)
            .skeleton()
    }
}

struct SkeletonCircle: View {
    @Environment(\.theme) private var theme
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(theme.tertiaryBackground)
            .frame(width: size, height: size)
            .skeleton()
    }
}

struct SkeletonCard: View {
    @Environment(\.theme) private var theme
    @State private var animationOffset: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: CornerRadius.small)
                .fill(theme.tertiaryBackground)
                .frame(width: 100, height: 12)

            RoundedRectangle(cornerRadius: CornerRadius.small)
                .fill(theme.tertiaryBackground)
                .frame(height: 20)

            RoundedRectangle(cornerRadius: CornerRadius.small)
                .fill(theme.tertiaryBackground)
                .frame(height: 16)

            HStack {
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .fill(theme.tertiaryBackground)
                    .frame(width: 60, height: 12)

                Spacer()

                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .fill(theme.tertiaryBackground)
                    .frame(width: 40, height: 12)
            }
        }
        .padding(Spacing.lg)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0),
                    Color.white.opacity(0.3),
                    Color.white.opacity(0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: animationOffset)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        )
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                animationOffset = 400
            }
        }
    }
}
