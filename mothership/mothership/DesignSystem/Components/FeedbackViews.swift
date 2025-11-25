//
//  FeedbackViews.swift
//  mothership
//
//  Centralized components for loading/error/user feedback states
//

import SwiftUI

// MARK: - Shared Types

struct FeedbackAction {
    let title: String
    let action: () -> Void
}

enum FeedbackSeverity {
    case info
    case warning
    case error
    
    var iconName: String {
        switch self {
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.octagon.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .info:
            return AppColors.lavenderBlue
        case .warning:
            return AppColors.warningOrange
        case .error:
            return AppColors.dangerRed
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .info:
            return AppColors.secondaryBackground
        case .warning:
            return AppColors.warningOrange.opacity(0.12)
        case .error:
            return AppColors.dangerRed.opacity(0.12)
        }
    }
    
    var borderColor: Color {
        accentColor.opacity(0.35)
    }
}

// MARK: - Loading State

struct LoadingStateView: View {
    var message: String?
    var showsBackground: Bool = false
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ProgressView()
                .tint(AppColors.lavenderBlue)
            if let message {
                Text(message)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(showsBackground ? AppColors.cardBackground : Color.clear)
        .cornerRadius(showsBackground ? AppSpacing.cardCornerRadiusSmall : 0)
    }
}

// MARK: - Banner

struct FeedbackBanner: View {
    let severity: FeedbackSeverity
    let messages: [String]
    var action: FeedbackAction?
    var showsIcon: Bool = true
    
    var body: some View {
        if messages.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    if showsIcon {
                        Image(systemName: severity.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(severity.accentColor)
                            .padding(.top, AppSpacing.xs)
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        ForEach(messages.indices, id: \.self) { index in
                            Text(messages[index])
                                .font(index == 0 ? AppTypography.body : AppTypography.caption)
                                .foregroundColor(index == 0 ? AppColors.textPrimary : AppColors.textSecondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    if let action {
                        Button(action: action.action) {
                            Text(action.title.uppercased())
                                .font(AppTypography.caption)
                                .foregroundColor(severity.accentColor)
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(severity.backgroundColor)
            .cornerRadius(AppSpacing.cardCornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadiusSmall)
                    .stroke(severity.borderColor, lineWidth: 1)
            )
        }
    }
}

// MARK: - Full-Screen Error State

struct ErrorStateView: View {
    let severity: FeedbackSeverity
    let title: String
    var message: String?
    var primaryAction: FeedbackAction?
    var secondaryAction: FeedbackAction?
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(systemName: severity.iconName)
                .font(.system(size: 64))
                .foregroundColor(severity.accentColor)
            
            Text(title)
                .font(AppTypography.title2)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            if let message {
                Text(message)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: AppSpacing.sm) {
                if let primaryAction {
                    Button(primaryAction.title.uppercased(), action: primaryAction.action)
                        .font(AppTypography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(severity.accentColor)
                        .cornerRadius(AppSpacing.buttonCornerRadius)
                }
                
                if let secondaryAction {
                    Button(secondaryAction.title.uppercased(), action: secondaryAction.action)
                        .font(AppTypography.button)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColors.secondaryBackground)
                        .cornerRadius(AppSpacing.buttonCornerRadius)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.bottom, AppSpacing.lg)
    }
}

#Preview("Feedback Banner") {
    VStack(spacing: AppSpacing.md) {
        FeedbackBanner(
            severity: .info,
            messages: ["All cards synced", "Updated 2 minutes ago"]
        )
        FeedbackBanner(
            severity: .warning,
            messages: ["Working from cache", "We'll refresh automatically when the network recovers"],
            action: FeedbackAction(title: "Reload") {}
        )
        FeedbackBanner(
            severity: .error,
            messages: ["Unable to load decks"],
            action: FeedbackAction(title: "Retry") {}
        )
    }
    .padding()
}
//
//  FeedbackViews.swift
//  mothership
//
//  Centralized components for loading/error/user feedback states
//

import SwiftUI

// MARK: - Shared Types

struct FeedbackAction {
    let title: String
    let action: () -> Void
}

enum FeedbackSeverity {
    case info
    case warning
    case error
    
    var iconName: String {
        switch self {
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.octagon.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .info:
            return AppColors.lavenderBlue
        case .warning:
            return AppColors.warningOrange
        case .error:
            return AppColors.dangerRed
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .info:
            return AppColors.secondaryBackground
        case .warning:
            return AppColors.warningOrange.opacity(0.12)
        case .error:
            return AppColors.dangerRed.opacity(0.12)
        }
    }
    
    var borderColor: Color {
        accentColor.opacity(0.4)
    }
}

// MARK: - Loading State

struct LoadingStateView: View {
    var message: String?
    var showsBackground: Bool = false
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ProgressView()
                .tint(AppColors.lavenderBlue)
            if let message {
                Text(message)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(showsBackground ? AppColors.cardBackground : Color.clear)
        .cornerRadius(showsBackground ? AppSpacing.cardCornerRadiusSmall : 0)
    }
}

// MARK: - Banner

struct FeedbackBanner: View {
    let severity: FeedbackSeverity
    let messages: [String]
    var action: FeedbackAction?
    var showsIcon: Bool = true
    
    var body: some View {
        if messages.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    if showsIcon {
                        Image(systemName: severity.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(severity.accentColor)
                            .padding(.top, AppSpacing.xs)
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        ForEach(messages.indices, id: \.self) { index in
                            Text(messages[index])
                                .font(index == 0 ? AppTypography.body : AppTypography.caption)
                                .foregroundColor(index == 0 ? AppColors.textPrimary : AppColors.textSecondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    if let action {
                        Button(action: action.action) {
                            Text(action.title.uppercased())
                                .font(AppTypography.caption)
                                .foregroundColor(severity.accentColor)
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(severity.backgroundColor)
            .cornerRadius(AppSpacing.cardCornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadiusSmall)
                    .stroke(severity.borderColor, lineWidth: 1)
            )
        }
    }
}

// MARK: - Full-Screen Error State

struct ErrorStateView: View {
    let severity: FeedbackSeverity
    let title: String
    var message: String?
    var primaryAction: FeedbackAction?
    var secondaryAction: FeedbackAction?
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(systemName: severity.iconName)
                .font(.system(size: 64))
                .foregroundColor(severity.accentColor)
            
            Text(title)
                .font(AppTypography.title2)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            if let message {
                Text(message)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: AppSpacing.sm) {
                if let primaryAction {
                    Button(primaryAction.title.uppercased(), action: primaryAction.action)
                        .font(AppTypography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(severity.accentColor)
                        .cornerRadius(AppSpacing.buttonCornerRadius)
                }
                
                if let secondaryAction {
                    Button(secondaryAction.title.uppercased(), action: secondaryAction.action)
                        .font(AppTypography.button)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColors.secondaryBackground)
                        .cornerRadius(AppSpacing.buttonCornerRadius)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.bottom, AppSpacing.lg)
    }
}

#Preview("Feedback Banner") {
    VStack(spacing: AppSpacing.md) {
        FeedbackBanner(
            severity: .info,
            messages: ["All cards synced", "Updated 2 minutes ago"]
        )
        FeedbackBanner(
            severity: .warning,
            messages: ["Working from cache", "We'll refresh automatically when the network recovers"],
            action: FeedbackAction(title: "Reload") {}
        )
        FeedbackBanner(
            severity: .error,
            messages: ["Unable to load decks"],
            action: FeedbackAction(title: "Retry") {}
        )
    }
    .padding()
}

