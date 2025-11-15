//
//  Button.swift
//  mothership
//
//  Reusable button components 
//

import SwiftUI

// MARK: - Primary Button 

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var backgroundColor: Color = AppColors.basicsCardColor
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(AppTypography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppSpacing.buttonHeight)
                .background(isEnabled ? backgroundColor : AppColors.lightGray)
                .cornerRadius(AppSpacing.buttonCornerRadius)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Secondary Button (like "NO THANKS" in meditation app)

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var textColor: Color = AppColors.textPrimary
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(AppTypography.button)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: AppSpacing.buttonHeight)
        }
    }
}

// MARK: - Text Button (inline, not full width)

struct TextButton: View {
    let title: String
    let action: () -> Void
    var textColor: Color = AppColors.textPrimary
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.button)
                .foregroundColor(textColor)
        }
    }
}

// MARK: - Day Selector Button (like in meditation app)

struct DayButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(AppTypography.button)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .frame(width: 50, height: 50)
                .background(isSelected ? AppColors.textPrimary : AppColors.lightGray)
                .clipShape(Circle())
        }
    }
}

// MARK: - Day Selector Group

struct DaySelector: View {
    @Binding var selectedDays: Set<Int> // 0=Sunday, 1=Monday, etc.
    
    let days = ["SU", "M", "T", "W", "TH", "F", "S"]
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(0..<7) { index in
                DayButton(
                    day: days[index],
                    isSelected: selectedDays.contains(index),
                    action: {
                        if selectedDays.contains(index) {
                            selectedDays.remove(index)
                        } else {
                            selectedDays.insert(index)
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Previews

#Preview("Primary Button") {
    VStack(spacing: 20) {
        PrimaryButton(title: "Save", action: {})
            .padding()
        
        PrimaryButton(title: "Create Charter", action: {}, isEnabled: false)
            .padding()
    }
}

#Preview("Secondary Button") {
    VStack(spacing: 20) {
        SecondaryButton(title: "No Thanks", action: {})
            .padding()
    }
}

#Preview("Day Selector") {
    @Previewable @State var selectedDays: Set<Int> = [0, 1, 2, 3, 6]
    
    VStack(spacing: 20) {
        Text("Which day would you like to meditate?")
            .font(AppTypography.title2)
            .foregroundColor(AppColors.textPrimary)
        
        Text("Everyday is best, but we recommend picking at least five.")
            .font(AppTypography.subheadline)
            .foregroundColor(AppColors.textSecondary)
            .multilineTextAlignment(.center)
        
        DaySelector(selectedDays: $selectedDays)
            .padding()
    }
    .padding()
}

