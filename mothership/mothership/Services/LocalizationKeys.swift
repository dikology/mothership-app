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
        static let editCharter = "charter.edit_charter"
        static let editCharterDescription = "charter.edit_charter_description"
        static let deleteCharter = "charter.delete_charter"
        static let deleteCharterConfirmation = "charter.delete_charter_confirmation"
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
    
    // MARK: - Practice
    
    enum Practice {
        static let practice = "practice.practice"
        static let essentialChecklistsAndPracticalGuides = "practice.essential_checklists_and_practical_guides"
        static let essentialBriefingsForYourCharter = "practice.essential_briefings_for_your_charter"
        static let briefing = "practice.briefing"
        static let knots = "practice.knots"
        static let maneuvering = "practice.maneuvering"
        static let mooring = "practice.mooring"
        static let safety = "practice.safety"
        static let all = "practice.all"
    }
    
    // MARK: - Tab Bar
    
    enum Tab {
        static let home = "tab.home"
        static let learn = "tab.learn"
        static let practice = "tab.practice"
        static let profile = "tab.profile"
    }
    
    // MARK: - Checklist
    
    enum Checklist {
        static let checkInChecklist = "checklist.check_in_checklist"
        static let checkAllItemsWhenReceivingYacht = "checklist.check_all_items_when_receiving_yacht"
        static let dailyChecklist = "checklist.daily_checklist"
        static let dailyChecklistSubtitle = "checklist.daily_checklist_subtitle"
        static let progress = "checklist.progress"
        static let items = "checklist.items"
        static let information = "checklist.information"
        static let yourNotes = "checklist.your_notes"
        static let addNote = "checklist.add_note"
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
        static let edit = "common.edit"
        static let delete = "common.delete"
    }
    
    // MARK: - Learn
    
    enum Learn {
        static let learn = "learn.learn"
        static let studyWithSpacedRepetition = "learn.study_with_spaced_repetition"
        static let showAnswer = "learn.show_answer"
        static let reviewComplete = "learn.review_complete"
        static let greatJob = "learn.great_job"
        static let noCardsDue = "learn.no_cards_due"
        static let allCardsReviewed = "learn.all_cards_reviewed"
        
        enum Deck {
            static let soundSignals = "learn.deck.sound_signals"
            static let soundSignalsDescription = "learn.deck.sound_signals.description"
            static let navigationLights = "learn.deck.navigation_lights"
            static let navigationLightsDescription = "learn.deck.navigation_lights.description"
            static let colregs = "learn.deck.colregs"
            static let colregsDescription = "learn.deck.colregs.description"
        }
    }
    
    // MARK: - Settings (for future use)
    
    enum Settings {
        static let title = "settings.title"
        static let language = "settings.language"
        static let systemLanguage = "settings.system_language"
    }
}

