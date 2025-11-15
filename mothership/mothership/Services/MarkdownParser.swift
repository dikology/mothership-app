//
//  MarkdownParser.swift
//  mothership
//
//  Parser for Obsidian-style markdown with images and videos
//

import Foundation

struct MarkdownContent {
    let title: String
    let sections: [MarkdownSection]
    let images: [MarkdownImage]
    let videos: [MarkdownVideo]
    let animatedMedia: [MarkdownAnimatedMedia]
    let metadata: [String: String]
}

struct MarkdownSection {
    let title: String?
    let content: String
    let items: [MarkdownItem]
}

struct MarkdownItem {
    let title: String
    let content: String?
    let imagePath: String?
}

struct MarkdownImage {
    let path: String
    let alt: String?
    let caption: String?
}

struct MarkdownVideo {
    let url: String
    let videoID: String
    let title: String?
}

struct MarkdownAnimatedMedia {
    let url: String
    let path: String
    let type: AnimatedMediaType
    let caption: String?
    
    enum AnimatedMediaType: String {
        case gif
        case mp4
        case webm
    }
}

enum MarkdownParser {
    /// Parse markdown content into structured format
    static func parse(_ markdown: String, basePath: String = "") -> MarkdownContent {
        var title = ""
        var sections: [MarkdownSection] = []
        var images: [MarkdownImage] = []
        var videos: [MarkdownVideo] = []
        var animatedMedia: [MarkdownAnimatedMedia] = []
        var metadata: [String: String] = [:]
        
        // Parse frontmatter first
        let (frontmatter, contentWithoutFrontmatter) = parseFrontmatter(markdown)
        metadata = frontmatter
        
        let lines = contentWithoutFrontmatter.components(separatedBy: .newlines)
        var currentSection: MarkdownSection?
        var currentItems: [MarkdownItem] = []
        var currentContent: [String] = []
        
        for line in lines {
            
            // Parse title (first H1)
            if line.hasPrefix("# ") && title.isEmpty {
                title = String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                continue
            }
            
            // Parse section headers (H2, H3)
            if line.hasPrefix("## ") {
                // Save previous section
                if let section = currentSection {
                    sections.append(section)
                }
                
                let sectionTitle = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                currentSection = MarkdownSection(
                    title: sectionTitle,
                    content: currentContent.joined(separator: "\n"),
                    items: currentItems
                )
                currentContent = []
                currentItems = []
                continue
            }
            
            // Parse videos: ![video](https://www.youtube.com/watch?v=...)
            if line.contains("![") && line.contains("youtube.com") {
                if let video = parseVideo(line: line) {
                    videos.append(video)
                }
                continue
            }
            
            // Parse animated media (GIFs, MP4s): ![[animation.gif]] or ![alt](path.mp4)
            if line.contains("![") {
                if let animated = parseAnimatedMedia(line: line, basePath: basePath) {
                    animatedMedia.append(animated)
                    continue
                }
                
                // Parse regular images: ![[image.png]] or ![alt](path)
                if let image = parseImage(line: line, basePath: basePath) {
                    images.append(image)
                }
            }
            
            // Parse list items (for flashcards)
            if line.hasPrefix("- ") || line.hasPrefix("* ") {
                let itemContent = String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                // Check if it's a flashcard format: "Question :: Answer"
                if itemContent.contains("::") {
                    let parts = itemContent.components(separatedBy: "::")
                    if parts.count >= 2 {
                        let question = parts[0].trimmingCharacters(in: .whitespaces)
                        let answer = parts[1...].joined(separator: "::").trimmingCharacters(in: .whitespaces)
                        currentItems.append(MarkdownItem(title: question, content: answer, imagePath: nil))
                    }
                } else {
                    currentItems.append(MarkdownItem(title: itemContent, content: nil, imagePath: nil))
                }
            } else {
                currentContent.append(line)
            }
        }
        
        // Save last section
        if let section = currentSection {
            sections.append(section)
        }
        
        return MarkdownContent(
            title: title,
            sections: sections,
            images: images,
            videos: videos,
            animatedMedia: animatedMedia,
            metadata: metadata
        )
    }
    
    // MARK: - Frontmatter Parsing
    
    /// Parse YAML frontmatter from markdown
    private static func parseFrontmatter(_ markdown: String) -> ([String: String], String) {
        var metadata: [String: String] = [:]
        var content = markdown
        
        // Check if frontmatter exists
        if markdown.hasPrefix("---\n") {
            let components = markdown.components(separatedBy: "---\n")
            if components.count >= 3 {
                let frontmatterText = components[1]
                content = components[2...].joined(separator: "---\n")
                
                // Simple YAML parsing (key: value format)
                let frontmatterLines = frontmatterText.components(separatedBy: .newlines)
                for line in frontmatterLines {
                    if line.contains(":") {
                        let parts = line.split(separator: ":", maxSplits: 1)
                        if parts.count == 2 {
                            let key = parts[0].trimmingCharacters(in: .whitespaces)
                            let value = parts[1].trimmingCharacters(in: .whitespaces)
                            // Remove quotes if present
                            let cleanValue = value.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                            metadata[key] = cleanValue
                        }
                    }
                }
            }
        }
        
        return (metadata, content)
    }
    
    private static func parseImage(line: String, basePath: String = "") -> MarkdownImage? {
        // Parse Obsidian format: ![[image.png]]
        if let match = line.range(of: #"!\[\[([^\]]+)\]\]"#, options: .regularExpression) {
            let imagePath = String(line[match]).replacingOccurrences(of: "![[", with: "").replacingOccurrences(of: "]]", with: "")
            let resolvedPath = resolvePath(imagePath, basePath: basePath)
            return MarkdownImage(path: resolvedPath, alt: nil, caption: nil)
        }
        
        // Parse standard markdown: ![alt](path)
        let markdownImagePattern = #"!\[([^\]]*)\]\(([^\)]+)\)"#
        if let regex = try? NSRegularExpression(pattern: markdownImagePattern, options: []),
           let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
            
            var alt: String? = nil
            var path: String = ""
            
            if match.range(at: 1).location != NSNotFound,
               let altRange = Range(match.range(at: 1), in: line) {
                let altText = String(line[altRange])
                if !altText.isEmpty {
                    alt = altText
                }
            }
            
            if match.range(at: 2).location != NSNotFound,
               let pathRange = Range(match.range(at: 2), in: line) {
                path = String(line[pathRange])
            }
            
            if !path.isEmpty {
                let resolvedPath = resolvePath(path, basePath: basePath)
                return MarkdownImage(path: resolvedPath, alt: alt, caption: nil)
            }
        }
        
        return nil
    }
    
    private static func parseAnimatedMedia(line: String, basePath: String = "") -> MarkdownAnimatedMedia? {
        // Check for GIF, MP4, or WebM extensions
        let animatedExtensions = ["gif", "mp4", "webm"]
        
        // Parse Obsidian format: ![[animation.gif]]
        if let match = line.range(of: #"!\[\[([^\]]+)\]\]"#, options: .regularExpression) {
            let mediaPath = String(line[match]).replacingOccurrences(of: "![[", with: "").replacingOccurrences(of: "]]", with: "")
            let lowercased = mediaPath.lowercased()
            
            for ext in animatedExtensions {
                if lowercased.hasSuffix(".\(ext)") {
                    let resolvedPath = resolvePath(mediaPath, basePath: basePath)
                    let type: MarkdownAnimatedMedia.AnimatedMediaType = {
                        switch ext {
                        case "gif": return .gif
                        case "mp4": return .mp4
                        case "webm": return .webm
                        default: return .gif
                        }
                    }()
                    return MarkdownAnimatedMedia(
                        url: resolvedPath,
                        path: resolvedPath,
                        type: type,
                        caption: nil
                    )
                }
            }
        }
        
        // Parse standard markdown: ![alt](path.gif) or ![alt](path.mp4)
        let markdownMediaPattern = #"!\[([^\]]*)\]\(([^\)]+)\)"#
        if let regex = try? NSRegularExpression(pattern: markdownMediaPattern, options: []),
           let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
            
            var caption: String? = nil
            var path: String = ""
            
            if match.range(at: 1).location != NSNotFound,
               let captionRange = Range(match.range(at: 1), in: line) {
                let captionText = String(line[captionRange])
                if !captionText.isEmpty {
                    caption = captionText
                }
            }
            
            if match.range(at: 2).location != NSNotFound,
               let pathRange = Range(match.range(at: 2), in: line) {
                path = String(line[pathRange])
            }
            
            if !path.isEmpty {
                let lowercased = path.lowercased()
                for ext in animatedExtensions {
                    if lowercased.hasSuffix(".\(ext)") {
                        let resolvedPath = resolvePath(path, basePath: basePath)
                        let type: MarkdownAnimatedMedia.AnimatedMediaType = {
                            switch ext {
                            case "gif": return .gif
                            case "mp4": return .mp4
                            case "webm": return .webm
                            default: return .gif
                            }
                        }()
                        return MarkdownAnimatedMedia(
                            url: resolvedPath,
                            path: resolvedPath,
                            type: type,
                            caption: caption
                        )
                    }
                }
            }
        }
        
        return nil
    }
    
    /// Resolve relative image/media paths relative to markdown file location
    private static func resolvePath(_ path: String, basePath: String) -> String {
        // If path is already absolute (starts with http:// or https://), return as-is
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return path
        }
        
        // If basePath is empty, return path as-is
        guard !basePath.isEmpty else {
            return path
        }
        
        // If path is already absolute (starts with /), return as-is
        if path.hasPrefix("/") {
            return path
        }
        
        // Resolve relative path
        let baseDir = (basePath as NSString).deletingLastPathComponent
        let resolved = (baseDir as NSString).appendingPathComponent(path)
        return resolved
    }
    
    private static func parseVideo(line: String) -> MarkdownVideo? {
        // Parse format: ![video](https://www.youtube.com/watch?v=VIDEO_ID)
        // or ![video](https://youtu.be/VIDEO_ID)
        let youtubePattern = #"!\[([^\]]*)\]\((https?://(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]+))\)"#
        
        if let regex = try? NSRegularExpression(pattern: youtubePattern, options: []),
           let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
            
            // Extract video URL
            if let urlRange = Range(match.range(at: 2), in: line),
               let videoIDRange = Range(match.range(at: 3), in: line) {
                let url = String(line[urlRange])
                let videoID = String(line[videoIDRange])
                
                // Extract title if available
                var title: String? = nil
                if match.range(at: 1).location != NSNotFound,
                   let titleRange = Range(match.range(at: 1), in: line) {
                    let titleText = String(line[titleRange])
                    if !titleText.isEmpty && titleText != "video" {
                        title = titleText
                    }
                }
                
                return MarkdownVideo(url: url, videoID: videoID, title: title)
            }
        }
        
        return nil
    }
    
}

