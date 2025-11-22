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
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }
    
    private let authService = AuthService()
    
    init() {
        // Load stored user on initialization
        loadStoredUser()
    }
    
    // MARK: - Authentication
    
    func signInWithApple() async throws {
        let user = try await authService.signInWithApple()
        currentUser = user
    }
    
    func signOut() {
        authService.signOut()
        currentUser = nil
    }
    
    func loadStoredUser() {
        currentUser = authService.loadStoredUser()
    }
    
    // MARK: - Profile Management
    
    func updateProfile(_ user: User) throws {
        try authService.updateUser(user)
        currentUser = user
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

