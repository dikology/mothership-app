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
        static let mainInformation = "charter.main_information"
        static let charterName = "charter.charter_name"
        static let charterNameExample = "charter.charter_name_example"
        static let startDate = "charter.start_date"
        static let endDate = "charter.end_date"
        static let additionalInformation = "charter.additional_information"
        static let location = "charter.location"
        static let locationExample = "charter.location_example"
        static let yachtName = "charter.yacht_name"
        static let yachtNameExample = "charter.yacht_name_example"
        static let charterCompany = "charter.charter_company"
        static let charterCompanyExample = "charter.charter_company_example"
        static let notes = "charter.notes"
        static let setAsActive = "charter.set_as_active"
        static let charterNameRequired = "charter.charter_name_required"
        static let information = "charter.information"
        static let charter = "charter.charter"
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
        static let error = "common.error"
        static let ok = "common.ok"
    }
    
    // MARK: - Settings (for future use)
    
    enum Settings {
        static let title = "settings.title"
        static let language = "settings.language"
        static let systemLanguage = "settings.system_language"
    }
}

