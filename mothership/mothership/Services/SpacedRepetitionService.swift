//
//  SpacedRepetitionService.swift
//  mothership
//
//  Spaced Repetition System (SM-2 algorithm) for flashcards
//

import Foundation

/// SM-2 Spaced Repetition Algorithm implementation
/// Based on SuperMemo 2 algorithm
enum SpacedRepetitionService {
    
    /// Update flashcard after review with given quality
    /// - Parameters:
    ///   - flashcard: The flashcard to update
    ///   - quality: Review quality (0=again, 1=hard, 2=good, 3=easy)
    /// - Returns: Updated flashcard
    static func updateAfterReview(_ flashcard: Flashcard, quality: ReviewQuality) -> Flashcard {
        var updated = flashcard
        let q = quality.rawValue
        
        // Update ease factor
        updated.easeFactor = calculateNewEaseFactor(
            currentEaseFactor: flashcard.easeFactor,
            quality: q
        )
        
        // Ensure ease factor doesn't go below 1.3
        updated.easeFactor = max(updated.easeFactor, 1.3)
        
        // Update interval and repetitions based on quality
        if q < 2 {
            // Again or Hard: reset repetitions, interval = 1
            updated.repetitions = 0
            updated.interval = 1
        } else {
            // Good or Easy: increase repetitions and interval
            updated.repetitions += 1
            
            if updated.repetitions == 1 {
                updated.interval = 1
            } else if updated.repetitions == 2 {
                updated.interval = 6
            } else {
                updated.interval = Int(Double(updated.interval) * updated.easeFactor)
            }
        }
        
        // Update dates
        updated.lastReviewed = Date()
        
        // Calculate nextReview: always use start of day to avoid time-of-day issues
        // Add interval days to today's start of day
        let today = Calendar.current.startOfDay(for: Date())
        updated.nextReview = Calendar.current.date(byAdding: .day, value: updated.interval, to: today)
        
        updated.lastQuality = q
        
        return updated
    }
    
    /// Calculate new ease factor based on SM-2 formula
    private static func calculateNewEaseFactor(currentEaseFactor: Double, quality: Int) -> Double {
        // SM-2 formula: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        let q = Double(quality)
        let newEaseFactor = currentEaseFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        return max(newEaseFactor, 1.3) // Minimum ease factor is 1.3
    }
    
    /// Get cards due for review from a deck
    static func getDueCards(from flashcards: [Flashcard]) -> [Flashcard] {
        return flashcards.filter { $0.isDue }
    }
    
    /// Get cards due today
    static func getCardsDueToday(from flashcards: [Flashcard]) -> [Flashcard] {
        let today = Calendar.current.startOfDay(for: Date())
        return flashcards.filter { flashcard in
            guard let nextReview = flashcard.nextReview else {
                return true // New cards are due
            }
            let reviewDay = Calendar.current.startOfDay(for: nextReview)
            return reviewDay <= today
        }
    }
    
    /// Get review statistics for a deck
    static func getReviewStats(for flashcards: [Flashcard]) -> ReviewStats {
        let total = flashcards.count
        let due = getCardsDueToday(from: flashcards).count
        let new = flashcards.filter { $0.repetitions == 0 }.count
        let learning = flashcards.filter { $0.repetitions > 0 && $0.repetitions < 3 }.count
        let mastered = flashcards.filter { $0.repetitions >= 3 && !$0.isDue }.count
        
        return ReviewStats(
            total: total,
            due: due,
            new: new,
            learning: learning,
            mastered: mastered
        )
    }
}

// MARK: - Review Statistics

struct ReviewStats {
    let total: Int
    let due: Int
    let new: Int
    let learning: Int
    let mastered: Int
    
    var duePercentage: Double {
        guard total > 0 else { return 0 }
        return Double(due) / Double(total)
    }
}

