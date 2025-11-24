//
//  RetryStrategy.swift
//  mothership
//
//  Retry logic with exponential backoff for network requests
//

import Foundation

struct RetryStrategy {
    let maxRetries: Int
    let baseDelay: TimeInterval
    let maxDelay: TimeInterval
    let jitter: Bool
    
    static let `default` = RetryStrategy(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        jitter: true
    )
    
    static let aggressive = RetryStrategy(
        maxRetries: 5,
        baseDelay: 0.5,
        maxDelay: 60.0,
        jitter: true
    )
    
    static let conservative = RetryStrategy(
        maxRetries: 2,
        baseDelay: 2.0,
        maxDelay: 15.0,
        jitter: true
    )
    
    /// Calculate delay for retry attempt
    func delay(for attempt: Int) -> TimeInterval {
        // Exponential backoff: baseDelay * 2^(attempt-1)
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt - 1))
        
        // Cap at maxDelay
        let cappedDelay = min(exponentialDelay, maxDelay)
        
        // Add jitter (±20%) to prevent thundering herd
        if jitter {
            let jitterAmount = cappedDelay * 0.2
            let randomJitter = Double.random(in: -jitterAmount...jitterAmount)
            return max(0.1, cappedDelay + randomJitter) // Minimum 0.1 seconds
        }
        
        return cappedDelay
    }
    
    /// Execute async operation with retry logic
    func execute<T>(
        operation: @escaping () async throws -> T,
        shouldRetry: @escaping (Error) -> Bool = { _ in true }
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                // Check if we should retry this error
                guard shouldRetry(error) else {
                    throw error
                }
                
                // Don't retry on last attempt
                guard attempt < maxRetries else {
                    break
                }
                
                // Calculate delay and wait
                let delay = delay(for: attempt)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        // All retries exhausted
        throw lastError ?? RetryError.maxRetriesExceeded
    }
}

enum RetryError: LocalizedError {
    case maxRetriesExceeded
    
    var errorDescription: String? {
        switch self {
        case .maxRetriesExceeded:
            return "Maximum retry attempts exceeded"
        }
    }
}

