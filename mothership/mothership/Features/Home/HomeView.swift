//
//  HomeView.swift
//  mothership
//
//  Home view
//

import SwiftUI
//import Tagged

struct HomeView: View {
    @Environment(\.localization) private var localization
    @Environment(\.charterStore) private var charterStore
    
    private var charterState: ViewState<[Charter]> {
        charterStore.charterState
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                // Header with personalized greeting
                headerSection
                
                if charterState.isLoading {
                    LoadingStateView(message: nil, showsBackground: true)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
                
                if let charterError = charterState.errorValue {
                    FeedbackBanner(
                        severity: .error,
                        messages: [charterError.localizedDescription(using: localization)],
                        action: FeedbackAction(
                            title: localization.localized(L10n.Error.retry),
                            action: retryCharterLoad
                        )
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                } else if charterState.isEmpty {
                    FeedbackBanner(
                        severity: .info,
                        messages: [localization.localized(L10n.Charter.createCharterDescription)]
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
                
                if let activeCharter = charterStore.activeCharter {
                    activeCharterCard(charter: activeCharter)
                } else {
                    createCharterCard
                }

                // Context-aware content based on charter state
                if charterStore.activeCharter != nil {
                    charterContextContent
                }
            }
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(greetingText)
                .font(AppTypography.greeting)
                .foregroundColor(AppColors.textPrimary)
            Text(localization.localized(L10n.Greeting.subtitle))
                .font(AppTypography.greetingSubtitle)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.lg)
    }

    private func activeCharterCard(charter: Charter) -> some View {
        NavigationLink(value: AppPath.charterDetail(charter.id)) {
            FeaturedCard(
                backgroundColor: AppColors.basicsCardColor,
                illustrationType: .basics
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(charter.name)
                        .font(AppTypography.cardTitle)
                    if let location = charter.location {
                        Text(location)
                            .font(AppTypography.caption)
                            .opacity(0.9)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    private var createCharterCard: some View {
        NavigationLink(value: AppPath.charterCreation) {
            FeaturedCard(
                backgroundColor: AppColors.basicsCardColor,
                illustrationType: .basics
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(localization.localized(L10n.Charter.createCharter))
                        .font(AppTypography.cardTitle)
                    Text(localization.localized(L10n.Charter.createCharterDescription))
                        .font(AppTypography.caption)
                        .opacity(0.9)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, AppSpacing.screenPadding)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return localization.localized(L10n.Greeting.morning)
        case 12..<17:
            return localization.localized(L10n.Greeting.day)
        case 17..<22:
            return localization.localized(L10n.Greeting.evening)
        default:
            return localization.localized(L10n.Greeting.night)
        }
    }
    
    // MARK: - Charter Context Content
    
    private var charterContextContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Section Header
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(localization.localized(L10n.Practice.briefing))
                    .font(AppTypography.sectionTitle)
                    .foregroundColor(AppColors.textPrimary)
                Text(localization.localized(L10n.Practice.essentialBriefingsForYourCharter))
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            
            // Briefing Modules - Daily checklist first (horizontal), then grid
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Daily Checklist Card (Horizontal, if it's a briefing module with checklist type)
                if let dailyModule = briefingModules.first(where: { $0.type == .checklist }) {
                    NavigationLink(value: AppPath.practiceModule(dailyModule.id.uuidString)) {
                        DailyCard(
                            title: dailyModule.title,
                            subtitle: dailyModule.subtitle,
                            backgroundColor: AppColors.dailyThoughtBackground,
                            textColor: .white,
                            showPlayButton: false
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
                
                // Other Briefing Modules Grid
                let gridModules = briefingModules.filter { $0.type != .checklist }
                if !gridModules.isEmpty {
                    let columns = [
                        GridItem(.flexible(), spacing: AppSpacing.cardSpacing),
                        GridItem(.flexible(), spacing: AppSpacing.cardSpacing)
                    ]
                    
                    LazyVGrid(columns: columns, spacing: AppSpacing.cardSpacing) {
                        ForEach(gridModules) { module in
                            NavigationLink(value: AppPath.practiceModule(module.id.uuidString)) {
                                PracticeModuleCard(module: module)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
        }
    }
    
    private var briefingModules: [PracticeModule] {
        PracticeModule.defaultModules.filter { $0.category == .briefing }
    }
    
    private func retryCharterLoad() {
        charterStore.reload()
    }
}

