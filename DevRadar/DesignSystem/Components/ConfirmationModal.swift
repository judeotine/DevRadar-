import SwiftUI

struct ConfirmationModal: ViewModifier {
    @Environment(\.theme) private var theme
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmTitle: String
    let confirmAction: () -> Void
    let confirmRole: ButtonRole
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isPresented = false
                                }
                            }
                        
                        VStack(spacing: 0) {
                            VStack(spacing: Spacing.md) {
                                Text(title)
                                    .font(Typography.headline())
                                    .foregroundStyle(theme.text)
                                    .responsiveText()
                                
                                Text(message)
                                    .font(Typography.body())
                                    .foregroundStyle(theme.secondaryText)
                                    .responsiveText()
                                    .multilineTextAlignment(.center)
                            }
                            .padding(Spacing.xl)
                            
                            Divider()
                            
                            VStack(spacing: 0) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isPresented = false
                                        confirmAction()
                                    }
                                }) {
                                    Text(confirmTitle)
                                        .font(Typography.body())
                                        .foregroundStyle(confirmRole == .destructive ? theme.error : theme.primary)
                                        .responsiveText()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, Spacing.md)
                                }
                                .buttonStyle(.plain)
                                
                                Divider()
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isPresented = false
                                    }
                                }) {
                                    Text("Cancel")
                                        .font(Typography.body())
                                        .foregroundStyle(theme.primary)
                                        .responsiveText()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, Spacing.md)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .frame(maxWidth: 280)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                        .transition(.scale.combined(with: .opacity))
                    }
                    .zIndex(1000)
                }
            }
    }
}

extension View {
    func confirmationModal(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        confirmRole: ButtonRole = .destructive,
        confirmAction: @escaping () -> Void
    ) -> some View {
        modifier(ConfirmationModal(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            confirmAction: confirmAction,
            confirmRole: confirmRole
        ))
    }
}

