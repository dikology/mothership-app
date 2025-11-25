//
//  SignInView.swift
//  mothership
//
//  Sign in view with Apple Sign In
//

import SwiftUI

struct SignInView: View {
    @Environment(\.userStore) private var userStore
    @Environment(\.localization) private var localization
    
    private var authState: ViewState<User> {
        userStore.userState
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            branding
            Spacer()
            signInOptions
        }
        .appBackground()
        .overlay(alignment: .top) {
            if let error = authState.errorValue {
                FeedbackBanner(
                    severity: .error,
                    messages: [error.localizedDescription(using: localization)]
                )
                .padding()
            }
        }
        .overlay {
            if authState.isLoading {
                LoadingStateView(message: nil, showsBackground: true)
                    .padding()
            }
        }
    }
    
    private var branding: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "sailboat.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.basicsCardColor)
            
            Text("Mothership")
                .font(AppTypography.largeTitle)
                .foregroundColor(AppColors.textPrimary)
            
            Text(localization.localized(L10n.Auth.welcomeMessage))
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.screenPadding)
        }
    }
    
    private var signInOptions: some View {
        VStack(spacing: AppSpacing.md) {
            Button(action: triggerSignIn) {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.system(size: 18, weight: .medium))
                    Text(localization.localized(L10n.Auth.signInWithApple))
                        .font(AppTypography.button)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppSpacing.buttonHeight)
                .background(Color.black)
                .cornerRadius(AppSpacing.buttonCornerRadius)
            }
            .disabled(authState.isLoading)
            .padding(.horizontal, AppSpacing.screenPadding)
            
            Button(action: {}) {
                Text(localization.localized(L10n.Auth.continueAsGuest))
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            .disabled(true)
            .opacity(0.5)
            
            Link(
                destination: URL(string: "https://mothership.app/privacy") ?? URL(string: "https://example.com")!,
                label: {
                    Text(localization.localized(L10n.Auth.privacyPolicy))
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            )
        }
        .padding(.bottom, AppSpacing.xxxl)
    }
    
    private func triggerSignIn() {
        Task {
            do {
                try await userStore.signInWithApple()
            } catch {
                // State already updated via store
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(\.userStore, UserStore())
        .environment(\.localization, LocalizationService())
}
