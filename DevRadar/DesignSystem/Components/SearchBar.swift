import SwiftUI

struct SearchBar: View {
    @Environment(\.theme) private var theme
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.secondaryText)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(Typography.body())
                .foregroundStyle(theme.text)
                .responsiveText()
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.secondaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.md)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

