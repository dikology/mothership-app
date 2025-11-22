//
//  TokenManager.swift
//  mothership
//
//  Secure token and user data storage using Keychain
//

import Foundation
import Security

final class TokenManager {
    static let shared = TokenManager()
    
    private let service = "com.mothership.app"
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Keychain Operations
    
    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw TokenManagerError.saveFailed
        }
    }
    
    func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return data
    }
    
    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - User Data
    
    func saveUser(_ user: User) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        try save(data, forKey: "current_user")
    }
    
    func loadUser() -> User? {
        guard let data = load(forKey: "current_user") else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(User.self, from: data)
    }
    
    func deleteUser() {
        delete(forKey: "current_user")
    }
    
    // MARK: - Apple Sign In Token
    
    func saveAppleToken(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw TokenManagerError.invalidData
        }
        try save(data, forKey: "apple_token")
    }
    
    func loadAppleToken() -> String? {
        guard let data = load(forKey: "apple_token"),
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        return token
    }
    
    func deleteAppleToken() {
        delete(forKey: "apple_token")
    }
}

enum TokenManagerError: LocalizedError {
    case saveFailed
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data to keychain"
        case .invalidData:
            return "Invalid data format"
        }
    }
}

