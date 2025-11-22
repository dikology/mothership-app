//
//  ContentFetcher.swift
//  sailingdesk
//
//  Service for fetching content from GitHub (captains-locker)
//

import Foundation

enum ContentFetcher {
    static let baseURLString = "https://raw.githubusercontent.com/dikology/captains-locker/master"
    
    /// Fetch markdown content from GitHub
    static func fetchMarkdown(path: String) async throws -> String {
        // Properly encode the path components for URL (handles Cyrillic and special characters)
        let pathComponents = path.components(separatedBy: "/")
        let encodedComponents = pathComponents.map { component in
            // Encode each component - only allow ASCII alphanumeric, dash, underscore, dot
            // This ensures Cyrillic and other non-ASCII characters are properly encoded
            var allowed = CharacterSet.alphanumerics
            allowed.insert(charactersIn: "-._")
            return component.addingPercentEncoding(withAllowedCharacters: allowed) ?? component
        }
        let encodedPath = encodedComponents.joined(separator: "/")
        
        // Construct full URL string directly (GitHub raw URLs need branch in path)
        let fullURLString = "\(baseURLString)/\(encodedPath)"
        guard let url = URL(string: fullURLString) else {
            throw ContentFetchError.invalidURL(fullURLString)
        }
        
        let finalURL = url.absoluteString
        print("🔍 Fetching content from: \(finalURL)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw ContentFetchError.fetchFailed(nil, finalURL)
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ HTTP Error: \(httpResponse.statusCode)")
                throw ContentFetchError.fetchFailed(httpResponse.statusCode, finalURL)
            }
            
            print("✅ Successfully fetched \(data.count) bytes")
            
            guard let content = String(data: data, encoding: .utf8) else {
                print("❌ Failed to decode data as UTF-8")
                throw ContentFetchError.invalidData
            }
            
            return content
        } catch let error as ContentFetchError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ContentFetchError.networkError(error)
        }
    }
    
    /// Fetch image from GitHub
    static func fetchImage(path: String) async throws -> Data {
        // Properly encode the path components for URL (handles Cyrillic and special characters)
        let pathComponents = path.components(separatedBy: "/")
        let encodedComponents = pathComponents.map { component in
            // Encode each component - only allow ASCII alphanumeric, dash, underscore, dot
            // This ensures Cyrillic and other non-ASCII characters are properly encoded
            var allowed = CharacterSet.alphanumerics
            allowed.insert(charactersIn: "-._")
            return component.addingPercentEncoding(withAllowedCharacters: allowed) ?? component
        }
        let encodedPath = encodedComponents.joined(separator: "/")
        
        // Construct full URL string directly (GitHub raw URLs need branch in path)
        let fullURLString = "\(baseURLString)/\(encodedPath)"
        guard let url = URL(string: fullURLString) else {
            throw ContentFetchError.invalidURL(fullURLString)
        }
        
        let finalURL = url.absoluteString
        print("🔍 Fetching image from: \(finalURL)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ContentFetchError.fetchFailed(nil, finalURL)
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ContentFetchError.fetchFailed(httpResponse.statusCode, finalURL)
            }
            
            return data
        } catch let error as ContentFetchError {
            throw error
        } catch {
            throw ContentFetchError.networkError(error)
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
    
    /// Fetch flashcards from a GitHub folder
    /// Uses GitHub API v3 to list files in directory, then fetches each markdown file
    static func fetchFlashcardsFromFolder(folderName: String, deckID: UUID) async throws -> [Flashcard] {
        // Use GitHub API v3 to list directory contents
        // Properly encode folder name for URL (handles Cyrillic characters)
        let encodedFolderName = folderName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? folderName
        let apiURLString = "https://api.github.com/repos/dikology/captains-locker/contents/\(encodedFolderName)"
        
        guard let apiURL = URL(string: apiURLString) else {
            throw ContentFetchError.invalidURL(apiURLString)
        }
        
        // Fetch directory listing
        let (data, response) = try await URLSession.shared.data(from: apiURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ContentFetchError.fetchFailed((response as? HTTPURLResponse)?.statusCode, apiURLString)
        }
        
        // Parse JSON response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw ContentFetchError.invalidData
        }
        
        // Filter markdown files and fetch each
        var flashcards: [Flashcard] = []
        
        for fileInfo in json {
            guard let fileName = fileInfo["name"] as? String,
                  fileName.hasSuffix(".md"),
                  let downloadURL = fileInfo["download_url"] as? String,
                  let url = URL(string: downloadURL) else {
                continue
            }
            
            // Fetch markdown content
            do {
                let (fileData, fileResponse) = try await URLSession.shared.data(from: url)
                
                guard let fileHttpResponse = fileResponse as? HTTPURLResponse,
                      fileHttpResponse.statusCode == 200,
                      let markdownContent = String(data: fileData, encoding: .utf8) else {
                    continue
                }
                
                let flashcard = Flashcard(
                    fileName: fileName,
                    markdownContent: markdownContent,
                    deckID: deckID
                )
                flashcards.append(flashcard)
            } catch {
                // Skip files that fail to fetch
                print("⚠️ Failed to fetch \(fileName): \(error.localizedDescription)")
                continue
            }
        }
        
        return flashcards
    }
}

enum ContentFetchError: LocalizedError {
    case invalidURL(String)
    case fetchFailed(Int?, String?)
    case invalidData
    case networkError(Error)
    
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
        }
    }
}

// MARK: - Content Cache Manager

@Observable
final class ContentCache {
    private let cacheDirectory: URL
    private let fileManager = FileManager.default
    
    init() {
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cacheDir.appendingPathComponent("ContentCache", isDirectory: true)
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func cachePath(for key: String) -> URL {
        cacheDirectory.appendingPathComponent(key)
    }
    
    func save(data: Data, for key: String) throws {
        let fileURL = cachePath(for: key)
        try data.write(to: fileURL)
    }
    
    func load(for key: String) -> Data? {
        let fileURL = cachePath(for: key)
        return try? Data(contentsOf: fileURL)
    }
    
    func hasCached(key: String) -> Bool {
        let fileURL = cachePath(for: key)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    func clearCache() throws {
        try fileManager.removeItem(at: cacheDirectory)
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

