//
//  LocalizationKeys.swift
//  mothership
//
//  Centralized localization keys for type-safe string access
//

import Foundation

/// Centralized localization keys
/// Usage: L10n.greeting.morning
enum L10n {
    // MARK: - Greetings
    
    enum Greeting {
        static let morning = "greeting.morning"
        static let day = "greeting.day"
        static let evening = "greeting.evening"
        static let night = "greeting.night"
        static let subtitle = "greeting.subtitle"
    }
    
    // MARK: - Charter
    
    enum Charter {
        static let createCharter = "charter.create_charter"
        static let createCharterDescription = "charter.create_charter_description"
    }
    
    // MARK: - Tab Bar
    
    enum Tab {
        static let home = "tab.home"
        static let learn = "tab.learn"
        static let practice = "tab.practice"
        static let profile = "tab.profile"
    }
    
    // MARK: - Common
    
    enum Common {
        static let comingSoon = "common.coming_soon"
        static let cancel = "common.cancel"
        static let save = "common.save"
        static let done = "common.done"
        static let back = "common.back"
    }
    
    // MARK: - Settings (for future use)
    
    enum Settings {
        static let title = "settings.title"
        static let language = "settings.language"
        static let systemLanguage = "settings.system_language"
    }
}

