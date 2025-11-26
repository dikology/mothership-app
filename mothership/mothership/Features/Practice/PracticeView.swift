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
        let allModules = PracticeModule.defaultModules(using: localization)
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
            return .relaxation
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
        ZStack {
            backgroundColor
            
            // Illustration in top right corner (like meditation app)
            if let illustrationType = illustrationType {
                VStack {
                    HStack {
                        Spacer()
                        CardIllustration(
                            type: illustrationType,
                            size: AppSpacing.featuredCardIllustrationSize // Match meditation app grid card size
                        )
                        .foregroundColor(textColor.opacity(0.9))
                        .offset(x: AppSpacing.illustrationCornerOffsetX, y: AppSpacing.illustrationCornerOffsetY)
                    }
                    Spacer()
                }
                .allowsHitTesting(false)
            }
            
            // Text content at bottom left
            VStack {
                Spacer()
                HStack {
                    Text(title)
                        .font(AppTypography.cardTitle)
                        .foregroundColor(textColor)
                        .lineLimit(3) // Allow up to 3 lines for better fit
                        .minimumScaleFactor(0.8) // Scale down if needed
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
            }
            .padding(AppSpacing.cardPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180) // Increased from 140 to match meditation app grid cards
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
    static func defaultModules(using localization: LocalizationService) -> [PracticeModule] {
        [
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                title: localization.localized(L10n.Practice.Module.safetyBriefingTitle),
                subtitle: localization.localized(L10n.Practice.Module.safetyBriefingSubtitle),
                category: .briefing,
                type: .document,
                source: .remote
            ),
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                title: localization.localized(L10n.Practice.Module.lifeOnYachtTitle),
                subtitle: localization.localized(L10n.Practice.Module.lifeOnYachtSubtitle),
                category: .briefing,
                type: .document,
                source: .remote
            ),
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                title: localization.localized(L10n.Practice.Module.firstAidKitTitle),
                subtitle: localization.localized(L10n.Practice.Module.firstAidKitSubtitle),
                category: .safety,
                type: .document,
                source: .remote
            ),
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                title: localization.localized(L10n.Practice.Module.goingAshoreTitle),
                subtitle: localization.localized(L10n.Practice.Module.goingAshoreSubtitle),
                category: .safety,
                type: .document,
                source: .remote
            ),
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                title: localization.localized(L10n.Practice.Module.mooringAndDepartureTitle),
                subtitle: localization.localized(L10n.Practice.Module.mooringAndDepartureSubtitle),
                category: .safety,
                type: .document,
                source: .remote
            ),
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
                title: localization.localized(L10n.Practice.Module.roundTurnTitle),
                subtitle: localization.localized(L10n.Practice.Module.roundTurnSubtitle),
                category: .knots,
                type: .document,
                source: .remote
            ),
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
                title: localization.localized(L10n.Practice.Module.preDepartureTitle),
                subtitle: localization.localized(L10n.Practice.Module.preDepartureSubtitle),
                category: .briefing,
                type: .checklist,
                source: .remote
            ),
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
                title: localization.localized(L10n.Practice.Module.departureFromPierTitle),
                subtitle: localization.localized(L10n.Practice.Module.departureFromPierSubtitle),
                category: .mooring,
                type: .document,
                source: .remote
            ),
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!,
                title: localization.localized(L10n.Practice.Module.mediterraneanMooringTitle),
                subtitle: localization.localized(L10n.Practice.Module.mediterraneanMooringSubtitle),
                category: .mooring,
                type: .document,
                source: .remote
            ),
            PracticeModule(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
                title: localization.localized(L10n.Practice.Module.anchoringTitle),
                subtitle: localization.localized(L10n.Practice.Module.anchoringSubtitle),
                category: .mooring,
                type: .document,
                source: .remote
            )
        ]
    }
}

#Preview {
    PracticeView()
}
