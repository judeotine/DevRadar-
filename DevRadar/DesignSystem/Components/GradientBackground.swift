import SwiftUI

struct GradientBackground: View {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color(hex: "0D1117"), // GitHub dark background
                        Color(hex: "161B22"), // Slightly lighter
                        Color(hex: "1C2128")  // Even lighter
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(hex: "E8F4F8"),
                        Color(hex: "F0E8F5"),
                        Color(hex: "FFE8E0")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            BackgroundIcons(colorScheme: colorScheme)
        }
        .ignoresSafeArea()
    }
}

private struct BackgroundIcons: View {
    let colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                IconView(
                    icon: "git.branch",
                    color: colorScheme == .dark ? Color(hex: "58A6FF") : Color(hex: "FF6B35"),
                    position: CGPoint(x: geometry.size.width * 0.15, y: geometry.size.height * 0.2)
                )
                
                IconView(
                    icon: "terminal.fill",
                    color: colorScheme == .dark ? Color(hex: "79C0FF") : Color(hex: "4A90E2"),
                    position: CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
                )
                
                IconView(
                    icon: "code",
                    color: colorScheme == .dark ? Color(hex: "A5D6FF") : Color(hex: "7B68EE"),
                    position: CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height * 0.4)
                )
                
                IconView(
                    icon: "server.rack",
                    color: colorScheme == .dark ? Color(hex: "7EE787") : Color(hex: "50C878"),
                    position: CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height * 0.35)
                )
                
                IconView(
                    icon: "cube.fill",
                    color: colorScheme == .dark ? Color(hex: "FFA657") : Color(hex: "FFD700"),
                    position: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.25)
                )
                
                IconView(
                    icon: "chart.bar.fill",
                    color: colorScheme == .dark ? Color(hex: "FF7B72") : Color(hex: "FF6B9D"),
                    position: CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.5)
                )
                
                IconView(
                    icon: "key.fill",
                    color: colorScheme == .dark ? Color(hex: "BC8CFF") : Color(hex: "9B59B6"),
                    position: CGPoint(x: geometry.size.width * 0.9, y: geometry.size.height * 0.45)
                )
            }
        }
    }
}

private struct IconView: View {
    let icon: String
    let color: Color
    let position: CGPoint
    @State private var rotation: Double = 0
    
    init(icon: String, color: Color, position: CGPoint) {
        self.icon = icon
        self.color = color
        self.position = position
        _rotation = State(initialValue: Double.random(in: -20...20))
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 60, height: 60)
                .blur(radius: 10)
            
            Image(systemName: icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(color.opacity(0.6))
        }
        .position(position)
        .rotationEffect(.degrees(rotation))
    }
}

