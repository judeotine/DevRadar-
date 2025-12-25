import SwiftUI

protocol Theme {
    var primary: Color { get }
    var secondary: Color { get }
    var tertiary: Color { get }
    var background: Color { get }
    var secondaryBackground: Color { get }
    var tertiaryBackground: Color { get }
    var success: Color { get }
    var warning: Color { get }
    var error: Color { get }
    var text: Color { get }
    var secondaryText: Color { get }
    var tertiaryText: Color { get }
    var border: Color { get }
    var separator: Color { get }
}

struct LightTheme: Theme {
    let primary = Color(hex: "0969DA")
    let secondary = Color(hex: "6E7781")
    let tertiary = Color(hex: "8C959F")
    let background = Color(hex: "FFFFFF")
    let secondaryBackground = Color(hex: "F6F8FA")
    let tertiaryBackground = Color(hex: "EFF2F5")
    let success = Color(hex: "1A7F37")
    let warning = Color(hex: "9A6700")
    let error = Color(hex: "CF222E")
    let text = Color(hex: "1F2328")
    let secondaryText = Color(hex: "656D76")
    let tertiaryText = Color(hex: "8C959F")
    let border = Color(hex: "D1D9E0")
    let separator = Color(hex: "E8EAED")
}

struct DarkTheme: Theme {
    let primary = Color(hex: "4493F8")
    let secondary = Color(hex: "8D96A0")
    let tertiary = Color(hex: "6E7681")
    let background = Color(hex: "0D1117")
    let secondaryBackground = Color(hex: "161B22")
    let tertiaryBackground = Color(hex: "1C2128")
    let success = Color(hex: "3FB950")
    let warning = Color(hex: "D29922")
    let error = Color(hex: "F85149")
    let text = Color(hex: "E6EDF3")
    let secondaryText = Color(hex: "8D96A0")
    let tertiaryText = Color(hex: "6E7681")
    let border = Color(hex: "30363D")
    let separator = Color(hex: "21262D")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255
        )
    }
}

struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Theme = LightTheme()
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

enum CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xlarge: CGFloat = 16
}

enum Typography {
    static func display() -> Font {
        .system(size: 34, weight: .bold, design: .default)
    }

    static func title() -> Font {
        .system(size: 28, weight: .semibold, design: .default)
    }

    static func headline() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    static func body() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }

    static func caption() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }

    static func code() -> Font {
        .system(size: 14, weight: .regular, design: .monospaced)
    }
}

