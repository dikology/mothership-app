//
//  AppleSignInProvider.swift
//  mothership
//
//  Sign in with Apple implementation
//

import Foundation
import AuthenticationServices
import CryptoKit
import UIKit

@MainActor
final class AppleSignInProvider: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private var continuation: CheckedContinuation<User, Error>?
    private var currentNonce: String?
    
    func signIn() async throws -> User {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            authorizationController.performRequests()
        }
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthError.invalidCredential)
            continuation = nil
            return
        }
        
        guard let nonce = currentNonce else {
            continuation?.resume(throwing: AuthError.missingNonce)
            continuation = nil
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            continuation?.resume(throwing: AuthError.tokenDecodingFailed)
            continuation = nil
            return
        }
        
        // Save token
        do {
            try TokenManager.shared.saveAppleToken(idTokenString)
        } catch {
            // Log error but continue
            print("Failed to save Apple token: \(error)")
        }
        
        // Create user from credential
        let appleUserID = appleIDCredential.user
        let email = appleIDCredential.email
        let fullName = appleIDCredential.fullName
        
        let displayName: String
        if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
            displayName = "\(givenName) \(familyName)"
        } else if let givenName = fullName?.givenName {
            displayName = givenName
        } else if let familyName = fullName?.familyName {
            displayName = familyName
        } else {
            displayName = email ?? "User"
        }
        
        let user = User(
            appleUserID: appleUserID,
            email: email,
            displayName: displayName,
            userType: .traveler, // Default, can be changed in profile
            communities: []
        )
        
        continuation?.resume(returning: user)
        continuation = nil
        currentNonce = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
        currentNonce = nil
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Get the window from the scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available for Apple Sign In")
        }
        return window
    }
    
    // MARK: - Helper Methods
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

enum AuthError: LocalizedError {
    case invalidCredential
    case missingNonce
    case tokenDecodingFailed
    case userCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid authentication credential"
        case .missingNonce:
            return "Missing security nonce"
        case .tokenDecodingFailed:
            return "Failed to decode authentication token"
        case .userCreationFailed:
            return "Failed to create user account"
        }
    }
}

