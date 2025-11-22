//
//  Card.swift
//  mothership
//
//  Reusable card components
//

import SwiftUI

enum CardStyle {
    case featured
    case standard
    case compact
}

struct MaritimeCard<Content: View>: View {
    let style: CardStyle
    let backgroundColor: Color
    let textColor: Color
    let content: Content
    
    init(
        style: CardStyle = .standard,
        backgroundColor: Color = AppColors.cardBackground,
        textColor: Color = AppColors.primaryText,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(AppSpacing.cardCornerRadius)
            .shadow(
                color: Color.black.opacity(AppSpacing.cardShadowOpacity),
                radius: AppSpacing.cardShadowRadius,
                x: 0,
                y: 4
            )
    }
}

struct FeaturedCard<Content: View>: View {
    let backgroundColor: Color
    let textColor: Color
    let illustrationType: CardIllustration.IllustrationType?
    let content: Content
    
    init(
        backgroundColor: Color,
        textColor: Color? = nil,
        illustrationType: CardIllustration.IllustrationType? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        // Auto-determine text color if not provided
        self.textColor = textColor ?? (backgroundColor == AppColors.basicsCardColor ? .white : AppColors.textPrimary)
        self.illustrationType = illustrationType
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            backgroundColor
            
            // Illustration in top right corner
            if let illustrationType = illustrationType {
                VStack {
                    HStack {
                        Spacer()
                        CardIllustration(
                            type: illustrationType,
                            size: AppSpacing.featuredCardIllustrationSize
                        )
                        .offset(
                            x: AppSpacing.illustrationCornerOffsetX,
                            y: AppSpacing.illustrationCornerOffsetY
                        )
                    }
                    Spacer()
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                )
                .allowsHitTesting(false) // Don't interfere with card tap
            }
            
            // Content at bottom left
            VStack {
                Spacer()
                HStack {
                    content
                        .foregroundColor(textColor)
                    Spacer()
                }
            }
            .padding(AppSpacing.cardPadding)
        }
        .frame(height: AppSpacing.featuredCardHeight)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(
            color: Color.black.opacity(AppSpacing.cardShadowOpacity),
            radius: AppSpacing.cardShadowRadius,
            x: 0,
            y: 4
        )
    }
}

struct RecommendedCard<Content: View>: View {
    let backgroundColor: Color
    let textColor: Color
    let illustration: (() -> AnyView)?
    let content: Content
    
    init(
        backgroundColor: Color,
        textColor: Color? = nil,
        illustration: (() -> AnyView)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        // Auto-determine text color - light backgrounds use dark text
        self.textColor = textColor ?? AppColors.textPrimary
        self.illustration = illustration
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            backgroundColor
            
            if let illustration = illustration {
                VStack {
                    illustration()
                        .padding(.top, AppSpacing.md)
                    Spacer()
                }
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Spacer()
                content
                    .foregroundColor(textColor)
            }
            .padding(AppSpacing.cardPadding)
        }
        .frame(width: AppSpacing.recommendedCardWidth, height: AppSpacing.recommendedCardHeight)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(
            color: Color.black.opacity(AppSpacing.cardShadowOpacity),
            radius: AppSpacing.cardShadowRadius,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Daily Card Component (Horizontal, like "Daily Calm" in meditation app)

struct DailyCard: View {
    let title: String
    let subtitle: String?
    let backgroundColor: Color
    let textColor: Color
    let showPlayButton: Bool
    
    init(
        title: String,
        subtitle: String? = nil,
        backgroundColor: Color = AppColors.dailyThoughtBackground,
        textColor: Color = .white,
        showPlayButton: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.showPlayButton = showPlayButton
    }
    
    var body: some View {
        ZStack {
            backgroundColor
            
            // Optional abstract pattern overlay (subtle)
            // In production, this could be a pattern image
            
            // Content
            HStack(alignment: .center, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.cardTitle)
                        .foregroundColor(textColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AppTypography.caption)
                            .foregroundColor(textColor.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if showPlayButton {
                    // Play button (like meditation app)
                    Button(action: {}) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(textColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(AppSpacing.cardPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: AppSpacing.dailyCardHeight)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(
            color: Color.black.opacity(AppSpacing.cardShadowOpacity),
            radius: AppSpacing.cardShadowRadius,
            x: 0,
            y: 4
        )
    }
}

