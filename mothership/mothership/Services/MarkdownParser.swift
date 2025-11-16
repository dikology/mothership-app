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
    let wikilinks: [MarkdownWikilink]
    let metadata: [String: String]
}

struct MarkdownSection {
    let level: Int // 1 for H1, 2 for H2, 3 for H3, etc.
    let title: String?
    let content: String
    let subsections: [MarkdownSection]
    let items: [MarkdownItem]
}

struct MarkdownItem {
    let title: String
    let content: String?
    let imagePath: String?
}

struct MarkdownWikilink {
    let link: String
    let displayText: String?
    let isEmbedded: Bool
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
        var images: [MarkdownImage] = []
        var videos: [MarkdownVideo] = []
        var animatedMedia: [MarkdownAnimatedMedia] = []
        var wikilinks: [MarkdownWikilink] = []
        var metadata: [String: String] = [:]
        
        // Parse frontmatter first
        let (frontmatter, contentWithoutFrontmatter) = parseFrontmatter(markdown)
        metadata = frontmatter
        
        let lines = contentWithoutFrontmatter.components(separatedBy: .newlines)
        
        // First pass: extract title and collect media/links
        var contentLines: [String] = []
        for line in lines {
            // Extract title (first H1)
            if line.hasPrefix("# ") && title.isEmpty {
                title = String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                contentLines.append(line)
                continue
            }
            
            // Extract videos
            if line.contains("![") && line.contains("youtube.com") {
                if let video = parseVideo(line: line) {
                    videos.append(video)
                }
            }
            
            // Extract animated media and images
            if line.contains("![") {
                if let animated = parseAnimatedMedia(line: line, basePath: basePath) {
                    animatedMedia.append(animated)
                } else if let image = parseImage(line: line, basePath: basePath) {
                    images.append(image)
                }
            }
            
            // Extract wikilinks
            let extractedLinks = parseWikilinks(line: line)
            wikilinks.append(contentsOf: extractedLinks)
            
            contentLines.append(line)
        }
        
        // Second pass: parse hierarchical sections
        let sections = parseSections(lines: contentLines)
        
        return MarkdownContent(
            title: title,
            sections: sections,
            images: images,
            videos: videos,
            animatedMedia: animatedMedia,
            wikilinks: wikilinks,
            metadata: metadata
        )
    }
    
    /// Parse sections with hierarchical structure
    private static func parseSections(lines: [String]) -> [MarkdownSection] {
        var sections: [MarkdownSection] = []
        var currentH2: SectionBuilder?
        var currentH3: SectionBuilder?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip title (H1) and empty lines at the start
            if trimmedLine.hasPrefix("# ") {
                continue
            }
            
            // H2 section
            if trimmedLine.hasPrefix("## ") {
                // Save previous H3 if exists
                if let h3 = currentH3, let h2 = currentH2 {
                    h2.subsections.append(h3.build())
                    currentH3 = nil
                }
                
                // Save previous H2
                if let h2 = currentH2 {
                    sections.append(h2.build())
                }
                
                let sectionTitle = String(trimmedLine.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                currentH2 = SectionBuilder(level: 2, title: sectionTitle)
                continue
            }
            
            // H3 subsection
            if trimmedLine.hasPrefix("### ") {
                // Save previous H3 if exists
                if let h3 = currentH3, let h2 = currentH2 {
                    h2.subsections.append(h3.build())
                }
                
                let sectionTitle = String(trimmedLine.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                currentH3 = SectionBuilder(level: 3, title: sectionTitle)
                continue
            }
            
            // H4+ subsections (treat as H3 for now)
            if trimmedLine.hasPrefix("#### ") {
                // Save previous H3 if exists
                if let h3 = currentH3, let h2 = currentH2 {
                    h2.subsections.append(h3.build())
                }
                
                let sectionTitle = String(trimmedLine.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                currentH3 = SectionBuilder(level: 4, title: sectionTitle)
                continue
            }
            
            // Horizontal rule - treat as section separator
            if trimmedLine.hasPrefix("---") {
                continue
            }
            
            // List items
            if trimmedLine.hasPrefix("- ") || trimmedLine.hasPrefix("* ") {
                let itemContent = String(trimmedLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                let processedContent = processInlineFormatting(itemContent)
                
                // Check if it's a flashcard format: "Question :: Answer"
                if processedContent.contains("::") {
                    let parts = processedContent.components(separatedBy: "::")
                    if parts.count >= 2 {
                        let question = parts[0].trimmingCharacters(in: .whitespaces)
                        let answer = parts[1...].joined(separator: "::").trimmingCharacters(in: .whitespaces)
                        let item = MarkdownItem(title: question, content: answer, imagePath: nil)
                        
                        if let h3 = currentH3 {
                            h3.items.append(item)
                        } else if let h2 = currentH2 {
                            h2.items.append(item)
                        }
                    }
                } else {
                    let item = MarkdownItem(title: processedContent, content: nil, imagePath: nil)
                    
                    if let h3 = currentH3 {
                        h3.items.append(item)
                    } else if let h2 = currentH2 {
                        h2.items.append(item)
                    }
                }
                continue
            }
            
            // Regular content (paragraphs)
            if !trimmedLine.isEmpty {
                let processedLine = processInlineFormatting(line)
                
                if let h3 = currentH3 {
                    h3.content.append(processedLine)
                } else if let h2 = currentH2 {
                    h2.content.append(processedLine)
                }
            }
        }
        
        // Save remaining sections
        if let h3 = currentH3, let h2 = currentH2 {
            h2.subsections.append(h3.build())
        }
        if let h2 = currentH2 {
            sections.append(h2.build())
        }
        
        return sections
    }
    
    /// Process inline formatting (bold, italic, wikilinks)
    private static func processInlineFormatting(_ text: String) -> String {
        var processed = text
        
        // Keep bold markers for display (**text**)
        // Keep emoji and special characters
        // Remove wikilink brackets but keep text
        processed = replaceWikilinksForDisplay(processed)
        
        return processed
    }
    
    /// Replace wikilinks with display text
    private static func replaceWikilinksForDisplay(_ text: String) -> String {
        var result = text
        
        // Handle embedded wikilinks: ![[link|display]] or ![[link]]
        let embeddedPattern = #"!\[\[([^\]|]+)(?:\|([^\]]+))?\]\]"#
        if let regex = try? NSRegularExpression(pattern: embeddedPattern, options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count))
            for match in matches.reversed() {
                if let displayRange = Range(match.range(at: 2), in: result) {
                    // Use display text if available
                    let displayText = String(result[displayRange])
                    if let matchRange = Range(match.range, in: result) {
                        result.replaceSubrange(matchRange, with: "[\(displayText)]")
                    }
                } else if let linkRange = Range(match.range(at: 1), in: result) {
                    // Use link text
                    let linkText = String(result[linkRange])
                    let displayText = (linkText as NSString).lastPathComponent
                    if let matchRange = Range(match.range, in: result) {
                        result.replaceSubrange(matchRange, with: "[\(displayText)]")
                    }
                }
            }
        }
        
        // Handle regular wikilinks: [[link|display]] or [[link]]
        let linkPattern = #"\[\[([^\]|]+)(?:\|([^\]]+))?\]\]"#
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count))
            for match in matches.reversed() {
                if let displayRange = Range(match.range(at: 2), in: result) {
                    // Use display text if available
                    let displayText = String(result[displayRange])
                    if let matchRange = Range(match.range, in: result) {
                        result.replaceSubrange(matchRange, with: displayText)
                    }
                } else if let linkRange = Range(match.range(at: 1), in: result) {
                    // Use link text
                    let linkText = String(result[linkRange])
                    let displayText = (linkText as NSString).lastPathComponent
                    if let matchRange = Range(match.range, in: result) {
                        result.replaceSubrange(matchRange, with: displayText)
                    }
                }
            }
        }
        
        return result
    }
    
    /// Parse wikilinks from a line
    private static func parseWikilinks(line: String) -> [MarkdownWikilink] {
        var wikilinks: [MarkdownWikilink] = []
        
        // Parse embedded wikilinks: ![[link|display]] or ![[link]]
        let embeddedPattern = #"!\[\[([^\]|]+)(?:\|([^\]]+))?\]\]"#
        if let regex = try? NSRegularExpression(pattern: embeddedPattern, options: []) {
            let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count))
            for match in matches {
                if let linkRange = Range(match.range(at: 1), in: line) {
                    let link = String(line[linkRange])
                    var displayText: String? = nil
                    
                    if let displayRange = Range(match.range(at: 2), in: line) {
                        displayText = String(line[displayRange])
                    }
                    
                    wikilinks.append(MarkdownWikilink(link: link, displayText: displayText, isEmbedded: true))
                }
            }
        }
        
        // Parse regular wikilinks: [[link|display]] or [[link]]
        let linkPattern = #"(?<!!)\[\[([^\]|]+)(?:\|([^\]]+))?\]\]"#
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: []) {
            let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count))
            for match in matches {
                if let linkRange = Range(match.range(at: 1), in: line) {
                    let link = String(line[linkRange])
                    var displayText: String? = nil
                    
                    if match.numberOfRanges > 2, let displayRange = Range(match.range(at: 2), in: line) {
                        displayText = String(line[displayRange])
                    }
                    
                    wikilinks.append(MarkdownWikilink(link: link, displayText: displayText, isEmbedded: false))
                }
            }
        }
        
        return wikilinks
    }
    
    /// Helper class to build sections
    private class SectionBuilder {
        let level: Int
        let title: String?
        var content: [String] = []
        var items: [MarkdownItem] = []
        var subsections: [MarkdownSection] = []
        
        init(level: Int, title: String?) {
            self.level = level
            self.title = title
        }
        
        func build() -> MarkdownSection {
            let contentString = content.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            return MarkdownSection(
                level: level,
                title: title,
                content: contentString,
                subsections: subsections,
                items: items
            )
        }
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

