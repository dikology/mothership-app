//
//  FlashcardParsedContentCache.swift
//  mothership
//
//  Cache for parsed markdown content to avoid re-parsing on each review
//

import Foundation

/// Thread-safe cache for parsed flashcard markdown content
final class FlashcardParsedContentCache {
    static let shared = FlashcardParsedContentCache()
    
    private var cache: [UUID: MarkdownContent] = [:]
    private let queue = DispatchQueue(label: "com.mothership.flashcardCache", attributes: .concurrent)
    
    private init() {}
    
    /// Get parsed content for a flashcard (cached)
    func getParsedContent(for flashcard: Flashcard) -> MarkdownContent {
        return queue.sync {
            if let cached = cache[flashcard.id] {
                return cached
            }
            
            // Parse and cache with performance monitoring
            let startTime = CFAbsoluteTimeGetCurrent()
            let parsed = MarkdownParser.parse(flashcard.markdownContent)
            let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000 // Convert to milliseconds
            
            cache[flashcard.id] = parsed
            
            // Log performance for large files (> 1KB)
            let contentSize = flashcard.markdownContent.utf8.count
            if contentSize > 1024 || elapsed > 10 {
                AppLogger.debug("Parsed '\(flashcard.fileName)': \(String(format: "%.1f", elapsed))ms (\(contentSize) bytes)")
            }
            
            return parsed
        }
    }
    
    /// Invalidate cache for a specific flashcard
    func invalidate(for flashcardID: UUID) {
        queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: flashcardID)
        }
    }
    
    /// Clear all cached content
    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
    
    /// Pre-parse and cache content for multiple flashcards
    func preload(flashcards: [Flashcard]) {
        queue.async(flags: .barrier) {
            let startTime = CFAbsoluteTimeGetCurrent()
            var parsedCount = 0
            var totalSize = 0
            
            for flashcard in flashcards {
                if self.cache[flashcard.id] == nil {
                    let parsed = MarkdownParser.parse(flashcard.markdownContent)
                    self.cache[flashcard.id] = parsed
                    parsedCount += 1
                    totalSize += flashcard.markdownContent.utf8.count
                }
            }
            
            let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            // Only log if parsing more than 5 cards or taking significant time
            if parsedCount > 5 || elapsed > 50 {
                AppLogger.info("Pre-parsed \(parsedCount) flashcard(s) in \(String(format: "%.1f", elapsed))ms (\(totalSize / 1024)KB total)")
            }
        }
    }
}

