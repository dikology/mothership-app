//
//  ContentFetcher.swift
//  sailingdesk
//
//  Service for fetching content from GitHub (captains-locker)
//

import Foundation

enum ContentFetcher {
    static let baseURLString = "https://raw.githubusercontent.com/dikology/captains-locker/master"
    private static let cache = ContentCache.shared
    private static let rateLimitTracker = RateLimitTracker.shared
    private static let retryStrategy = RetryStrategy.default
    
    /// Fetch markdown content from GitHub with caching and retry logic
    /// - Parameters:
    ///   - path: Path to markdown file
    ///   - useCache: Whether to use cached content if available (default: true)
    ///   - forceRefresh: Whether to force refresh even if cache exists (default: false)
    /// - Returns: Markdown content string
    static func fetchMarkdown(
        path: String,
        useCache: Bool = true,
        forceRefresh: Bool = false
    ) async throws -> String {
        let cacheKey = "markdown:\(path)"
        
        // Check cache first (unless forcing refresh)
        if useCache && !forceRefresh {
            if let cachedData = cache.load(for: cacheKey),
               let cachedContent = String(data: cachedData, encoding: .utf8) {
                return cachedContent
            }
        }
        
        // Check rate limit before making request
        let rateLimitStatus = rateLimitTracker.checkRateLimit()
        if rateLimitStatus.isRateLimited {
            // Try to return cached content even if stale
            if useCache, let cachedData = cache.load(for: cacheKey),
               let cachedContent = String(data: cachedData, encoding: .utf8) {
                throw ContentFetchError.rateLimited(
                    timeUntilReset: rateLimitStatus.userMessage.contains("hour") ? 3600 : 60
                )
            }
            if case .rateLimited(let timeUntilReset) = rateLimitStatus {
                throw ContentFetchError.rateLimited(timeUntilReset: timeUntilReset)
            }
        }
        
        // Properly encode the path components for URL (handles Cyrillic and special characters)
        let pathComponents = path.components(separatedBy: "/")
        let encodedComponents = pathComponents.map { component in
            var allowed = CharacterSet.alphanumerics
            allowed.insert(charactersIn: "-._")
            return component.addingPercentEncoding(withAllowedCharacters: allowed) ?? component
        }
        let encodedPath = encodedComponents.joined(separator: "/")
        
        let fullURLString = "\(baseURLString)/\(encodedPath)"
        guard let url = URL(string: fullURLString) else {
            throw ContentFetchError.invalidURL(fullURLString)
        }
        
        // Fetch with retry logic
        return try await retryStrategy.execute {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ContentFetchError.fetchFailed(nil, fullURLString)
            }
            
            // Update rate limit tracker
            rateLimitTracker.update(from: httpResponse)
            
            // Check for rate limit in response
            if httpResponse.statusCode == 403 {
                let rateLimitStatus = rateLimitTracker.checkRateLimit()
                if rateLimitStatus.isRateLimited {
                    if case .rateLimited(let timeUntilReset) = rateLimitStatus {
                        throw ContentFetchError.rateLimited(timeUntilReset: timeUntilReset)
                    }
                }
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ContentFetchError.fetchFailed(httpResponse.statusCode, fullURLString)
            }
            
            guard let content = String(data: data, encoding: .utf8) else {
                throw ContentFetchError.invalidData
            }
            
            // Cache the content
            try? cache.save(data: data, for: cacheKey)
            
            return content
        } shouldRetry: { error in
            // Don't retry on rate limit errors
            if case .rateLimited = error as? ContentFetchError {
                return false
            }
            // Retry on network errors and 5xx errors
            if case .networkError = error as? ContentFetchError {
                return true
            }
            if case .fetchFailed(let statusCode, _) = error as? ContentFetchError,
               let statusCode = statusCode,
               statusCode >= 500 {
                return true
            }
            return false
        }
    }
    
    /// Fetch image from GitHub with caching and retry logic
    /// - Parameters:
    ///   - path: Path to image file
    ///   - useCache: Whether to use cached content if available (default: true)
    ///   - forceRefresh: Whether to force refresh even if cache exists (default: false)
    /// - Returns: Image data
    static func fetchImage(
        path: String,
        useCache: Bool = true,
        forceRefresh: Bool = false
    ) async throws -> Data {
        let cacheKey = "image:\(path)"
        
        // Check cache first (unless forcing refresh)
        if useCache && !forceRefresh {
            if let cachedData = cache.load(for: cacheKey) {
                return cachedData
            }
        }
        
        // Check rate limit before making request
        let rateLimitStatus = rateLimitTracker.checkRateLimit()
        if rateLimitStatus.isRateLimited {
            // Try to return cached content even if stale
            if useCache, let cachedData = cache.load(for: cacheKey) {
                if case .rateLimited(let timeUntilReset) = rateLimitStatus {
                    throw ContentFetchError.rateLimited(timeUntilReset: timeUntilReset)
                }
            }
            if case .rateLimited(let timeUntilReset) = rateLimitStatus {
                throw ContentFetchError.rateLimited(timeUntilReset: timeUntilReset)
            }
        }
        
        // Properly encode the path components for URL
        let pathComponents = path.components(separatedBy: "/")
        let encodedComponents = pathComponents.map { component in
            var allowed = CharacterSet.alphanumerics
            allowed.insert(charactersIn: "-._")
            return component.addingPercentEncoding(withAllowedCharacters: allowed) ?? component
        }
        let encodedPath = encodedComponents.joined(separator: "/")
        
        let fullURLString = "\(baseURLString)/\(encodedPath)"
        guard let url = URL(string: fullURLString) else {
            throw ContentFetchError.invalidURL(fullURLString)
        }
        
        // Fetch with retry logic
        return try await retryStrategy.execute {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ContentFetchError.fetchFailed(nil, fullURLString)
            }
            
            // Update rate limit tracker
            rateLimitTracker.update(from: httpResponse)
            
            // Check for rate limit in response
            if httpResponse.statusCode == 403 {
                let rateLimitStatus = rateLimitTracker.checkRateLimit()
                if rateLimitStatus.isRateLimited {
                    if case .rateLimited(let timeUntilReset) = rateLimitStatus {
                        throw ContentFetchError.rateLimited(timeUntilReset: timeUntilReset)
                    }
                }
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ContentFetchError.fetchFailed(httpResponse.statusCode, fullURLString)
            }
            
            // Cache the image
            try? cache.save(data: data, for: cacheKey)
            
            return data
        } shouldRetry: { error in
            // Don't retry on rate limit errors
            if case .rateLimited = error as? ContentFetchError {
                return false
            }
            // Retry on network errors and 5xx errors
            if case .networkError = error as? ContentFetchError {
                return true
            }
            if case .fetchFailed(let statusCode, _) = error as? ContentFetchError,
               let statusCode = statusCode,
               statusCode >= 500 {
                return true
            }
            return false
        }
    }
    
    /// List available content files from GitHub
    static func listContentFiles(directory: String = "") async throws -> [String] {
        // Note: GitHub raw API doesn't support directory listing
        // This would need to use GitHub API v3/v4 or maintain a manifest file
        // For now, return empty array - content paths should be known/hardcoded
        return []
    }
    
    // MARK: - Flashcard Fetching
    
    /// Fetch flashcards from a GitHub folder with caching and rate limit handling
    /// Uses GitHub API v3 to list files in directory, then fetches each markdown file
    /// - Parameters:
    ///   - folderName: Name of the folder in GitHub repo
    ///   - deckID: ID of the flashcard deck
    ///   - useCache: Whether to use cached content if available (default: true)
    ///   - forceRefresh: Whether to force refresh even if cache exists (default: false)
    /// - Returns: Array of flashcards
    static func fetchFlashcardsFromFolder(
        folderName: String,
        deckID: UUID,
        useCache: Bool = true,
        forceRefresh: Bool = false
    ) async throws -> [Flashcard] {
        let cacheKey = "flashcards:\(folderName)"
        
        // Check cache first (unless forcing refresh)
        if useCache && !forceRefresh {
            if let cachedData = cache.load(for: cacheKey),
               let cachedFlashcards = try? JSONDecoder().decode([CachedFlashcard].self, from: cachedData) {
                return cachedFlashcards.map { $0.toFlashcard(deckID: deckID) }
            }
        }
        
        // Check rate limit before making request
        let rateLimitStatus = rateLimitTracker.checkRateLimit()
        if rateLimitStatus.isRateLimited {
            // Try to return cached content even if stale
            if useCache, let cachedData = cache.load(for: cacheKey),
               let cachedFlashcards = try? JSONDecoder().decode([CachedFlashcard].self, from: cachedData) {
                if case .rateLimited(let timeUntilReset) = rateLimitStatus {
                    throw ContentFetchError.rateLimited(timeUntilReset: timeUntilReset)
                }
            }
            if case .rateLimited(let timeUntilReset) = rateLimitStatus {
                throw ContentFetchError.rateLimited(timeUntilReset: timeUntilReset)
            }
        }
        
        // Use GitHub API v3 to list directory contents
        let encodedFolderName = folderName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? folderName
        let apiURLString = "https://api.github.com/repos/dikology/captains-locker/contents/\(encodedFolderName)"
        
        guard let apiURL = URL(string: apiURLString) else {
            throw ContentFetchError.invalidURL(apiURLString)
        }
        
        // Fetch directory listing with retry
        let (data, response) = try await retryStrategy.execute {
        let (data, response) = try await URLSession.shared.data(from: apiURL)
        
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ContentFetchError.fetchFailed(nil, apiURLString)
            }
            
            // Update rate limit tracker (only logs for API responses)
            rateLimitTracker.update(from: httpResponse)
            
            // Check for rate limit
            if httpResponse.statusCode == 403 {
                let rateLimitStatus = rateLimitTracker.checkRateLimit()
                if rateLimitStatus.isRateLimited {
                    if case .rateLimited(let timeUntilReset) = rateLimitStatus {
                        throw ContentFetchError.rateLimited(timeUntilReset: timeUntilReset)
                    }
                }
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ContentFetchError.fetchFailed(httpResponse.statusCode, apiURLString)
            }
            
            return (data, response)
        } shouldRetry: { error in
            if case .rateLimited = error as? ContentFetchError {
                return false
            }
            if case .networkError = error as? ContentFetchError {
                return true
            }
            if case .fetchFailed(let statusCode, _) = error as? ContentFetchError,
               let statusCode = statusCode,
               statusCode >= 500 {
                return true
            }
            return false
        }
        
        // Parse JSON response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw ContentFetchError.invalidData
        }
        
        // Filter markdown files and fetch each (with rate limit awareness)
        var flashcards: [Flashcard] = []
        var failedFiles: [String] = []
        
        for (index, fileInfo) in json.enumerated() {
            guard let fileName = fileInfo["name"] as? String,
                  fileName.hasSuffix(".md"),
                  let downloadURL = fileInfo["download_url"] as? String,
                  let url = URL(string: downloadURL) else {
                continue
            }
            
            // Check for cancellation
            try Task.checkCancellation()
            
            // Check rate limit before each file fetch
            let currentRateLimitStatus = rateLimitTracker.checkRateLimit()
            if currentRateLimitStatus.isRateLimited {
                NSLog("[ContentFetcher] Rate limit reached while fetching files. Stopping fetch.")
                break
            }
            
            // Fetch markdown content with retry
            do {
                let fileData = try await retryStrategy.execute {
                    let (data, response) = try await URLSession.shared.data(from: url)
                
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw ContentFetchError.fetchFailed(nil, downloadURL)
                    }
                    
                    // Update rate limit tracker (only processes API responses)
                    rateLimitTracker.update(from: httpResponse)
                    
                    guard httpResponse.statusCode == 200 else {
                        throw ContentFetchError.fetchFailed(httpResponse.statusCode, downloadURL)
                    }
                    
                    return data
                } shouldRetry: { error in
                    if case .rateLimited = error as? ContentFetchError {
                        return false
                    }
                    if case .networkError = error as? ContentFetchError {
                        return true
                    }
                    if case .fetchFailed(let statusCode, _) = error as? ContentFetchError,
                       let statusCode = statusCode,
                       statusCode >= 500 {
                        return true
                    }
                    return false
                }
                
                guard let markdownContent = String(data: fileData, encoding: .utf8) else {
                    failedFiles.append(fileName)
                    continue
                }
                
                let flashcard = Flashcard(
                    fileName: fileName,
                    markdownContent: markdownContent,
                    deckID: deckID
                )
                flashcards.append(flashcard)
                
                // Small delay between requests to be respectful
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            } catch is CancellationError {
                failedFiles.append(fileName)
                throw CancellationError()
            } catch {
                failedFiles.append(fileName)
                NSLog("[ContentFetcher] Failed to fetch %@: %@", fileName, error.localizedDescription)
                continue
            }
        }
        
        // Cache the flashcards if we got any
        if !flashcards.isEmpty {
            let cachedFlashcards = flashcards.map { CachedFlashcard(from: $0) }
            if let cacheData = try? JSONEncoder().encode(cachedFlashcards) {
                try? cache.save(data: cacheData, for: cacheKey)
            }
        }
        
        if !failedFiles.isEmpty {
            NSLog("[ContentFetcher] Failed to fetch %d file(s) from %@: %@", failedFiles.count, folderName, failedFiles.joined(separator: ", "))
        }
        
        return flashcards
    }
}

// MARK: - Cached Flashcard Helper

struct CachedFlashcard: Codable {
    let fileName: String
    let markdownContent: String
    
    init(from flashcard: Flashcard) {
        self.fileName = flashcard.fileName
        self.markdownContent = flashcard.markdownContent
    }
    
    func toFlashcard(deckID: UUID) -> Flashcard {
        Flashcard(
            fileName: fileName,
            markdownContent: markdownContent,
            deckID: deckID
        )
    }
}

enum ContentFetchError: LocalizedError {
    case invalidURL(String)
    case fetchFailed(Int?, String?)
    case invalidData
    case networkError(Error)
    case rateLimited(timeUntilReset: TimeInterval)
    case cacheUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .fetchFailed(let statusCode, let urlString):
            if let statusCode = statusCode {
                return "Fetch failed with status code \(statusCode) for URL: \(urlString ?? "unknown")"
            }
            return "Fetch failed for URL: \(urlString ?? "unknown")"
        case .invalidData:
            return "Invalid data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimited(let timeUntilReset):
            let hours = Int(timeUntilReset) / 3600
            let minutes = (Int(timeUntilReset) % 3600) / 60
            if hours > 0 {
                return "Rate limit exceeded. Try again in \(hours) hour\(hours > 1 ? "s" : "")"
            } else {
                return "Rate limit exceeded. Try again in \(minutes) minute\(minutes > 1 ? "s" : "")"
            }
        case .cacheUnavailable:
            return "Cached content unavailable"
        }
    }
    
}

// MARK: - Content Cache Manager

@Observable
final class ContentCache {
    static let shared = ContentCache()
    
    private let cacheDirectory: URL
    private let metadataDirectory: URL
    private let fileManager = FileManager.default
    
    // Default cache expiration: 7 days
    static let defaultMaxAge: TimeInterval = 7 * 24 * 60 * 60
    
    init() {
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cacheDir.appendingPathComponent("ContentCache", isDirectory: true)
        metadataDirectory = cacheDir.appendingPathComponent("ContentCacheMetadata", isDirectory: true)
        
        // Create cache directories if they don't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: metadataDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Cache Operations
    
    func cachePath(for key: String) -> URL {
        // Sanitize key for filesystem (replace / with _)
        let sanitizedKey = key.replacingOccurrences(of: "/", with: "_")
        return cacheDirectory.appendingPathComponent(sanitizedKey)
    }
    
    func metadataPath(for key: String) -> URL {
        let sanitizedKey = key.replacingOccurrences(of: "/", with: "_")
        return metadataDirectory.appendingPathComponent("\(sanitizedKey).json")
    }
    
    func save(data: Data, for key: String) throws {
        let fileURL = cachePath(for: key)
        try data.write(to: fileURL)
        
        // Save metadata
        let metadata = CacheMetadata(lastFetched: Date())
        let metadataData = try JSONEncoder().encode(metadata)
        try metadataData.write(to: metadataPath(for: key))
    }
    
    func load(for key: String) -> Data? {
        let fileURL = cachePath(for: key)
        return try? Data(contentsOf: fileURL)
    }
    
    func hasCached(key: String) -> Bool {
        let fileURL = cachePath(for: key)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    func getLastFetched(for key: String) -> Date? {
        guard let metadataData = try? Data(contentsOf: metadataPath(for: key)),
              let metadata = try? JSONDecoder().decode(CacheMetadata.self, from: metadataData) else {
            return nil
        }
        return metadata.lastFetched
    }
    
    func isStale(key: String, maxAge: TimeInterval = defaultMaxAge) -> Bool {
        guard let lastFetched = getLastFetched(for: key) else {
            return true // No cache, consider stale
        }
        let age = Date().timeIntervalSince(lastFetched)
        return age > maxAge
    }
    
    func clearCache() throws {
        try fileManager.removeItem(at: cacheDirectory)
        try fileManager.removeItem(at: metadataDirectory)
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: metadataDirectory, withIntermediateDirectories: true)
    }
    
    /// Clear stale cache entries older than maxAge
    func clearStale(maxAge: TimeInterval = defaultMaxAge) {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for file in files {
            let key = file.lastPathComponent.replacingOccurrences(of: "_", with: "/")
            if isStale(key: key, maxAge: maxAge) {
                try? fileManager.removeItem(at: file)
                try? fileManager.removeItem(at: metadataPath(for: key))
            }
        }
    }
}

struct CacheMetadata: Codable {
    let lastFetched: Date
}

