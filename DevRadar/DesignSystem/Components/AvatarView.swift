import SwiftUI

struct AvatarView: View {
    @Environment(\.theme) private var theme

    let url: String?
    let size: CGFloat
    let fallbackInitials: String?

    init(url: String?, size: CGFloat = 40, fallbackInitials: String? = nil) {
        self.url = url
        self.size = size
        self.fallbackInitials = fallbackInitials
    }

    var body: some View {
        Group {
            if let urlString = url, let imageURL = URL(string: urlString) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Group {
            if let initials = fallbackInitials {
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(theme.text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.tertiaryBackground)
            } else {
                Circle()
                    .fill(theme.tertiaryBackground)
            }
        }
    }
}

