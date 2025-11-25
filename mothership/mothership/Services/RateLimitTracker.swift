//
//  RateLimitTracker.swift
//  mothership
//
//  Tracks GitHub API rate limits and provides rate limit detection
//

import Foundation
import os.log

/// Tracks GitHub API rate limit status
@Observable
final class RateLimitTracker {
    static let shared = RateLimitTracker()
    
    private var remainingRequests: Int = 60 // Default for unauthenticated
    private var resetTime: Date?
    private var isRateLimited: Bool = false
    
    private init() {}
    
    /// Update rate limit info from HTTP response headers
    /// Only processes rate limit headers from GitHub API (api.github.com), not raw.githubusercontent.com
    func update(from response: HTTPURLResponse) {
        let urlString = response.url?.absoluteString ?? ""
        
        // Only process rate limit headers from GitHub API, not raw.githubusercontent.com
        // raw.githubusercontent.com is a CDN and doesn't count against API rate limits
        guard urlString.contains("api.github.com") else {
            return
        }
        
        // GitHub API v3 rate limit headers
        let remainingHeader = response.value(forHTTPHeaderField: "X-RateLimit-Remaining")
        let limitHeader = response.value(forHTTPHeaderField: "X-RateLimit-Limit")
        let resetHeader = response.value(forHTTPHeaderField: "X-RateLimit-Reset")
        
        if let remainingHeader = remainingHeader,
           let remaining = Int(remainingHeader) {
            remainingRequests = remaining
        }
        
        if let resetHeader = resetHeader,
           let resetTimestamp = TimeInterval(resetHeader) {
            resetTime = Date(timeIntervalSince1970: resetTimestamp)
        }
        
        // Check if we're rate limited
        let wasRateLimited = isRateLimited
        isRateLimited = remainingRequests <= 0
        
        // Only log significant changes or warnings
        if isRateLimited && !wasRateLimited {
            NSLog("[RateLimit] Rate limit exceeded. Remaining: %d", remainingRequests)
        } else if !isRateLimited && wasRateLimited {
            NSLog("[RateLimit] Rate limit reset. Remaining: %d", remainingRequests)
        } else if remainingRequests < 10 && !isRateLimited {
            NSLog("[RateLimit] Low remaining requests: %d", remainingRequests)
        }
    }
    
    /// Get current rate limit status for debugging
    func getDebugInfo() -> String {
        var info = "Rate Limit Debug Info:\n"
        info += "  Remaining Requests: \(remainingRequests)\n"
        if let resetTime = resetTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            info += "  Reset Time: \(formatter.string(from: resetTime))\n"
            let timeUntilReset = resetTime.timeIntervalSinceNow
            if timeUntilReset > 0 {
                let hours = Int(timeUntilReset) / 3600
                let minutes = (Int(timeUntilReset) % 3600) / 60
                info += "  Time Until Reset: \(hours)h \(minutes)m\n"
            } else {
                info += "  Reset Time: Already passed\n"
            }
        } else {
            info += "  Reset Time: Not set\n"
        }
        info += "  Is Rate Limited: \(isRateLimited)\n"
        return info
    }
    
    /// Check if we're currently rate limited
    func checkRateLimit() -> RateLimitStatus {
        if isRateLimited {
            if let resetTime = resetTime {
                let timeUntilReset = resetTime.timeIntervalSinceNow
                return .rateLimited(timeUntilReset: timeUntilReset)
            }
            return .rateLimited(timeUntilReset: 3600) // Default 1 hour
        }
        
        if remainingRequests < 10 {
            return .warning(remaining: remainingRequests)
        }
        
        return .ok(remaining: remainingRequests)
    }
    
    /// Get time until rate limit resets (in seconds)
    func timeUntilReset() -> TimeInterval? {
        guard let resetTime = resetTime else { return nil }
        let timeUntilReset = resetTime.timeIntervalSinceNow
        return timeUntilReset > 0 ? timeUntilReset : nil
    }
    
    /// Reset tracker (for testing or manual reset)
    func reset() {
        remainingRequests = 60
        resetTime = nil
        isRateLimited = false
    }
}

enum RateLimitStatus {
    case ok(remaining: Int)
    case warning(remaining: Int)
    case rateLimited(timeUntilReset: TimeInterval)
    
    var isRateLimited: Bool {
        if case .rateLimited = self {
            return true
        }
        return false
    }
    
    var userMessage: String {
        switch self {
        case .ok(let remaining):
            return "API requests remaining: \(remaining)"
        case .warning(let remaining):
            return "Low API requests remaining: \(remaining). Consider refreshing later."
        case .rateLimited(let timeUntilReset):
            let hours = Int(timeUntilReset) / 3600
            let minutes = (Int(timeUntilReset) % 3600) / 60
            if hours > 0 {
                return "Rate limit exceeded. Try again in \(hours) hour\(hours > 1 ? "s" : "")"
            } else {
                return "Rate limit exceeded. Try again in \(minutes) minute\(minutes > 1 ? "s" : "")"
            }
        }
    }
}

