//
//  Spacing.swift
//  mothership
//
//  Spacing and layout constants
//

import SwiftUI

enum AppSpacing {
    // MARK: - Base spacing unit (8pt grid system)
    static let base: CGFloat = 8
    
    // MARK: - Standard spacing values
    static let xs: CGFloat = 4      // 0.5x base
    static let sm: CGFloat = 8      // 1x base
    static let md: CGFloat = 16     // 2x base
    static let lg: CGFloat = 24     // 3x base
    static let xl: CGFloat = 32     // 4x base
    static let xxl: CGFloat = 40    // 5x base
    static let xxxl: CGFloat = 48   // 6x base
    
    // MARK: - Component-specific spacing (exact from meditation app design)
    static let cardPadding: CGFloat = 20
    static let cardSpacing: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let screenPadding: CGFloat = 20
    
    // MARK: - Button dimensions
    static let buttonPadding: CGFloat = 16
    static let buttonHeight: CGFloat = 50
    static let buttonHeightSmall: CGFloat = 35
    static let buttonWidthSmall: CGFloat = 70
    static let buttonCornerRadius: CGFloat = 25 // Pill-shaped
    
    // MARK: - Card dimensions
    static let featuredCardWidth: CGFloat = 177
    static let featuredCardHeight: CGFloat = 210
    static let recommendedCardWidth: CGFloat = 162
    static let recommendedCardHeight: CGFloat = 161
    static let dailyCardWidth: CGFloat = 374
    static let dailyCardHeight: CGFloat = 95
    
    // MARK: - Corner radius
    static let cardCornerRadius: CGFloat = 25 // Very rounded like meditation app
    static let cardCornerRadiusSmall: CGFloat = 12
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowOpacity: Double = 0.1
    
    // MARK: - Navigation
    static let tabBarHeight: CGFloat = 88
    static let navBarHeight: CGFloat = 44
    
    // MARK: - Illustration sizes (responsive, relative to card dimensions)
    static let featuredCardIllustrationSize: CGFloat = 100
    static let recommendedCardIllustrationSize: CGFloat = 80
    
    // MARK: - Illustration offsets (for corner positioning)
    static let illustrationCornerOffsetX: CGFloat = 0 // Horizontal offset
    static let illustrationCornerOffsetY: CGFloat = -4 // Vertical offset (extends into corner)
    
    // MARK: - Other component sizes
    static let playButtonSize: CGFloat = 40
    static let dotSize: CGFloat = 3
}
