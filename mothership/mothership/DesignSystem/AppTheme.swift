//
//  AppTheme.swift
//  Mothership
//
//  Global theme configuration and view modifiers
//

import SwiftUI

// MARK: - Theme Environment

@Observable
final class AppTheme {
    var colorScheme: ColorScheme = .light
    
    init() {}
    
    func toggleColorScheme() {
        colorScheme = colorScheme == .light ? .dark : .light
    }
}

// MARK: - Global View Modifiers

extension View {
    /// Applies the app's standard background color
    func appBackground() -> some View {
        self.background(AppColors.background)
    }
    
    /// Applies standard screen padding
    func screenPadding() -> some View {
        self.padding(.horizontal, AppSpacing.screenPadding)
    }
    
    /// Applies standard section spacing
    func sectionSpacing() -> some View {
        self.padding(.vertical, AppSpacing.sectionSpacing)
    }
}

