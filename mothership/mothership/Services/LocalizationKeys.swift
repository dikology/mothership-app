//
//  LocalizationKeys.swift
//  mothership
//
//  Centralized localization keys for type-safe string access
//

import Foundation

/// Centralized localization keys
/// Usage: L10n.greeting.morning
enum L10n: Sendable {
    // MARK: - Greetings
    
    enum Greeting: Sendable {
        static let morning = "greeting.morning"
        static let day = "greeting.day"
        static let evening = "greeting.evening"
        static let night = "greeting.night"
        static let subtitle = "greeting.subtitle"
    }
    
    // MARK: - Charter
    
    enum Charter: Sendable {
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
    
    enum Practice: Sendable {
        static let practice = "practice.practice"
        static let essentialChecklistsAndPracticalGuides = "practice.essential_checklists_and_practical_guides"
        static let essentialBriefingsForYourCharter = "practice.essential_briefings_for_your_charter"
        static let briefing = "practice.briefing"
        static let knots = "practice.knots"
        static let maneuvering = "practice.maneuvering"
        static let mooring = "practice.mooring"
        static let safety = "practice.safety"
        static let all = "practice.all"
        
        enum Module: Sendable {
            static let safetyBriefingTitle = "practice.module.safety_briefing.title"
            static let safetyBriefingSubtitle = "practice.module.safety_briefing.subtitle"
            static let lifeOnYachtTitle = "practice.module.life_on_yacht.title"
            static let lifeOnYachtSubtitle = "practice.module.life_on_yacht.subtitle"
            static let firstAidKitTitle = "practice.module.first_aid_kit.title"
            static let firstAidKitSubtitle = "practice.module.first_aid_kit.subtitle"
            static let goingAshoreTitle = "practice.module.going_ashore.title"
            static let goingAshoreSubtitle = "practice.module.going_ashore.subtitle"
            static let mooringAndDepartureTitle = "practice.module.mooring_and_departure.title"
            static let mooringAndDepartureSubtitle = "practice.module.mooring_and_departure.subtitle"
            static let roundTurnTitle = "practice.module.round_turn.title"
            static let roundTurnSubtitle = "practice.module.round_turn.subtitle"
            static let preDepartureTitle = "practice.module.pre_departure.title"
            static let preDepartureSubtitle = "practice.module.pre_departure.subtitle"
            static let departureFromPierTitle = "practice.module.departure_from_pier.title"
            static let departureFromPierSubtitle = "practice.module.departure_from_pier.subtitle"
            static let mediterraneanMooringTitle = "practice.module.mediterranean_mooring.title"
            static let mediterraneanMooringSubtitle = "practice.module.mediterranean_mooring.subtitle"
            static let anchoringTitle = "practice.module.anchoring.title"
            static let anchoringSubtitle = "practice.module.anchoring.subtitle"
        }
    }
    
    // MARK: - Tab Bar
    
    enum Tab: Sendable {
        static let home = "tab.home"
        static let learn = "tab.learn"
        static let practice = "tab.practice"
        static let profile = "tab.profile"
    }
    
    // MARK: - Checklist
    
    enum Checklist: Sendable {
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
    
    enum Common: Sendable {
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
    
    enum Learn: Sendable {
        static let learn = "learn.learn"
        static let studyWithSpacedRepetition = "learn.study_with_spaced_repetition"
        static let showAnswer = "learn.show_answer"
        static let reviewComplete = "learn.review_complete"
        static let greatJob = "learn.great_job"
        static let noCardsDue = "learn.no_cards_due"
        static let allCardsReviewed = "learn.all_cards_reviewed"
        
        enum Deck: Sendable {
            static let soundSignals = "learn.deck.sound_signals"
            static let soundSignalsDescription = "learn.deck.sound_signals.description"
            static let navigationLights = "learn.deck.navigation_lights"
            static let navigationLightsDescription = "learn.deck.navigation_lights.description"
            static let colregs = "learn.deck.colregs"
            static let colregsDescription = "learn.deck.colregs.description"
        }
    }
    
    // MARK: - Auth
    
    enum Auth: Sendable {
        static let welcomeMessage = "auth.welcome_message"
        static let signInWithApple = "auth.sign_in_with_apple"
        static let continueAsGuest = "auth.continue_as_guest"
        static let privacyPolicy = "auth.privacy_policy"
        static let signOut = "auth.sign_out"
        static let notSignedIn = "auth.not_signed_in"
    }
    
    // MARK: - Profile
    
    enum Profile: Sendable {
        static let userType = "profile.user_type"
        static let communities = "profile.communities"
        static let noCommunities = "profile.no_communities"
        static let addCommunity = "profile.add_community"
        static let experience = "profile.experience"
        static let certifications = "profile.certifications"
        static let statistics = "profile.statistics"
        static let contributions = "profile.contributions"
        static let reputation = "profile.reputation"
        static let editProfile = "profile.edit_profile"
        static let selectUserType = "profile.select_user_type"
        static let deleteAccount = "profile.delete_account"
        static let deleteAccountConfirmation = "profile.delete_account_confirmation"
    }
    
    // MARK: - Error Handling
    
    enum Error: Sendable {
        static let generic = "error.generic"
        static let networkConnection = "error.network_connection"
        static let timeout = "error.timeout"
        static let server = "error.server"
        static let notFound = "error.not_found"
        static let unauthorized = "error.unauthorized"
        static let signInFailed = "error.sign_in_failed"
        static let rateLimit = "error.rate_limit"
        static let validation = "error.validation"
        static let invalidData = "error.invalid_data"
        static let cacheUnavailable = "error.cache_unavailable"
        static let emptyDeck = "error.empty_deck"
        static let malformedMarkdown = "error.malformed_markdown"
        static let loadingCancelled = "error.loading_cancelled"
        static let moduleNotFound = "error.module_not_found"
        static let contentUnavailable = "error.content_unavailable"
        static let cacheFallback = "error.cache_fallback"
        static let retry = "error.retry"
    }
    
    // MARK: - Settings (for future use)
    
    enum Settings: Sendable {
        static let title = "settings.title"
        static let language = "settings.language"
        static let systemLanguage = "settings.system_language"
    }
}

