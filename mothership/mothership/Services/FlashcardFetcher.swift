//
//  FlashcardFetcher.swift
//  mothership
//
//  Service for fetching flashcard decks from GitHub folders
//

import Foundation

enum FlashcardFetcher {
    
    /// Predefined flashcard deck configurations
    /// These define which folders to fetch and their localized names
    static let deckConfigurations: [DeckConfiguration] = [
        DeckConfiguration(
            folderName: "звуковые сигналы",
            displayNameKey: "learn.deck.sound_signals",
            descriptionKey: "learn.deck.sound_signals.description"
        ),
        DeckConfiguration(
            folderName: "навигационные огни",
            displayNameKey: "learn.deck.navigation_lights",
            descriptionKey: "learn.deck.navigation_lights.description"
        ),
        DeckConfiguration(
            folderName: "МППСС",
            displayNameKey: "learn.deck.colregs",
            descriptionKey: "learn.deck.colregs.description"
        )
    ]
    
    /// Fetch a flashcard deck from GitHub folder
    /// Note: deckID will be set when merging with existing deck in FlashcardStore
    static func fetchDeck(
        folderName: String,
        displayName: String,
        description: String? = nil,
        existingDeckID: UUID? = nil
    ) async throws -> FlashcardDeck {
        let flashcards = try await ContentFetcher.fetchFlashcardsFromFolder(
            folderName: folderName,
            deckID: existingDeckID ?? UUID()
        )
        
        let deck = FlashcardDeck(
            id: existingDeckID ?? UUID(),
            folderName: folderName,
            displayName: displayName,
            description: description,
            flashcards: flashcards,
            lastFetched: Date()
        )
        
        return deck
    }
    
    /// Fetch all configured decks
    /// Note: This should be called with existing decks from store to preserve IDs
    static func fetchAllDecks(
        using localization: LocalizationService,
        existingDecks: [FlashcardDeck] = []
    ) async throws -> [FlashcardDeck] {
        var decks: [FlashcardDeck] = []
        
        for config in deckConfigurations {
            do {
                let displayName = localization.localized(config.displayNameKey)
                let description = config.descriptionKey.map { localization.localized($0) }
                
                // Find existing deck by folderName to preserve its ID
                let existingDeck = existingDecks.first { $0.folderName == config.folderName }
                
                let deck = try await fetchDeck(
                    folderName: config.folderName,
                    displayName: displayName,
                    description: description,
                    existingDeckID: existingDeck?.id
                )
                decks.append(deck)
            } catch {
                print("⚠️ Failed to fetch deck \(config.folderName): \(error.localizedDescription)")
                // Continue fetching other decks even if one fails
            }
        }
        
        return decks
    }
}

// MARK: - Deck Configuration

struct DeckConfiguration {
    let folderName: String
    let displayNameKey: String
    let descriptionKey: String?
}

