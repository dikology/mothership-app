//
//  AuthService.swift
//  mothership
//
//  Authentication service orchestration
//

import Foundation

@MainActor
final class AuthService {
    private let tokenManager = TokenManager.shared
    private let appleSignInProvider = AppleSignInProvider()
    
    func signInWithApple() async throws -> User {
        let user = try await appleSignInProvider.signIn()
        
        // Save user to keychain
        try tokenManager.saveUser(user)
        
        return user
    }
    
    func signOut() {
        tokenManager.deleteUser()
        tokenManager.deleteAppleToken()
    }
    
    func loadStoredUser() -> User? {
        return tokenManager.loadUser()
    }
    
    func updateUser(_ user: User) throws {
        var updatedUser = user
        updatedUser.lastUpdated = Date()
        try tokenManager.saveUser(updatedUser)
    }
}

