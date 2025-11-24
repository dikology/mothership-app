//
//  ContentCacheTests.swift
//  mothershipTests
//
//  Tests for ContentCache - caching strategy and staleness detection
//

import Testing
@testable import mothership
import Foundation

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
        
        // Very old cache should be stale - we'll test by waiting or using a very short maxAge
        // For this test, we'll use a very short maxAge to simulate old cache
        // In practice, we'd need to manipulate the file system directly or wait
        // For now, test that fresh cache is not stale with reasonable maxAge
        
        // Should be stale with 1 hour max age
        #expect(cache.isStale(key: testKey, maxAge: 3600) == true)
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
        
        // Save fresh entry
        try cache.save(data: testData, for: freshKey)
        
        // Save stale entry - we'll use a very short maxAge to simulate stale cache
        // In practice, we'd manipulate the metadata file directly
        // For this test, we'll verify the clearStale logic works with a short maxAge
        try cache.save(data: testData, for: staleKey)
        
        // Wait a tiny bit to ensure timestamps differ
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        // Verify both exist
        #expect(cache.hasCached(key: freshKey) == true)
        #expect(cache.hasCached(key: staleKey) == true)
        
        // Clear stale with very short maxAge (0.005 seconds) - should clear staleKey
        cache.clearStale(maxAge: 0.005)
        
        // Fresh should remain (saved just before), stale should be gone (saved earlier)
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

