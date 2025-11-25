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
    
    /// Fetch a flashcard deck from GitHub folder with caching and fallback
    /// Note: deckID will be set when merging with existing deck in FlashcardStore
    /// - Parameters:
    ///   - folderName: Name of the folder in GitHub repo
    ///   - displayName: Localized display name
    ///   - description: Optional description
    ///   - existingDeckID: Existing deck ID to preserve
    ///   - useCache: Whether to use cached content (default: true)
    ///   - forceRefresh: Whether to force refresh (default: false)
    /// - Returns: FlashcardDeck
    static func fetchDeck(
        folderName: String,
        displayName: String,
        description: String? = nil,
        existingDeckID: UUID? = nil,
        useCache: Bool = true,
        forceRefresh: Bool = false
    ) async throws -> FlashcardDeck {
        let deckID = existingDeckID ?? UUID()
        
        // Check cache first if not forcing refresh
        if useCache && !forceRefresh {
            let cacheKey = "flashcards:\(folderName)"
            if ContentCache.shared.hasCached(key: cacheKey) {
                if let cachedData = ContentCache.shared.load(for: cacheKey),
                   let cachedFlashcards = try? JSONDecoder().decode([CachedFlashcard].self, from: cachedData),
                   !cachedFlashcards.isEmpty {
                    let isStale = ContentCache.shared.isStale(key: cacheKey)
                    if !isStale {
                        let flashcards = cachedFlashcards.map { $0.toFlashcard(deckID: deckID) }
                        return FlashcardDeck(
                            id: deckID,
                            folderName: folderName,
                            displayName: displayName,
                            description: description,
                            flashcards: flashcards,
                            lastFetched: ContentCache.shared.getLastFetched(for: cacheKey) ?? Date.distantPast
                        )
                    }
                }
            }
        }
        
        do {
        let flashcards = try await ContentFetcher.fetchFlashcardsFromFolder(
            folderName: folderName,
                deckID: deckID,
                useCache: useCache,
                forceRefresh: forceRefresh
        )
        
        let deck = FlashcardDeck(
                id: deckID,
            folderName: folderName,
            displayName: displayName,
            description: description,
            flashcards: flashcards,
            lastFetched: Date()
        )
        
        return deck
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as ContentFetchError {
            // If rate limited and we have cache, try to return cached content
            if case .rateLimited = error, useCache {
                let cacheKey = "flashcards:\(folderName)"
                if let cachedData = ContentCache.shared.load(for: cacheKey),
                   let cachedFlashcards = try? JSONDecoder().decode([CachedFlashcard].self, from: cachedData),
                   !cachedFlashcards.isEmpty {
                    let flashcards = cachedFlashcards.map { $0.toFlashcard(deckID: deckID) }
                    return FlashcardDeck(
                        id: deckID,
                        folderName: folderName,
                        displayName: displayName,
                        description: description,
                        flashcards: flashcards,
                        lastFetched: ContentCache.shared.getLastFetched(for: cacheKey) ?? Date.distantPast
                    )
                }
            }
            throw error
        } catch {
            NSLog("[FlashcardFetcher] Unexpected error fetching deck %@: %@", folderName, error.localizedDescription)
            throw error
        }
    }
    
    /// Fetch all configured decks with smart caching and error handling
    /// Note: This should be called with existing decks from store to preserve IDs
    /// - Parameters:
    ///   - localization: Localization service
    ///   - existingDecks: Existing decks to preserve IDs and SRS data
    ///   - useCache: Whether to use cached content (default: true)
    ///   - forceRefresh: Whether to force refresh (default: false)
    /// - Returns: Array of fetched decks (may include cached content if rate limited)
    static func fetchAllDecks(
        using localization: LocalizationService,
        existingDecks: [FlashcardDeck] = [],
        useCache: Bool = true,
        forceRefresh: Bool = false
    ) async throws -> [FlashcardDeck] {
        var decks: [FlashcardDeck] = []
        var errors: [String: Error] = [:]
        
        for config in deckConfigurations {
            // Check for cancellation before each deck
            try Task.checkCancellation()
            
            do {
                let displayName = localization.localized(config.displayNameKey)
                let description = config.descriptionKey.map { localization.localized($0) }
                
                // Find existing deck by folderName to preserve its ID
                let existingDeck = existingDecks.first { $0.folderName == config.folderName }
                
                let deck = try await fetchDeck(
                    folderName: config.folderName,
                    displayName: displayName,
                    description: description,
                    existingDeckID: existingDeck?.id,
                    useCache: useCache,
                    forceRefresh: forceRefresh
                )
                
                decks.append(deck)
            } catch is CancellationError {
                let errorMsg = "Task cancelled while fetching deck \(config.folderName)"
                errors[config.folderName] = NSError(domain: "FlashcardFetcher", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
                throw CancellationError()
            } catch let error as ContentFetchError {
                errors[config.folderName] = error
                
                // If rate limited, try to use cached content
                if case .rateLimited = error, useCache {
                    let existingDeck = existingDecks.first { $0.folderName == config.folderName }
                    if let existingDeck = existingDeck, !existingDeck.flashcards.isEmpty {
                        decks.append(existingDeck)
                    }
                }
                // Continue fetching other decks even if one fails
            } catch {
                errors[config.folderName] = error
                NSLog("[FlashcardFetcher] Error fetching deck %@: %@", config.folderName, error.localizedDescription)
                // Continue fetching other decks even if one fails
            }
        }
        
        if !errors.isEmpty {
            NSLog("[FlashcardFetcher] Fetch summary: %d succeeded, %d failed", decks.count, errors.count)
        }
        
        // If we got some decks but had errors, that's okay (partial success)
        // But if we got no decks and all failed, throw an error
        if decks.isEmpty && !errors.isEmpty {
            throw errors.values.first!
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

