//
//  Typography.swift
//  mothership
//
//  Typography system optimized for readability
//

import SwiftUI

enum AppTypography {
    // MARK: - Display Fonts (Large, High Contrast)
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    // MARK: - Body Fonts
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    
    // MARK: - Special Purpose Fonts
    static let button = Font.system(size: 17, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 14, weight: .semibold, design: .default)
    static let tabBar = Font.system(size: 10, weight: .medium, design: .default)
    
    // MARK: - Typography 
    // Greeting text (like "Good Morning, Afsar") - 30pt height, bold
    static let greeting = Font.system(size: 30, weight: .bold, design: .default)
    static let greetingSubtitle = Font.system(size: 22, weight: .regular, design: .default)
    
    // Card title (exact from design - 18pt semibold for "Basics", "Relaxation")
    static let cardTitle = Font.system(size: 18, weight: .semibold, design: .default)
    static let cardSubtitle = Font.system(size: 12, weight: .regular, design: .default)
    static let cardCategory = Font.system(size: 11, weight: .regular, design: .default)
    static let cardDuration = Font.system(size: 12, weight: .regular, design: .default)
    
    // Button text
    static let buttonTextSmall = Font.system(size: 12, weight: .medium, design: .default)
    
    // Section title
    static let sectionTitle = Font.system(size: 22, weight: .bold, design: .default)
}

// MARK: - Text Style Modifier

struct TextStyle: ViewModifier {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat?
    
    init(font: Font, color: Color = AppColors.primaryText, lineSpacing: CGFloat? = nil) {
        self.font = font
        self.color = color
        self.lineSpacing = lineSpacing
    }
    
    func body(content: Content) -> some View {
        if let lineSpacing = lineSpacing {
            content
                .font(font)
                .foregroundColor(color)
                .lineSpacing(lineSpacing)
        } else {
            content
                .font(font)
                .foregroundColor(color)
        }
    }
}

extension View {
    func textStyle(_ font: Font, color: Color = AppColors.primaryText, lineSpacing: CGFloat? = nil) -> some View {
        modifier(TextStyle(font: font, color: color, lineSpacing: lineSpacing))
    }
}
