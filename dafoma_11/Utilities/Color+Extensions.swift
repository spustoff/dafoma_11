import SwiftUI

extension Color {
    // Additional color utilities for the app
    
    /// Returns a lighter version of the color
    func lighter(by percentage: Double = 0.2) -> Color {
        return self.opacity(1.0 - percentage)
    }
    
    /// Returns a darker version of the color
    func darker(by percentage: Double = 0.2) -> Color {
        return self.opacity(1.0 + percentage)
    }
    
    /// Creates a color with specified opacity
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
    
    // Main App Colors - Direct references to AppColors
    static var primaryYellow: Color {
        Color(hex: "fcc418")
    }
    
    static var primaryGreen: Color {
        Color(hex: "3cc45b")
    }
    
    static var nutriTrackBackground: Color {
        Color(hex: "3e4464")
    }
    
    // Dynamic colors that adapt to content
    static func adaptiveText(for background: Color) -> Color {
        // Simplified logic - in a real app you'd calculate luminance
        return Color.white
    }
    
    // Nutrition-specific colors
    static var caloriesColor: Color {
        Color(hex: "ff6b6b")
    }
    
    static var proteinColor: Color {
        Color(hex: "4ecdc4")
    }
    
    static var carbsColor: Color {
        Color(hex: "45b7d1")
    }
    
    static var fatColor: Color {
        Color(hex: "f9ca24")
    }
    
    static var fiberColor: Color {
        Color(hex: "6c5ce7")
    }
    
    // Workout-specific colors
    static var cardioColor: Color {
        Color(hex: "e17055")
    }
    
    static var strengthColor: Color {
        Color(hex: "00b894")
    }
    
    static var flexibilityColor: Color {
        Color(hex: "a29bfe")
    }
    
    static var restColor: Color {
        Color(hex: "636e72")
    }
    
    // Hex color initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Color scheme modifiers for Telegram-style design
extension View {
    func nutriTrackCard() -> some View {
        self
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.1), Color.white.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    func nutriTrackButton(style: NutriTrackButtonStyle = .primary) -> some View {
        self
            .foregroundColor(style.textColor)
            .background(style.backgroundColor)
            .cornerRadius(25)
            .shadow(color: style.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    func nutriTrackTextField() -> some View {
        self
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

enum NutriTrackButtonStyle {
    case primary
    case secondary
    case success
    case warning
    case danger
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color.primaryYellow
        case .secondary:
            return Color.primaryGreen
        case .success:
            return Color.primaryGreen
        case .warning:
            return Color(hex: "ff9500")
        case .danger:
            return Color(hex: "ff3b30")
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary, .warning:
            return Color.nutriTrackBackground
        case .secondary, .success, .danger:
            return Color.white
        }
    }
    
    var shadowColor: Color {
        return backgroundColor.opacity(0.3)
    }
} 