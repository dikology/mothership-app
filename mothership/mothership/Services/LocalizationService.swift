//
//  LocalizationService.swift
//  mothership
//
//  Localization service with system language detection and manual override support
//

import SwiftUI

@Observable
final class LocalizationService {
    // MARK: - Properties
    
    /// Current language (nil means use system language)
    var currentLanguage: AppLanguage? {
        didSet {
            saveLanguagePreference()
        }
    }
    
    /// Effective language (taking into account system language if no override)
    var effectiveLanguage: AppLanguage {
        currentLanguage ?? systemLanguage
    }
    
    /// System language detected from device settings
    private var systemLanguage: AppLanguage {
        // let preferredLanguage = Locale.preferredLanguages.first ?? "ru"
        
        // // Check if it starts with a supported language code
        // if preferredLanguage.hasPrefix("ru") {
        //     return .russian
        // } else if preferredLanguage.hasPrefix("en") {
        //     return .english
        // }
        
        // Default to Russian
        return .russian
    }
    
    // MARK: - Initialization
    
    init() {
        self.currentLanguage = loadLanguagePreference()
    }
    
    // MARK: - Public Methods
    
    /// Get localized string for key
    func localized(_ key: String) -> String {
        let language = effectiveLanguage
        let bundle = language.bundle
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
    
    /// Get localized string with arguments
    func localized(_ key: String, _ arguments: CVarArg...) -> String {
        let format = localized(key)
        return String(format: format, arguments: arguments)
    }
    
    /// Set language manually (for settings)
    func setLanguage(_ language: AppLanguage?) {
        currentLanguage = language
    }
    
    /// Reset to system language
    func useSystemLanguage() {
        currentLanguage = nil
    }
    
    // MARK: - Private Methods
    
    private func saveLanguagePreference() {
        if let language = currentLanguage {
            UserDefaults.standard.set(language.code, forKey: "app_language")
        } else {
            UserDefaults.standard.removeObject(forKey: "app_language")
        }
    }
    
    private func loadLanguagePreference() -> AppLanguage? {
        guard let code = UserDefaults.standard.string(forKey: "app_language") else {
            return nil
        }
        return AppLanguage(rawValue: code)
    }
}

// MARK: - AppLanguage

enum AppLanguage: String, CaseIterable, Identifiable {
    case russian = "ru"
    case english = "en"
    
    var id: String { rawValue }
    
    var code: String {
        rawValue
    }
    
    var displayName: String {
        switch self {
        case .russian:
            return "Русский"
        case .english:
            return "English"
        }
    }
    
    /// Get the bundle for this language
    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
}

// MARK: - SwiftUI Environment

private struct LocalizationServiceKey: EnvironmentKey {
    static var defaultValue: LocalizationService {
        LocalizationService()
    }
}

extension EnvironmentValues {
    var localization: LocalizationService {
        get { self[LocalizationServiceKey.self] }
        set { self[LocalizationServiceKey.self] = newValue }
    }
}

// MARK: - String Extension

extension String {
    /// Localize string using the localization service from environment
    func localized(using service: LocalizationService) -> String {
        service.localized(self)
    }
    
    /// Localize string with arguments
    func localized(using service: LocalizationService, _ arguments: CVarArg...) -> String {
        let format = service.localized(self)
        return String(format: format, arguments: arguments)
    }
}

