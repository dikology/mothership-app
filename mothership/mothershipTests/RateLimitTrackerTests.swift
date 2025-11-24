//
//  RateLimitTrackerTests.swift
//  mothershipTests
//
//  Tests for RateLimitTracker - rate limit detection and tracking
//

import Testing
@testable import mothership
import Foundation

struct RateLimitTrackerTests {
    
    // MARK: - Rate Limit Detection
    
    @Test("Tracker initializes with default values")
    func tracker_Initialization() async throws {
        let tracker = RateLimitTracker.shared
        tracker.reset()
        
        let status = tracker.checkRateLimit()
        
        // Should start with ok status (default 60 remaining)
        if case .ok(let remaining) = status {
            #expect(remaining == 60)
        } else {
            Issue.record("Expected ok status, got \(status)")
        }
    }
    
    @Test("Tracker updates from GitHub API response")
    func tracker_UpdateFromAPIResponse() async throws {
        let tracker = RateLimitTracker.shared
        tracker.reset()
        
        // Create mock HTTP response with rate limit headers
        let url = URL(string: "https://api.github.com/repos/test/repo")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "X-RateLimit-Limit": "60",
                "X-RateLimit-Remaining": "45",
                "X-RateLimit-Used": "15",
                "X-RateLimit-Reset": "\(Int(Date().addingTimeInterval(3600).timeIntervalSince1970))"
            ]
        )!
        
        tracker.update(from: response)
        
        let status = tracker.checkRateLimit()
        
        // Should have 45 remaining
        if case .ok(let remaining) = status {
            #expect(remaining == 45)
        } else {
            Issue.record("Expected ok status with 45 remaining, got \(status)")
        }
    }
    
    @Test("Tracker ignores raw.githubusercontent.com responses")
    func tracker_IgnoresRawGitHubResponses() async throws {
        let tracker = RateLimitTracker.shared
        tracker.reset()
        
        // Set initial state
        let apiURL = URL(string: "https://api.github.com/repos/test/repo")!
        let apiResponse = HTTPURLResponse(
            url: apiURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "X-RateLimit-Remaining": "50"
            ]
        )!
        tracker.update(from: apiResponse)
        
        let initialStatus = tracker.checkRateLimit()
        var initialRemaining = 0
        if case .ok(let remaining) = initialStatus {
            initialRemaining = remaining
        }
        
        // Update with raw.githubusercontent.com response (should be ignored)
        let rawURL = URL(string: "https://raw.githubusercontent.com/test/repo/master/file.md")!
        let rawResponse = HTTPURLResponse(
            url: rawURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "X-RateLimit-Remaining": "999" // Should be ignored
            ]
        )!
        tracker.update(from: rawResponse)
        
        let finalStatus = tracker.checkRateLimit()
        
        // Should still have 50 remaining (not updated to 999)
        if case .ok(let remaining) = finalStatus {
            #expect(remaining == initialRemaining)
        } else {
            Issue.record("Expected ok status with \(initialRemaining) remaining, got \(finalStatus)")
        }
    }
    
    @Test("Tracker detects rate limit when remaining is 0")
    func tracker_DetectsRateLimit() async throws {
        let tracker = RateLimitTracker.shared
        tracker.reset()
        
        let url = URL(string: "https://api.github.com/repos/test/repo")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "X-RateLimit-Remaining": "0",
                "X-RateLimit-Reset": "\(Int(Date().addingTimeInterval(3600).timeIntervalSince1970))"
            ]
        )!
        
        tracker.update(from: response)
        
        let status = tracker.checkRateLimit()
        
        // Should be rate limited
        #expect(status.isRateLimited == true)
        
        if case .rateLimited(let timeUntilReset) = status {
            #expect(timeUntilReset > 0)
            #expect(timeUntilReset <= 3600)
        } else {
            Issue.record("Expected rateLimited status, got \(status)")
        }
    }
    
    @Test("Tracker provides warning when remaining is low")
    func tracker_WarningWhenLow() async throws {
        let tracker = RateLimitTracker.shared
        tracker.reset()
        
        let url = URL(string: "https://api.github.com/repos/test/repo")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "X-RateLimit-Remaining": "5" // Less than 10
            ]
        )!
        
        tracker.update(from: response)
        
        let status = tracker.checkRateLimit()
        
        // Should be warning
        if case .warning(let remaining) = status {
            #expect(remaining == 5)
        } else {
            Issue.record("Expected warning status with 5 remaining, got \(status)")
        }
    }
    
    @Test("Tracker calculates time until reset correctly")
    func tracker_TimeUntilReset() async throws {
        let tracker = RateLimitTracker.shared
        tracker.reset()
        
        let resetTime = Date().addingTimeInterval(1800) // 30 minutes from now
        let url = URL(string: "https://api.github.com/repos/test/repo")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "X-RateLimit-Remaining": "0",
                "X-RateLimit-Reset": "\(Int(resetTime.timeIntervalSince1970))"
            ]
        )!
        
        tracker.update(from: response)
        
        let timeUntilReset = tracker.timeUntilReset()
        #expect(timeUntilReset != nil)
        
        if let time = timeUntilReset {
            // Should be approximately 30 minutes (allow some tolerance)
            #expect(time > 1700) // > 28 minutes
            #expect(time < 1900) // < 32 minutes
        }
    }
    
    @Test("Tracker resets correctly")
    func tracker_Reset() async throws {
        let tracker = RateLimitTracker.shared
        
        // Set to rate limited state
        let url = URL(string: "https://api.github.com/repos/test/repo")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "X-RateLimit-Remaining": "0"
            ]
        )!
        tracker.update(from: response)
        
        #expect(tracker.checkRateLimit().isRateLimited == true)
        
        // Reset
        tracker.reset()
        
        // Should be back to default
        let status = tracker.checkRateLimit()
        if case .ok(let remaining) = status {
            #expect(remaining == 60)
        } else {
            Issue.record("Expected ok status after reset, got \(status)")
        }
    }
    
    @Test("RateLimitStatus provides correct user messages")
    func rateLimitStatus_UserMessages() async throws {
        let okStatus = RateLimitStatus.ok(remaining: 50)
        #expect(okStatus.userMessage.contains("50"))
        
        let warningStatus = RateLimitStatus.warning(remaining: 5)
        #expect(warningStatus.userMessage.contains("5"))
        #expect(warningStatus.userMessage.contains("Low"))
        
        let rateLimitedStatus = RateLimitStatus.rateLimited(timeUntilReset: 3600)
        #expect(rateLimitedStatus.userMessage.contains("Rate limit exceeded"))
        #expect(rateLimitedStatus.userMessage.contains("hour"))
        
        let rateLimitedMinutes = RateLimitStatus.rateLimited(timeUntilReset: 300)
        #expect(rateLimitedMinutes.userMessage.contains("minute"))
    }
}

