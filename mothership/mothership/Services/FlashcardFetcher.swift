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
            languageFolders: [
                "ru": "ru/звуковые сигналы",
                "en": "en/sound signals"
            ],
            legacyFolderNames: ["звуковые сигналы"],
            displayNameKey: "learn.deck.sound_signals",
            descriptionKey: "learn.deck.sound_signals.description"
        ),
        DeckConfiguration(
            languageFolders: [
                "ru": "ru/навигационные огни",
                "en": "en/navigation lights"
            ],
            legacyFolderNames: ["навигационные огни"],
            displayNameKey: "learn.deck.navigation_lights",
            descriptionKey: "learn.deck.navigation_lights.description"
        ),
        DeckConfiguration(
            languageFolders: [
                "ru": "ru/МППСС",
                "en": "en/colregs"
            ],
            legacyFolderNames: ["МППСС"],
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
            // Don't log here - let fetchAllDecks handle cancellation logging
            throw CancellationError()
        } catch let error as ContentFetchError {
            // If rate limited and we have cache, try to return cached content
            if case .rateLimited = error, useCache {
                let cacheKey = "flashcards:\(folderName)"
                if let cachedData = ContentCache.shared.load(for: cacheKey),
                   let cachedFlashcards = try? JSONDecoder().decode([CachedFlashcard].self, from: cachedData),
                   !cachedFlashcards.isEmpty {
                    AppLogger.info("Using cached content for '\(folderName)' (rate limited)")
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
            // Don't log here - let fetchAllDecks handle error logging to avoid duplicates
            throw error
        } catch {
            // Don't log here - let fetchAllDecks handle error logging to avoid duplicates
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
        let languageCode = localization.effectiveLanguage.code
        var decks: [FlashcardDeck] = []
        var errors: [String: Error] = [:]
        
        for config in deckConfigurations {
            let folderPath = config.folderPath(for: languageCode)
            // Check for cancellation before each deck
            try Task.checkCancellation()
            
            do {
                let displayName = localization.localized(config.displayNameKey)
                let description = config.descriptionKey.map { localization.localized($0) }
                
                // Find existing deck by folder path (or legacy names) to preserve its ID
                let existingDeck = config.existingDeck(for: languageCode, in: existingDecks)
                
                let deck = try await fetchDeck(
                    folderName: folderPath,
                    displayName: displayName,
                    description: description,
                    existingDeckID: existingDeck?.id,
                    useCache: useCache,
                    forceRefresh: forceRefresh
                )
                
                decks.append(deck)
            } catch is CancellationError {
                // Cancellation is expected when user pulls to refresh and releases, or navigates away
                // Don't treat it as an error - just continue with other decks
                // Don't log or add to errors - this is normal behavior
                continue
            } catch let error as ContentFetchError {
                errors[folderPath] = error
                
                // If rate limited, try to use cached content
                if case .rateLimited(let timeUntilReset) = error, useCache {
                    AppLogger.warning("Rate limited for '\(folderPath)', using cached content (resets in \(Int(timeUntilReset))s)")
                    let existingDeck = config.existingDeck(for: languageCode, in: existingDecks)
                    if let existingDeck = existingDeck, !existingDeck.flashcards.isEmpty {
                        decks.append(existingDeck)
                    }
                } else {
                    AppLogger.error("Failed to fetch deck '\(folderPath)': \(error.localizedDescription)")
                }
                // Continue fetching other decks even if one fails
            } catch {
                // Check if this is a cancellation error (NSURLErrorCancelled = -999)
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                    // Cancellation is expected - don't log as error, just continue
                    continue
                }
                
                errors[folderPath] = error
                let errorType = String(describing: type(of: error))
                AppLogger.error("Error fetching deck '\(folderPath)': \(error.localizedDescription) (type: \(errorType))")
                // Continue fetching other decks even if one fails
            }
        }
        
        if !errors.isEmpty {
            AppLogger.warning("Fetch summary: \(decks.count) deck(s) succeeded, \(errors.count) failed")
            for (folderName, error) in errors {
                AppLogger.warning("  - '\(folderName)': \(error.localizedDescription)")
            }
        } else if !decks.isEmpty {
            AppLogger.info("Successfully fetched all \(decks.count) deck(s)")
        }
        
        // If we got some decks, that's a success (even if some were cancelled or failed)
        // Only throw if we got no decks AND there were actual errors (not just cancellations)
        if decks.isEmpty && !errors.isEmpty {
            // Check if all errors were cancellations - if so, don't throw
            let nonCancellationErrors = errors.filter { key, error in
                !(error is CancellationError) && !(error as NSError).localizedDescription.contains("cancelled")
            }
            if !nonCancellationErrors.isEmpty {
                throw nonCancellationErrors.values.first!
            }
            // If all were cancellations, just return empty (caller will handle)
        }
        
        return decks
    }
}

// MARK: - Deck Configuration

struct DeckConfiguration {
    let languageFolders: [String: String]
    let legacyFolderNames: [String]
    let displayNameKey: String
    let descriptionKey: String?
    
    init(
        languageFolders: [String: String],
        legacyFolderNames: [String] = [],
        displayNameKey: String,
        descriptionKey: String?
    ) {
        self.languageFolders = languageFolders
        self.legacyFolderNames = legacyFolderNames
        self.displayNameKey = displayNameKey
        self.descriptionKey = descriptionKey
    }
    
    func folderPath(for languageCode: String) -> String {
        if let path = languageFolders[languageCode] {
            return path
        }
        if let ruPath = languageFolders["ru"] {
            return ruPath
        }
        if let enPath = languageFolders["en"] {
            return enPath
        }
        return languageFolders.values.first ?? ""
    }
    
    func existingDeck(for languageCode: String, in decks: [FlashcardDeck]) -> FlashcardDeck? {
        let currentPath = folderPath(for: languageCode)
        return decks.first { deck in
            deck.folderName == currentPath || legacyFolderNames.contains(deck.folderName)
        }
    }
}

