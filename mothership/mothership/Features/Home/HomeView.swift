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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                // Header with personalized greeting
                headerSection
                
                createCharterCard
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
                .foregroundColor(AppColors.meditationTextPrimary)
            Text(localization.localized(L10n.Greeting.subtitle))
                .font(AppTypography.greetingSubtitle)
                .foregroundColor(AppColors.meditationTextSecondary)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.lg)
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
    
    
}

