//
//  UserStore.swift
//  mothership
//
//  User authentication and profile state management
//

import Foundation
import SwiftUI

@Observable
final class UserStore {
    private(set) var currentUser: User?
    private(set) var userState: ViewState<User> = .idle
    var isAuthenticated: Bool { currentUser != nil }
    
    private let authService = AuthService()
    
    init() {
        loadStoredUser()
    }
    
    // MARK: - Authentication
    
    func signInWithApple() async throws {
        await MainActor.run {
            userState = .loading
        }
        
        do {
            let user = try await authService.signInWithApple()
            await MainActor.run {
                currentUser = user
                userState = .loaded(user)
            }
        } catch {
            let appError = AppError.map(error)
            await MainActor.run {
                userState = .error(appError)
            }
            throw appError
        }
    }
    
    func signOut() {
        authService.signOut()
        currentUser = nil
        userState = .empty
    }
    
    func loadStoredUser() {
        if let storedUser = authService.loadStoredUser() {
            currentUser = storedUser
            userState = .loaded(storedUser)
        } else {
            currentUser = nil
            userState = .empty
        }
    }
    
    // MARK: - Profile Management
    
    func updateProfile(_ user: User) throws {
        do {
            try authService.updateUser(user)
            currentUser = user
            userState = .loaded(user)
        } catch {
            let appError = AppError.map(error)
            userState = .error(appError)
            throw appError
        }
    }
    
    func updateUserType(_ type: UserType) throws {
        guard var user = currentUser else { return }
        user.userType = type
        try updateProfile(user)
    }
    
    func addCommunity(_ community: Community) throws {
        guard var user = currentUser else { return }
        if !user.communities.contains(community) {
            user.communities.append(community)
            try updateProfile(user)
        }
    }
    
    func removeCommunity(_ community: Community) throws {
        guard var user = currentUser else { return }
        user.communities.removeAll { $0.id == community.id }
        try updateProfile(user)
    }
    
    func updateExperienceLevel(_ level: ExperienceLevel) throws {
        guard var user = currentUser else { return }
        user.experienceLevel = level
        try updateProfile(user)
    }
    
    func addCertification(_ certification: Certification) throws {
        guard var user = currentUser else { return }
        user.certifications.append(certification)
        try updateProfile(user)
    }
    
    func removeCertification(_ certification: Certification) throws {
        guard var user = currentUser else { return }
        user.certifications.removeAll { $0.id == certification.id }
        try updateProfile(user)
    }
}
