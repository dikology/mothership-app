//
//  CharterDetailView.swift
//  mothership
//
//  Charter detail view with check-in checklist access
//

import SwiftUI

struct CharterDetailView: View {
    let charter: Charter
    
    @Environment(\.charterStore) private var charterStore
    @Environment(\.localization) private var localization

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(charter.name)
                        .font(AppTypography.largeTitle)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let location = charter.location {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(AppColors.oceanBlue)
                            Text(location)
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    if let yachtName = charter.yachtName {
                        HStack {
                            Image(systemName: "sailboat.fill")
                                .foregroundColor(AppColors.oceanBlue)
                            Text(yachtName)
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.md)
                
                // Charter Info
                if charter.notes != nil || charter.charterCompany != nil {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text(localization.localized(L10n.Charter.information))
                            .font(AppTypography.sectionTitle)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal, AppSpacing.screenPadding)
                        
                        if let charterCompany = charter.charterCompany {
                            MaritimeCard {
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    Text(localization.localized(L10n.Charter.charterCompany))
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                    Text(charterCompany)
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenPadding)
                        }
                        
                        if let notes = charter.notes, !notes.isEmpty {
                            MaritimeCard {
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    Text(localization.localized(L10n.Charter.notes))
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                    Text(notes)
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenPadding)
                        }
                    }
                }
            }
            .padding(.bottom, AppSpacing.xl)
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
}
