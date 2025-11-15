//
//  HomeView.swift
//  mothership
//
//  Home view
//

import SwiftUI
//import Tagged

struct HomeView: View {
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                // Header with personalized greeting
                headerSection
                
                // Content
                //contentSection
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
            Text("Хорошего настроения и погоды")
                .font(AppTypography.greetingSubtitle)
                .foregroundColor(AppColors.meditationTextSecondary)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.lg)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Доброе утро, Капитан"
        case 12..<17:
            return "Добрый день, Капитан"
        case 17..<22:
            return "Добрый вечер, Капитан"
        default:
            return "Доброй ночи, Капитан"
        }
    }
    
    
}

