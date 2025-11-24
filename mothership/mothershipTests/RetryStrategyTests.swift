//
//  RetryStrategyTests.swift
//  mothershipTests
//
//  Tests for RetryStrategy - exponential backoff and retry logic
//

import Testing
@testable import mothership
import Foundation

struct RetryStrategyTests {
    
    // MARK: - Retry Logic
    
    @Test("Retry strategy succeeds on first attempt")
    func retryStrategy_SucceedsOnFirstAttempt() async throws {
        let strategy = RetryStrategy.default
        var attemptCount = 0
        
        let result = try await strategy.execute {
            attemptCount += 1
            return "success"
        }
        
        #expect(result == "success")
        #expect(attemptCount == 1)
    }
    
    @Test("Retry strategy retries on transient errors")
    func retryStrategy_RetriesOnTransientErrors() async throws {
        let strategy = RetryStrategy.default
        var attemptCount = 0
        
        let result = try await strategy.execute(
            operation: {
                attemptCount += 1
                if attemptCount < 3 {
                    throw NSError(domain: "TestError", code: 500)
                }
                return "success"
            },
            shouldRetry: { error in
                if let nsError = error as NSError? {
                    return nsError.code >= 500
                }
                return false
            }
        )
        
        #expect(result == "success")
        #expect(attemptCount == 3)
    }
    
    @Test("Retry strategy does not retry on non-retriable errors")
    func retryStrategy_NoRetryOnNonRetriableErrors() async throws {
        let strategy = RetryStrategy.default
        var attemptCount = 0
        
        await #expect(throws: NSError.self) {
            try await strategy.execute(
                operation: {
                    attemptCount += 1
                    throw NSError(domain: "TestError", code: 400) // Client error, not retriable
                },
                shouldRetry: { error in
                    if let nsError = error as NSError? {
                        return nsError.code >= 500 // Only retry 5xx errors
                    }
                    return false
                }
            )
        }
        
        #expect(attemptCount == 1) // Should only try once
    }
    
    @Test("Retry strategy respects max retries")
    func retryStrategy_RespectsMaxRetries() async throws {
        let strategy = RetryStrategy(maxRetries: 2, baseDelay: 0.1, maxDelay: 1.0, jitter: false)
        var attemptCount = 0
        
        await #expect(throws: Error.self) {
            try await strategy.execute(
                operation: {
                    attemptCount += 1
                    throw NSError(domain: "TestError", code: 500)
                },
                shouldRetry: { _ in true }
            )
        }
        
        #expect(attemptCount == 2) // Should try maxRetries times
    }
    
    @Test("Retry strategy calculates exponential backoff correctly")
    func retryStrategy_ExponentialBackoff() async throws {
        let strategy = RetryStrategy(maxRetries: 3, baseDelay: 1.0, maxDelay: 10.0, jitter: false)
        
        // Attempt 1: baseDelay * 2^0 = 1.0
        let delay1 = strategy.delay(for: 1)
        #expect(delay1 == 1.0)
        
        // Attempt 2: baseDelay * 2^1 = 2.0
        let delay2 = strategy.delay(for: 2)
        #expect(delay2 == 2.0)
        
        // Attempt 3: baseDelay * 2^2 = 4.0
        let delay3 = strategy.delay(for: 3)
        #expect(delay3 == 4.0)
    }
    
    @Test("Retry strategy caps delay at maxDelay")
    func retryStrategy_CapsDelayAtMaxDelay() async throws {
        let strategy = RetryStrategy(maxRetries: 5, baseDelay: 10.0, maxDelay: 30.0, jitter: false)
        
        // Even with exponential backoff, should cap at maxDelay
        let delay = strategy.delay(for: 10) // Would be 5120 without cap
        #expect(delay <= 30.0)
    }
    
    @Test("Retry strategy adds jitter when enabled")
    func retryStrategy_AddsJitter() async throws {
        let strategy = RetryStrategy(maxRetries: 3, baseDelay: 1.0, maxDelay: 10.0, jitter: true)
        
        // Run multiple times to verify jitter varies
        var delays: [TimeInterval] = []
        for _ in 0..<10 {
            delays.append(strategy.delay(for: 2))
        }
        
        // All delays should be within ±20% of base delay * 2^1 = 2.0
        // So between 1.6 and 2.4
        for delay in delays {
            #expect(delay >= 1.6)
            #expect(delay <= 2.4)
        }
        
        // Should have some variation (not all the same)
        let uniqueDelays = Set(delays)
        #expect(uniqueDelays.count > 1) // Should have variation
    }
    
    @Test("Retry strategy presets have correct values")
    func retryStrategy_Presets() async throws {
        // Default preset
        #expect(RetryStrategy.default.maxRetries == 3)
        #expect(RetryStrategy.default.baseDelay == 1.0)
        #expect(RetryStrategy.default.maxDelay == 30.0)
        #expect(RetryStrategy.default.jitter == true)
        
        // Aggressive preset
        #expect(RetryStrategy.aggressive.maxRetries == 5)
        #expect(RetryStrategy.aggressive.baseDelay == 0.5)
        #expect(RetryStrategy.aggressive.maxDelay == 60.0)
        
        // Conservative preset
        #expect(RetryStrategy.conservative.maxRetries == 2)
        #expect(RetryStrategy.conservative.baseDelay == 2.0)
        #expect(RetryStrategy.conservative.maxDelay == 15.0)
    }
}

