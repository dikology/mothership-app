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
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

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
                                .foregroundColor(AppColors.lavenderBlue)
                            Text(location)
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    if let yachtName = charter.yachtName {
                        HStack {
                            Image(systemName: "sailboat.fill")
                                .foregroundColor(AppColors.lavenderBlue)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label(localization.localized(L10n.Common.edit), systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label(localization.localized(L10n.Common.delete), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(AppColors.lavenderBlue)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                CharterEditView(charter: charter)
            }
        }
        .alert(localization.localized(L10n.Charter.deleteCharter), isPresented: $showingDeleteAlert) {
            Button(localization.localized(L10n.Common.cancel), role: .cancel) { }
            Button(localization.localized(L10n.Common.delete), role: .destructive) {
                deleteCharter()
            }
        } message: {
            Text(localization.localized(L10n.Charter.deleteCharterConfirmation))
        }
    }
    
    private func deleteCharter() {
        charterStore.deleteCharter(charter)
        dismiss()
    }
}
