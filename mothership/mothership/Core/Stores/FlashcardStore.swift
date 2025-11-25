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
    /// Matches by folderName to preserve SRS progress when refreshing content
    func updateDeck(_ deck: FlashcardDeck) {
        AppLogger.info("📦 Updating deck '\(deck.displayName)' with \(deck.flashcards.count) flashcards")
        
        if let index = decks.firstIndex(where: { $0.folderName == deck.folderName }) {
            // Merge: preserve existing deck ID and SRS progress, update content
            var existingDeck = decks[index]
            
            // Update metadata
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
        
        if let deck = getDeck(id: deckID) {
            AppLogger.info("📋 Deck '\(deck.displayName)': \(dueCards.count) cards due out of \(flashcards.count) total")
        }
        
        return dueCards
    }
    
    // MARK: - Flashcard Management
    
    /// Update flashcard after review
    func updateFlashcard(_ flashcard: Flashcard, quality: ReviewQuality) {
        guard var deck = getDeck(id: flashcard.deckID) else {
            AppLogger.warning("⚠️ Cannot update flashcard: deck not found for ID \(flashcard.deckID)")
            return
        }
        
        let updated = SpacedRepetitionService.updateAfterReview(flashcard, quality: quality)
        
        // Update flashcard in deck
        if let index = deck.flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            deck.flashcards[index] = updated
            updateDeck(deck)
            
            AppLogger.debug("💾 Saved progress for '\(flashcard.fileName)': quality=\(quality.rawValue), nextReview=\(updated.nextReview?.description ?? "nil"), interval=\(updated.interval)")
        } else {
            AppLogger.warning("⚠️ Cannot update flashcard: card not found in deck")
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
            AppLogger.debug("💾 Saved \(decks.count) deck(s) with \(totalCards) total flashcards to UserDefaults")
        } else {
            AppLogger.error("❌ Failed to encode flashcard decks for saving")
        }
    }
    
    private func load() {
        if let data = userDefaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([FlashcardDeck].self, from: data) {
            decks = decoded
            
            // Pre-parse all flashcards to cache parsed content
            let allFlashcards = decoded.flatMap { $0.flashcards }
            if !allFlashcards.isEmpty {
                AppLogger.info("📚 Loading \(decoded.count) deck(s) with \(allFlashcards.count) total flashcards")
                FlashcardParsedContentCache.shared.preload(flashcards: allFlashcards)
                
                // Log progress statistics
                for deck in decoded {
                    let stats = getReviewStats(for: deck.id)
                    AppLogger.info("📖 Deck '\(deck.displayName)': \(stats.due) due, \(stats.total) total, \(stats.mastered) mastered")
                }
            }
            
            markDecksLoaded()
        } else {
            deckState = .empty
            AppLogger.info("📚 No saved flashcard decks found")
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

