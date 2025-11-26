//
//  ProfileView.swift
//  mothership
//
//  User profile view with type, communities, and settings
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.userStore) private var userStore
    @Environment(\.localization) private var localization
    
    @State private var showEditProfile = false
    @State private var showUserTypePicker = false
    @State private var showDeleteAccountAlert = false
    
    private var user: User? {
        userStore.currentUser
    }
    
    private var userState: ViewState<User> {
        userStore.userState
    }
    
    var body: some View {
        Group {
            switch userState {
            case .loading, .idle:
                LoadingStateView(message: nil, showsBackground: true)
                    .padding(AppSpacing.screenPadding)
            case .empty, .error:
                SignInView()
            case .loaded:
                profileContent
            }
        }
    }
    
    @ViewBuilder
    private var profileContent: some View {
        NavigationStack {
            List {
                if let user {
                    Section {
                        profileHeader(for: user)
                    }
                    
                    userTypeSection(for: user)
                    communitiesSection(for: user)
                    experienceSection(for: user)
                    statisticsSection(for: user)
                    settingsSection
                }
            }
            .navigationTitle(localization.localized(L10n.Tab.profile))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showUserTypePicker) {
                UserTypePickerView()
            }
        }
        .appBackground()
        .overlay(alignment: .top) {
            if case .error(let error) = userState {
                FeedbackBanner(
                    severity: .error,
                    messages: [error.localizedDescription(using: localization)],
                    action: FeedbackAction(
                        title: localization.localized(L10n.Error.retry),
                        action: retryLoadUser
                    )
                )
                .padding()
            }
        }
    }
    
    private func profileHeader(for user: User) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.basicsCardColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundColor(AppColors.basicsCardColor)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(user.displayName)
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                if let email = user.email {
                    Text(email)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, AppSpacing.sm)
    }
    
    @ViewBuilder
    private func userTypeSection(for user: User) -> some View {
        Section(localization.localized(L10n.Profile.userType)) {
            HStack {
                Image(systemName: user.userType.icon)
                    .foregroundColor(AppColors.basicsCardColor)
                Text(user.userType.displayName)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Button(action: { showUserTypePicker = true }) {
                    Text(localization.localized(L10n.Common.edit))
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.basicsCardColor)
                }
            }
        }
    }
    
    @ViewBuilder
    private func communitiesSection(for user: User) -> some View {
        Section(localization.localized(L10n.Profile.communities)) {
            if user.communities.isEmpty {
                Text(localization.localized(L10n.Profile.noCommunities))
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            } else {
                ForEach(user.communities) { community in
                    HStack {
                        if let icon = community.icon {
                            Image(systemName: icon)
                                .foregroundColor(AppColors.basicsCardColor)
                        }
                        Text(community.displayName)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            
            /*
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.basicsCardColor)
                    Text(localization.localized(L10n.Profile.addCommunity))
                        .foregroundColor(AppColors.basicsCardColor)
                }
            }
            */
        }
    }
    
    @ViewBuilder
    private func experienceSection(for user: User) -> some View {
        if let experienceLevel = user.experienceLevel {
            Section(localization.localized(L10n.Profile.experience)) {
                Text(experienceLevel.displayName)
                    .foregroundColor(AppColors.textPrimary)
                
                if !user.certifications.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(localization.localized(L10n.Profile.certifications))
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        ForEach(user.certifications) { cert in
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(AppColors.successGreen)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cert.name)
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text(cert.issuingOrganization)
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func statisticsSection(for user: User) -> some View {
        Section(localization.localized(L10n.Profile.statistics)) {
            HStack {
                Text(localization.localized(L10n.Profile.contributions))
                Spacer()
                Text("\(user.contributionsCount)")
                    .foregroundColor(AppColors.textSecondary)
            }
            
            HStack {
                Text(localization.localized(L10n.Profile.reputation))
                Spacer()
                Text("\(user.reputation)")
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    private var settingsSection: some View {
        Section {
            Button(action: { showEditProfile = true }) {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(AppColors.basicsCardColor)
                    Text(localization.localized(L10n.Profile.editProfile))
                        .foregroundColor(AppColors.basicsCardColor)
                }
            }
            
            Button(role: .destructive, action: userStore.signOut) {
                HStack {
                    Image(systemName: "arrow.right.square")
                    Text(localization.localized(L10n.Auth.signOut))
                }
            }
            
            Button(role: .destructive, action: { showDeleteAccountAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text(localization.localized(L10n.Profile.deleteAccount))
                }
            }
            .alert(localization.localized(L10n.Profile.deleteAccount), isPresented: $showDeleteAccountAlert) {
                Button(localization.localized(L10n.Common.cancel), role: .cancel) { }
                Button(localization.localized(L10n.Common.delete), role: .destructive) {
                    userStore.signOut()
                }
            } message: {
                Text(localization.localized(L10n.Profile.deleteAccountConfirmation))
            }
        }
    }
    
    private func retryLoadUser() {
        userStore.loadStoredUser()
    }
}

// MARK: - User Type Picker

struct UserTypePickerView: View {
    @Environment(\.userStore) private var userStore
    @Environment(\.localization) private var localization
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(UserType.allCases, id: \.self) { type in
                    Button(action: {
                        do {
                            try userStore.updateUserType(type)
                            dismiss()
                        } catch {
                            print("Failed to update user type: \(error)")
                        }
                    }) {
                        HStack {
                            Image(systemName: type.icon)
                                .foregroundColor(AppColors.basicsCardColor)
                            Text(type.displayName)
                                .foregroundColor(AppColors.textPrimary)
                            
                            if userStore.currentUser?.userType == type {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.basicsCardColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle(localization.localized(L10n.Profile.selectUserType))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.localized(L10n.Common.cancel)) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(\.userStore, {
            let store = UserStore()
            store.loadStoredUser()
            return store
        }())
        .environment(\.localization, LocalizationService())
}
