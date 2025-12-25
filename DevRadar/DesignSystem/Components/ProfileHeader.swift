import SwiftUI

struct ProfileHeader: View {
    @Environment(\.theme) private var theme
    
    let user: User
    let contributionPercentage: Int
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .stroke(theme.primary.opacity(0.2), lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: CGFloat(contributionPercentage) / 100)
                    .stroke(theme.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                AsyncImage(url: URL(string: user.avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(theme.tertiaryBackground)
                }
                .frame(width: 74, height: 74)
                .clipShape(Circle())
            }
            .frame(minWidth: 80, maxWidth: 80)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(user.displayName)
                    .font(Typography.body())
                    .foregroundStyle(theme.text)
                    .responsiveText()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text("@\(user.login)")
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Button(action: {}) {
                    HStack(spacing: Spacing.xs) {
                        if let emoji = user.status?.emoji {
                            Text(emoji)
                                .font(.system(size: 10))
                        } else {
                            Image(systemName: "message.fill")
                                .font(.system(size: 10))
                        }
                        Text(user.status?.displayText ?? "Active")
                            .font(Typography.caption())
                            .responsiveText()
                            .lineLimit(1)
                    }
                    .foregroundStyle(theme.primary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(theme.primary.opacity(0.1))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
    }
}

