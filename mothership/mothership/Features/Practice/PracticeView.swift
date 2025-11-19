//
//  PracticeView.swift
//  mothership
//
//  Practice section 
//

import SwiftUI

struct PracticeView: View {
    @Environment(\.localization) private var localization

    @State private var selectedCategory: PracticeCategory = .all
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(localization.localized(L10n.Practice.practice))
                        .font(AppTypography.largeTitle)
                        .foregroundColor(AppColors.textPrimary)
                    Text(localization.localized(L10n.Practice.essentialChecklistsAndPracticalGuides))
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.md)
                
                // Category Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(PracticeCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.displayName(using: localization),
                                icon: category.icon,
                                isSelected: selectedCategory == category,
                                action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedCategory = category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
                .padding(.vertical, AppSpacing.sm)
                
                // Learning Modules Grid
                let columns = [
                    GridItem(.flexible(), spacing: AppSpacing.cardSpacing),
                    GridItem(.flexible(), spacing: AppSpacing.cardSpacing)
                ]
                
                LazyVGrid(columns: columns, spacing: AppSpacing.cardSpacing) {
                    ForEach(filteredModules) { module in
                        NavigationLink(value: AppPath.practiceModule(module.id.uuidString)) {
                            PracticeModuleCard(module: module)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.tabBarHeight)
            }
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var filteredModules: [PracticeModule] {
        let allModules = PracticeModule.defaultModules
        if selectedCategory == .all {
            return allModules
        }
        return allModules.filter { $0.category == selectedCategory }
    }
}

// MARK: - Learning Module Card

struct PracticeModuleCard: View {
    let module: PracticeModule
    
    var body: some View {
        GridCard(
            title: module.title,
            subtitle: module.subtitle,
            backgroundColor: backgroundColorForCategory(module.category),
            textColor: .white,
            illustrationType: illustrationTypeForCategory(module.category)
        )
    }
    
    private func backgroundColorForCategory(_ category: PracticeCategory) -> Color {
        switch category {
        case .all:
            return AppColors.basicsCardColor
        case .briefing:
            return AppColors.relaxationCardColor
        case .knots:
            return AppColors.recommendedCardRed 
        case .maneuvering:
            return AppColors.basicsCardColor
        case .mooring:
            return AppColors.recommendedCardGreen
        case .safety:
            return AppColors.recommendedCardRed
        }
    }
    
    private func illustrationTypeForCategory(_ category: PracticeCategory) -> CardIllustration.IllustrationType {
        switch category {
        case .all:
            return .basics
        case .briefing:
            return .focus
        case .knots:
            return .focus
        case .maneuvering:
            return .dailyThought
        case .mooring:
            return .basics
        case .safety:
            return .dailyThought
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(AppTypography.caption)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(isSelected ? AppColors.lavenderBlue : AppColors.cardBackground)
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .cornerRadius(AppSpacing.buttonCornerRadius)
        }
    }
}

// MARK: - Grid Card Component

struct GridCard: View {
    let title: String
    let subtitle: String?
    let backgroundColor: Color
    let textColor: Color
    let illustrationType: CardIllustration.IllustrationType?
    
    init(
        title: String,
        subtitle: String? = nil,
        backgroundColor: Color,
        textColor: Color = AppColors.textPrimary,
        illustrationType: CardIllustration.IllustrationType? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.illustrationType = illustrationType
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            // Illustration at the top
            if let illustrationType = illustrationType {
                CardIllustration(
                    type: illustrationType,
                    size: AppSpacing.featuredCardIllustrationSize
                )
                .allowsHitTesting(false)
            }
            
            // Text content at the bottom (title only for cleaner look)
            Text(title)
                .font(AppTypography.cardTitle)
                .foregroundColor(textColor)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppSpacing.cardPadding)
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(backgroundColor)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(
            color: Color.black.opacity(AppSpacing.cardShadowOpacity),
            radius: AppSpacing.cardShadowRadius,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Default Learning Modules

extension PracticeModule {
    static let defaultModules: [PracticeModule] = [
        PracticeModule(
            title: "Безопасность",
            subtitle: "Брифинг по безопасности на яхте",
            category: .briefing,
            type: .document,
            source: .remote
        ),
        PracticeModule(
            title: "Жизнь на яхте",
            subtitle: "Брифинг по жизни на яхте",
            category: .briefing,
            type: .document,
            source: .remote
        ),
        PracticeModule(
            title: "Аптечка",
            subtitle: "Аптечка",
            category: .safety,
            type: .document,
            source: .remote
        )
    ]
}

extension PracticeCategory {
    func displayName(using localization: LocalizationService) -> String {
        switch self {
        case .all: return localization.localized(L10n.Practice.all)
        case .briefing: return localization.localized(L10n.Practice.briefing)
        case .knots: return localization.localized(L10n.Practice.knots)
        case .maneuvering: return localization.localized(L10n.Practice.maneuvering)
        case .mooring: return localization.localized(L10n.Practice.mooring)
        case .safety: return localization.localized(L10n.Practice.safety)
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .briefing: return "shield"
        case .knots: return "figure.walk"
        case .maneuvering: return "arrow.triangle.2.circlepath"
        case .mooring: return "anchor"
        case .safety: return "shield"
        }
    }
}


#Preview {
    PracticeView()
}
