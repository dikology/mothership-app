//
//  ContentCacheTests.swift
//  mothershipTests
//
//  Tests for ContentCache - caching strategy and staleness detection
//

import Testing
@testable import mothership
import Foundation

@MainActor
struct ContentCacheTests {
    
    // MARK: - Cache Operations
    
    @Test("Cache saves and loads data correctly")
    func cache_SaveAndLoad() async throws {
        let cache = ContentCache.shared
        let testKey = "test:save-load"
        let testData = "Test content".data(using: .utf8)!
        
        // Clear any existing cache
        try? cache.clearCache()
        
        // Save
        try cache.save(data: testData, for: testKey)
        
        // Load
        let loadedData = cache.load(for: testKey)
        #expect(loadedData != nil)
        #expect(loadedData == testData)
    }
    
    @Test("Cache detects existing cached data")
    func cache_HasCached() async throws {
        let cache = ContentCache.shared
        let testKey = "test:has-cached"
        let testData = "Test content".data(using: .utf8)!
        
        try? cache.clearCache()
        
        // Initially should not have cache
        #expect(cache.hasCached(key: testKey) == false)
        
        // Save
        try cache.save(data: testData, for: testKey)
        
        // Should now have cached cache
        #expect(cache.hasCached(key: testKey) == true)
    }
    
    @Test("Cache tracks last fetched timestamp")
    func cache_LastFetched() async throws {
        let cache = ContentCache.shared
        let testKey = "test:last-fetched"
        let testData = "Test content".data(using: .utf8)!
        
        try? cache.clearCache()
        
        // Initially should be nil
        #expect(cache.getLastFetched(for: testKey) == nil)
        
        // Save
        try cache.save(data: testData, for: testKey)
        
        // Should have timestamp
        let lastFetched = cache.getLastFetched(for: testKey)
        #expect(lastFetched != nil)
        
        // Should be recent (within last second)
        let timeSinceFetched = Date().timeIntervalSince(lastFetched!)
        #expect(timeSinceFetched >= 0)
        #expect(timeSinceFetched < 1.0)
    }
    
    @Test("Cache detects stale entries")
    func cache_IsStale() async throws {
        let cache = ContentCache.shared
        let testKey = "test:stale"
        let testData = "Test content".data(using: .utf8)!
        
        try? cache.clearCache()
        
        // No cache should be considered stale
        #expect(cache.isStale(key: testKey, maxAge: 3600) == true)
        
        // Save
        try cache.save(data: testData, for: testKey)
        
        // Fresh cache should not be stale
        #expect(cache.isStale(key: testKey, maxAge: 3600) == false)
        
        // Wait a tiny bit to ensure timestamps differ
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        // Should be stale with very short maxAge (effectively 0)
        #expect(cache.isStale(key: testKey, maxAge: 0.001) == true)
    }
    
    @Test("Cache clears all entries")
    func cache_ClearCache() async throws {
        let cache = ContentCache.shared
        let testKey1 = "test:clear-1"
        let testKey2 = "test:clear-2"
        let testData = "Test content".data(using: .utf8)!
        
        try? cache.clearCache()
        
        // Save multiple entries
        try cache.save(data: testData, for: testKey1)
        try cache.save(data: testData, for: testKey2)
        
        // Verify they exist
        #expect(cache.hasCached(key: testKey1) == true)
        #expect(cache.hasCached(key: testKey2) == true)
        
        // Clear
        try cache.clearCache()
        
        // Verify they're gone
        #expect(cache.hasCached(key: testKey1) == false)
        #expect(cache.hasCached(key: testKey2) == false)
    }
    
    @Test("Cache clears stale entries only")
    func cache_ClearStale() async throws {
        let cache = ContentCache.shared
        let freshKey = "test:fresh"
        let staleKey = "test:stale"
        let testData = "Test content".data(using: .utf8)!
        
        try? cache.clearCache()
        
        // Save stale entry first
        try cache.save(data: testData, for: staleKey)
        
        // Wait to make it "old"
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Save fresh entry now
        try cache.save(data: testData, for: freshKey)
        
        // Clear stale with maxAge that catches the first one but not the second
        // staleKey age is > 0.1s
        // freshKey age is ~ 0s
        // maxAge 0.05s will clear staleKey but keep freshKey
        cache.clearStale(maxAge: 0.05)
        
        // Fresh should remain, stale should be gone
        #expect(cache.hasCached(key: freshKey) == true)
        #expect(cache.hasCached(key: staleKey) == false)
    }
    
    @Test("Cache handles special characters in keys")
    func cache_SpecialCharactersInKeys() async throws {
        let cache = ContentCache.shared
        let testKey = "test:path/with/slashes"
        let testData = "Test content".data(using: .utf8)!
        
        try? cache.clearCache()
        
        // Save with special characters
        try cache.save(data: testData, for: testKey)
        
        // Should be able to load
        let loadedData = cache.load(for: testKey)
        #expect(loadedData != nil)
        #expect(loadedData == testData)
    }
    
    @Test("Cache uses correct default max age")
    func cache_DefaultMaxAge() async throws {
        #expect(ContentCache.defaultMaxAge == 7 * 24 * 60 * 60) // 7 days
    }
}

