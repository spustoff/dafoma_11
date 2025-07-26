import SwiftUI

struct AppColors {
    // Primary Brand Colors from the design spec
    static let background = Color(hex: "3e4464")
    static let primaryYellow = Color(hex: "fcc418")
    static let primaryGreen = Color(hex: "3cc45b")
    
    // Semantic Colors
    static let primary = primaryYellow
    static let secondary = primaryGreen
    static let accent = primaryGreen
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.8)
    static let textTertiary = Color.white.opacity(0.6)
    
    // Card and Surface Colors
    static let cardBackground = Color.white.opacity(0.1)
    static let surfaceElevated = Color.white.opacity(0.15)
    static let divider = Color.white.opacity(0.2)
    
    // Status Colors
    static let success = primaryGreen
    static let warning = Color(hex: "ff9500")
    static let error = Color(hex: "ff3b30")
    static let info = Color(hex: "007aff")
    
    // Gradient Colors
    static let primaryGradient = LinearGradient(
        colors: [primaryYellow, primaryGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [background, background.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient = LinearGradient(
        colors: [cardBackground, surfaceElevated],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

 