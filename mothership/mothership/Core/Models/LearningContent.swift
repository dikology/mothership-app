//
//  LearningContent.swift
//  mothership
//
//  Models for learning/flashcard content with SRS
//

import Foundation
import SwiftUI

// MARK: - Flashcard Deck

/// Represents a collection of flashcards from a GitHub folder
struct FlashcardDeck: Identifiable, Hashable, Codable {
    let id: UUID
    var folderName: String              // e.g., "звуковые сигналы"
    var displayName: String             // Localized display name
    var description: String?
    var flashcards: [Flashcard] = []
    var lastFetched: Date?
    
    init(
        id: UUID = UUID(),
        folderName: String,
        displayName: String,
        description: String? = nil,
        flashcards: [Flashcard] = [],
        lastFetched: Date? = nil
    ) {
        self.id = id
        self.folderName = folderName
        self.displayName = displayName
        self.description = description
        self.flashcards = flashcards
        self.lastFetched = lastFetched
    }
}

// MARK: - Flashcard

/// A flashcard containing markdown content with spaced repetition metadata
struct Flashcard: Identifiable, Hashable, Codable {
    let id: UUID
    var fileName: String                 // e.g., "один короткий звук.md"
    var markdownContent: String         // Full markdown content
    var deckID: FlashcardDeck.ID
    
    // SRS (Spaced Repetition System) metadata
    var easeFactor: Double = 2.5         // SM-2 ease factor (default 2.5)
    var interval: Int = 1                // Days until next review
    var repetitions: Int = 0            // Number of successful reviews
    var lastReviewed: Date?
    var nextReview: Date?
    
    // Review quality (0-5, where 0=again, 1=hard, 2=good, 3=easy)
    var lastQuality: Int?
    
    init(
        id: UUID = UUID(),
        fileName: String,
        markdownContent: String,
        deckID: FlashcardDeck.ID,
        easeFactor: Double = 2.5,
        interval: Int = 1,
        repetitions: Int = 0,
        lastReviewed: Date? = nil,
        nextReview: Date? = nil,
        lastQuality: Int? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.markdownContent = markdownContent
        self.deckID = deckID
        self.easeFactor = easeFactor
        self.interval = interval
        self.repetitions = repetitions
        self.lastReviewed = lastReviewed
        self.nextReview = nextReview
        self.lastQuality = lastQuality
    }
    
    /// Check if card is due for review
    var isDue: Bool {
        guard let nextReview = nextReview else {
            return true // New card, always due
        }
        return Date() >= nextReview
    }
    
    /// Get display title from markdown (first line or H1)
    var displayTitle: String {
        let lines = markdownContent.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Skip frontmatter
            if trimmed == "---" { continue }
            if trimmed.hasPrefix("---") { continue }
            // Check for H1
            if trimmed.hasPrefix("# ") {
                return String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            }
            // Use first non-empty line
            if !trimmed.isEmpty && !trimmed.hasPrefix("created:") && !trimmed.hasPrefix("modified:") {
                // Remove markdown formatting
                var title = trimmed
                title = title.replacingOccurrences(of: "**", with: "")
                title = title.replacingOccurrences(of: "[[", with: "")
                title = title.replacingOccurrences(of: "]]", with: "")
                return title.trimmingCharacters(in: .whitespaces)
            }
        }
        // Fallback to filename without extension
        return (fileName as NSString).deletingPathExtension
    }
}

// MARK: - Review Quality

enum ReviewQuality: Int, CaseIterable {
    case again = 0      // Forgot, repeat immediately
    case hard = 1       // Hard, but remembered
    case good = 2       // Good recall
    case easy = 3       // Easy recall
    
    var displayName: String {
        switch self {
        case .again: return "Снова"
        case .hard: return "Трудно"
        case .good: return "Хорошо"
        case .easy: return "Легко"
        }
    }
    
    var color: Color {
        switch self {
        case .again: return AppColors.dangerRed
        case .hard: return AppColors.warningOrange
        case .good: return AppColors.successGreen
        case .easy: return AppColors.lavenderBlue
        }
    }
}

