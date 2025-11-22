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
    var decks: [FlashcardDeck] = []
    var isLoading = false
    var error: Error?
    
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
    func updateDeck(_ deck: FlashcardDeck) {
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
        } else {
            decks.append(deck)
        }
        save()
    }
    
    /// Get flashcards for a deck
    func getFlashcards(for deckID: FlashcardDeck.ID) -> [Flashcard] {
        getDeck(id: deckID)?.flashcards ?? []
    }
    
    /// Get due flashcards for a deck
    func getDueFlashcards(for deckID: FlashcardDeck.ID) -> [Flashcard] {
        let flashcards = getFlashcards(for: deckID)
        return SpacedRepetitionService.getCardsDueToday(from: flashcards)
    }
    
    // MARK: - Flashcard Management
    
    /// Update flashcard after review
    func updateFlashcard(_ flashcard: Flashcard, quality: ReviewQuality) {
        guard var deck = getDeck(id: flashcard.deckID) else { return }
        
        let updated = SpacedRepetitionService.updateAfterReview(flashcard, quality: quality)
        
        // Update flashcard in deck
        if let index = deck.flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            deck.flashcards[index] = updated
            updateDeck(deck)
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
        }
    }
    
    private func load() {
        if let data = userDefaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([FlashcardDeck].self, from: data) {
            decks = decoded
        }
    }
}

