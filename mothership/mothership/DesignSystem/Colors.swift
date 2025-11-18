//
//  Colors.swift
//  mothership
//
//  Comprehensive design system colors
//

import SwiftUI

enum AppColors {
    // MARK: - Background Colors
    // Using direct color values (assets can be added later if needed)
    static var background: Color {
        backgroundFallback
    }
    
    static var secondaryBackground: Color {
        secondaryBackgroundFallback
    }
    
    static var cardBackground: Color {
        cardBackgroundFallback
    }
    
    // MARK: - Text Colors (High Contrast)
    static var primaryText: Color {
        primaryTextFallback
    }
    
    static var secondaryText: Color {
        secondaryTextFallback
    }
    
    static var accentText: Color {
        accentTextFallback
    }
    
    // MARK: - Direct Color Values (Adaptive for Dark Mode)
    static var backgroundFallback: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Dark: #1C1C1E
                : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0) // Light
        })
    }
    
    static var secondaryBackgroundFallback: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0) // Dark: #2C2C2E
                : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0) // Light
        })
    }
    
    static var cardBackgroundFallback: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0) // Dark: #2C2C2E
                : UIColor.white // Light
        })
    }
    
    static var primaryTextFallback: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 1.0) // Dark: #EBEBF5
                : UIColor(red: 0.25, green: 0.25, blue: 0.31, alpha: 1.0) // Light: #3F414E
        })
    }
    
    static var secondaryTextFallback: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1.0) // Dark: #8C8C93
                : UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0) // Light
        })
    }
    
    static var accentTextFallback: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0) // Dark: lighter blue
                : UIColor(red: 0.0, green: 0.4, blue: 0.6, alpha: 1.0) // Light
        })
    }
    
    // MARK: - Text Colors (Adaptive for Dark Mode)
    static var textPrimary: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 1.0) // Dark: #EBEBF5
                : UIColor(red: 0.25, green: 0.25, blue: 0.31, alpha: 1.0) // Light: #3F414E
        })
    }
    
    static var textSecondary: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1.0) // Dark: #8C8C93
                : UIColor(red: 0.63, green: 0.64, blue: 0.70, alpha: 1.0) // Light: #A1A4B2
        })
    }
    
    // MARK: - Primary Maritime Colors
    static let lavenderBlue = Color(hex: "8E97FD")
    static let deepBlue = Color(red: 0.0, green: 0.2, blue: 0.4)
    static let skyBlue = Color(red: 0.5, green: 0.7, blue: 0.9)
    static let sailWhite = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    // MARK: - Accent Colors
    static let anchorGold = Color(red: 0.85, green: 0.65, blue: 0.13)
    static let warningOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let dangerRed = Color(red: 0.8, green: 0.2, blue: 0.2)
    static let successGreen = Color(red: 0.2, green: 0.7, blue: 0.3)
    
    // MARK: - Neutral Colors (Adaptive for Dark Mode)
    static let charcoal = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let slateGray = Color(red: 0.4, green: 0.4, blue: 0.45)
    
    static var lightGray: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.23, green: 0.23, blue: 0.25, alpha: 1.0) // Dark: #3A3A3F
                : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // Light
        })
    }
    
    // MARK: - Tab Bar Colors (Adaptive for Dark Mode)
    static let tabBarSelected = Color(hex: "8E97FD")
    static let tabBarUnselected = Color(red: 0.6, green: 0.6, blue: 0.65) // Gray
    
    static var tabBarBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Dark: #1C1C1E
                : UIColor.white // Light
        })
    }
    
    // MARK: - Featured Card Colors
    static let basicsCardColor = Color(hex: "8E97FD") // Lavender-blue from Figma
    
    // Light orange for "Relaxation" style cards
    static let relaxationCardColor = Color(hex: "F4A17C") // Light orange/peach
    
    // MARK: - Daily Thought Card
    static let dailyThoughtBackground = Color(hex: "333242") // Dark gray
    
    // MARK: - Recommended Card Colors
    static let recommendedCardGreen = Color(hex: "85D485") // Light green
    static let recommendedCardOrange = Color(hex: "76C79E") // Light orange
    static let recommendedCardRed = Color(hex: "F05D48") // Light red
    
    // MARK: - Gradient Colors
    static let featuredCardGradientStart = Color(red: 0.58, green: 0.45, blue: 0.85) // #9486D9
    static let featuredCardGradientEnd = Color(red: 0.45, green: 0.35, blue: 0.75) // #7359BF
    static let relaxationCardGradientStart = Color(red: 1.0, green: 0.75, blue: 0.55) // #FFBF8C
    static let relaxationCardGradientEnd = Color(red: 0.95, green: 0.65, blue: 0.4) // #F2A666
    static let oceanGradientStart = Color(red: 0.2, green: 0.5, blue: 0.8)
    static let oceanGradientEnd = Color(red: 0.1, green: 0.3, blue: 0.6)
    static let skyGradientStart = Color(red: 0.65, green: 0.8, blue: 0.95)
    static let skyGradientEnd = Color(red: 0.45, green: 0.65, blue: 0.85)
    
    // MARK: - Button Colors
    static let buttonBackgroundLight = Color(red: 0.92, green: 0.92, blue: 0.93) // #EBEAEC
    static let buttonTextDark = Color(red: 0.25, green: 0.25, blue: 0.31) // #3F414E
    
    // MARK: - Overlay Colors
    static let overlayDark = Color.black.opacity(0.3)
    static let overlayLight = Color.white.opacity(0.1)
}

// MARK: - Color Extensions

extension Color {
    /// Initialize a Color from a hex string (e.g., "8E97FD" or "#8E97FD")
    /// - Parameter hex: Hex color string with or without the # prefix
    /// - Parameter opacity: Optional opacity (0.0 to 1.0), defaults to 1.0
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: opacity
        )
    }
    
}

// MARK: - Gradient Extensions

extension LinearGradient {
    // Featured card gradient (purple/blue - like "Basics" card)
    static var featuredCardGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.featuredCardGradientStart, AppColors.featuredCardGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Relaxation card gradient (orange - like "Relaxation" card)
    static var relaxationCardGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.relaxationCardGradientStart, AppColors.relaxationCardGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Ocean gradient (maritime theme)
    static var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.oceanGradientStart, AppColors.oceanGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Sky gradient
    static var skyGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.skyGradientStart, AppColors.skyGradientEnd],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
