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
    
    @State private var isSigningIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var appleSignInProvider = AppleSignInProvider()
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            // App branding
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
            
            Spacer()
            
            // Sign in options
            VStack(spacing: AppSpacing.md) {
                // Apple Sign In Button
                Button(action: {
                    Task {
                        await performSignIn()
                    }
                }) {
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
                .disabled(isSigningIn)
                .padding(.horizontal, AppSpacing.screenPadding)
                
                // Guest mode option
                Button(action: {
                    // Guest mode - skip authentication
                    // For now, we'll still require sign in, but this can be enabled later
                }) {
                    Text(localization.localized(L10n.Auth.continueAsGuest))
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .disabled(true) // Disabled for now - require authentication
                .opacity(0.5)
                
                // Privacy policy link
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
        .appBackground()
        .overlay {
            if isSigningIn {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func performSignIn() async {
        isSigningIn = true
        defer { isSigningIn = false }
        
        do {
            // Use AuthService which handles the full flow
            try await userStore.signInWithApple()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    SignInView()
        .environment(\.userStore, UserStore())
        .environment(\.localization, LocalizationService())
}

