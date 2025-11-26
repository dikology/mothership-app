//
//  FlashcardStore.swift
//  mothership
//
//  Store for managing flashcards and decks with SRS
//

import Foundation
import SwiftUI

@Observable
final class FlashcardStore {
    private(set) var decks: [FlashcardDeck] = []
    var deckState: ViewState<[FlashcardDeck]> = .idle
    
    private let userDefaultsKey = "FlashcardStore.v1"
    private let userDefaults: UserDefaults
    
    // Static flag to prevent loading across all instances (in case multiple instances are created)
    private static var hasLoadedGlobally = false
    private var hasLoaded = false // Per-instance flag
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }
    
    // MARK: - Deck Management
    
    /// Get deck by ID
    func getDeck(id: FlashcardDeck.ID) -> FlashcardDeck? {
        decks.first { $0.id == id }
    }
    
    /// Get deck by folder name
    func getDeck(folderName: String) -> FlashcardDeck? {
        decks.first { $0.folderName == folderName }
    }
    
    /// Add or update deck
    /// Matches by deck ID or folder name to preserve SRS progress when refreshing content
    func updateDeck(_ deck: FlashcardDeck) {
            AppLogger.info("Updating deck '\(deck.displayName)' with \(deck.flashcards.count) flashcards")
        
        if let index = decks.firstIndex(where: { $0.id == deck.id || $0.folderName == deck.folderName }) {
            // Merge: preserve existing deck ID and SRS progress, update content
            var existingDeck = decks[index]
            
            // Update metadata
            existingDeck.folderName = deck.folderName
            existingDeck.displayName = deck.displayName
            existingDeck.description = deck.description
            existingDeck.lastFetched = deck.lastFetched
            
            // Merge flashcards: preserve SRS data for existing cards
            var mergedFlashcards: [Flashcard] = []
            var newFlashcards: [Flashcard] = []
            let existingFlashcardIDs = Set(existingDeck.flashcards.map { $0.id })
            
            for newFlashcard in deck.flashcards {
                // Try to find existing flashcard by fileName
                if let existingIndex = existingDeck.flashcards.firstIndex(where: { $0.fileName == newFlashcard.fileName }) {
                    // Preserve existing flashcard with SRS data, but update content if changed
                    var existingFlashcard = existingDeck.flashcards[existingIndex]
                    
                    // Log if we're preserving progress
                    if existingFlashcard.repetitions > 0 || existingFlashcard.nextReview != nil {
                        AppLogger.debug("Preserving progress for '\(existingFlashcard.fileName)': repetitions=\(existingFlashcard.repetitions), nextReview=\(existingFlashcard.nextReview?.description ?? "nil")")
                    }
                    
                    // If content changed, invalidate cache
                    if existingFlashcard.markdownContent != newFlashcard.markdownContent {
                        FlashcardParsedContentCache.shared.invalidate(for: existingFlashcard.id)
                        existingFlashcard.markdownContent = newFlashcard.markdownContent
                    }
                    
                    mergedFlashcards.append(existingFlashcard)
                } else {
                    // New flashcard, use as-is
                    mergedFlashcards.append(newFlashcard)
                    newFlashcards.append(newFlashcard)
                }
            }
            
            existingDeck.flashcards = mergedFlashcards
            decks[index] = existingDeck
            
            // Pre-parse new flashcards
            if !newFlashcards.isEmpty {
                FlashcardParsedContentCache.shared.preload(flashcards: newFlashcards)
            }
        } else {
            // New deck, add it
            decks.append(deck)
            // Pre-parse all flashcards for new deck
            FlashcardParsedContentCache.shared.preload(flashcards: deck.flashcards)
        }
        save()
        markDecksLoaded()
    }
    
    /// Get flashcards for a deck
    func getFlashcards(for deckID: FlashcardDeck.ID) -> [Flashcard] {
        getDeck(id: deckID)?.flashcards ?? []
    }
    
    /// Get due flashcards for a deck
    func getDueFlashcards(for deckID: FlashcardDeck.ID) -> [Flashcard] {
        let flashcards = getFlashcards(for: deckID)
        let dueCards = SpacedRepetitionService.getCardsDueToday(from: flashcards)
        // Removed logging - this is called on every view render, too verbose
        return dueCards
    }
    
    // MARK: - Flashcard Management
    
    /// Update flashcard after review
    func updateFlashcard(_ flashcard: Flashcard, quality: ReviewQuality) {
        guard var deck = getDeck(id: flashcard.deckID) else {
            AppLogger.warning("Cannot update flashcard: deck not found for ID \(flashcard.deckID)")
            return
        }
        
        let updated = SpacedRepetitionService.updateAfterReview(flashcard, quality: quality)
        
        // Update flashcard in deck
        if let index = deck.flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            deck.flashcards[index] = updated
            
            // Update deck in array
            if let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) {
                decks[deckIndex] = deck
                save()
                
                // Log every card to debug progress saving
                AppLogger.debug("Saved progress for '\(flashcard.fileName)': quality=\(quality.rawValue), repetitions=\(updated.repetitions), interval=\(updated.interval), nextReview=\(updated.nextReview?.description ?? "nil")")
            } else {
                AppLogger.error("Cannot find deck in decks array to update")
            }
        } else {
            AppLogger.warning("Cannot update flashcard: card not found in deck")
        }
    }
    
    /// Get review statistics for a deck
    func getReviewStats(for deckID: FlashcardDeck.ID) -> ReviewStats {
        let flashcards = getFlashcards(for: deckID)
        return SpacedRepetitionService.getReviewStats(for: flashcards)
    }
    
    // MARK: - Persistence
    
    private func save() {
        if let data = try? JSONEncoder().encode(decks) {
            userDefaults.set(data, forKey: userDefaultsKey)
            let totalCards = decks.reduce(0) { $0 + $1.flashcards.count }
            AppLogger.debug("Saved \(decks.count) deck(s) with \(totalCards) total flashcards to UserDefaults")
        } else {
            AppLogger.error("Failed to encode flashcard decks for saving")
        }
    }
    
    private func load() {
        // Prevent multiple loads across all instances
        // This handles the case where EnvironmentKeys.defaultValue creates new instances
        guard !Self.hasLoadedGlobally && !hasLoaded else {
            // If already loaded globally, try to sync this instance with the loaded data
            if Self.hasLoadedGlobally, let data = userDefaults.data(forKey: userDefaultsKey),
               let decoded = try? JSONDecoder().decode([FlashcardDeck].self, from: data) {
                self.decks = decoded
                markDecksLoaded()
            }
            return
        }
        
        Self.hasLoadedGlobally = true
        hasLoaded = true
        
        if let data = userDefaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([FlashcardDeck].self, from: data) {
            decks = decoded
            
            // Pre-parse all flashcards to cache parsed content
            let allFlashcards = decoded.flatMap { $0.flashcards }
            if !allFlashcards.isEmpty {
                AppLogger.info("Loading \(decoded.count) deck(s) with \(allFlashcards.count) total flashcards")
                FlashcardParsedContentCache.shared.preload(flashcards: allFlashcards)
                
                // Log progress statistics and verify progress is loaded
                for deck in decoded {
                    let stats = getReviewStats(for: deck.id)
                    let cardsWithProgress = deck.flashcards.filter { $0.repetitions > 0 || $0.nextReview != nil }
                    AppLogger.info("Deck '\(deck.displayName)': \(stats.due) due, \(stats.total) total, \(stats.mastered) mastered, \(cardsWithProgress.count) with saved progress")
                    
                    // If we have cards but no progress, that's suspicious
                    if deck.flashcards.count > 0 && cardsWithProgress.count == 0 {
                        AppLogger.warning("⚠️ Deck '\(deck.displayName)' has no saved progress - all cards appear new")
                    }
                }
            }
            
            markDecksLoaded()
        } else {
            deckState = .empty
            AppLogger.info("No saved flashcard decks found")
        }
    }
    
    // MARK: - View State Helpers
    
    func markDecksLoading() {
        deckState = .loading
    }
    
    func markDecksLoaded() {
        if decks.isEmpty {
            deckState = .empty
        } else {
            deckState = .loaded(decks)
        }
    }
    
    func markDecksError(_ error: AppError) {
        deckState = .error(error)
    }
}

