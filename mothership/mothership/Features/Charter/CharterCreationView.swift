//
//  CharterCreationView.swift
//  mothership
//
//  Charter creation form
//

import SwiftUI

struct CharterCreationView: View {
    //@Environment(\.charterStore) private var charterStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.localization) private var localization
    @Environment(\.charterStore) private var charterStore
    
    @State private var name: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var hasEndDate: Bool = false
    @State private var location: String = ""
    @State private var yachtName: String = ""
    @State private var charterCompany: String = ""
    @State private var notes: String = ""
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(localization.localized(L10n.Charter.createCharter))
                        .font(AppTypography.title1)
                        .foregroundColor(AppColors.textPrimary)
                    Text(localization.localized(L10n.Charter.createCharterDescription))
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.sm)
                
                // Form
                VStack(spacing: AppSpacing.xl) {
                    // Required Fields Section
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        
                        // Name
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text(localization.localized(L10n.Charter.charterName))
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)
                            TextField(localization.localized(L10n.Charter.charterNameExample), text: $name)
                                .textFieldStyle(MaritimeTextFieldStyle())
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                        
                        // Start Date (Required)
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text(localization.localized(L10n.Charter.startDate))
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)
                            DatePicker(
                                "",
                                selection: $startDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .environment(\.calendar, Calendar.current)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppSpacing.cardCornerRadiusSmall)
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                        
                        // End Date (Optional)
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Toggle(localization.localized(L10n.Charter.endDate), isOn: $hasEndDate)
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .onChange(of: hasEndDate) { oldValue, newValue in
                                    if newValue && endDate == nil {
                                        // Set default end date to 7 days after start date
                                        endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)
                                    }
                                }
                            
                            if hasEndDate {
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { endDate ?? Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? Date() },
                                        set: { endDate = $0 }
                                    ),
                                    in: startDate...,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .environment(\.calendar, Calendar.current)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(AppColors.cardBackground)
                                .cornerRadius(AppSpacing.cardCornerRadiusSmall)
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                    }
                    
                    // Optional Fields Section
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        
                        // Location
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text(localization.localized(L10n.Charter.location))
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)
                            TextField(localization.localized(L10n.Charter.locationExample), text: $location)
                                .textFieldStyle(MaritimeTextFieldStyle())
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                        
                        // Yacht Name
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text(localization.localized(L10n.Charter.yachtName))
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)
                            TextField(localization.localized(L10n.Charter.yachtNameExample), text: $yachtName)
                                .textFieldStyle(MaritimeTextFieldStyle())
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                        
                        // Charter Company
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text(localization.localized(L10n.Charter.charterCompany))
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)
                            TextField(localization.localized(L10n.Charter.charterCompanyExample), text: $charterCompany)
                                .textFieldStyle(MaritimeTextFieldStyle())
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                        
                        // Notes
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text(localization.localized(L10n.Charter.notes))
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)
                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textPrimary)
                                .scrollContentBackground(.hidden)
                                .padding(AppSpacing.md)
                                .background(AppColors.cardBackground)
                                .cornerRadius(AppSpacing.cardCornerRadiusSmall)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadiusSmall)
                                        .stroke(AppColors.lightGray, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                    }
                    
                    // Create Button
                    VStack(spacing: AppSpacing.md) {
                        PrimaryButton(
                            title: localization.localized(L10n.Charter.createCharter),
                            action: createCharter,
                            backgroundColor: AppColors.lavenderBlue
                        )
                        
                        SecondaryButton(
                            title: localization.localized(L10n.Common.cancel),
                            action: { dismiss() }
                        )
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .alert(localization.localized(L10n.Common.error), isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createCharter() {
        // Validation
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            // Generate a generic name like "Charter <today's date>"
            let todayString = Date().formattedMedium()
            name = "\(localization.localized(L10n.Charter.charter)) \(todayString)"
        }
        
        // Create charter
        let charter = Charter(
            name: name.trimmingCharacters(in: .whitespaces),
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            location: location.isEmpty ? nil : location.trimmingCharacters(in: .whitespaces),
            yachtName: yachtName.isEmpty ? nil : yachtName.trimmingCharacters(in: .whitespaces),
            charterCompany: charterCompany.isEmpty ? nil : charterCompany.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces)
        )
        
        charterStore.addCharter(charter)
        
        // Dismiss
        dismiss()
    }
}

// MARK: - Text Field Style

struct MaritimeTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(AppTypography.body)
            .foregroundColor(AppColors.textPrimary)
            .padding(AppSpacing.md)
            .background(AppColors.cardBackground)
            .cornerRadius(AppSpacing.cardCornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadiusSmall)
                    .stroke(AppColors.lightGray, lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        CharterCreationView()
    }
    .environment(\.localization, LocalizationService())
}
