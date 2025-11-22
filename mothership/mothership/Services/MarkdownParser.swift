//
//  MarkdownParser.swift
//  mothership
//
//  Parser for Obsidian-style markdown with images and videos
//  Refactored to preserve content order and improve structure
//

import Foundation

// MARK: - Data Models

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
    let contentBlocks: [ContentBlock] // Preserves order of content and items
    let subsections: [MarkdownSection]
    
    // Legacy computed properties for backward compatibility
    var content: String {
        contentBlocks
            .compactMap { block -> String? in
                if case .text(let text) = block {
                    return text
                }
                return nil
            }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var items: [MarkdownItem] {
        contentBlocks.flatMap { block -> [MarkdownItem] in
            if case .items(let items) = block {
                return items
            }
            return []
        }
    }
}

/// Represents a content block that preserves order
enum ContentBlock {
    case text(String)           // Regular paragraph/text content
    case items([MarkdownItem])  // List items (preserves grouping)
}

struct MarkdownItem {
    let title: String
    let content: String?
    let imagePath: String?
    let subitems: [MarkdownItem]
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

// MARK: - Main Parser

enum MarkdownParser {
    /// Parse markdown content into structured format
    static func parse(_ markdown: String, basePath: String = "") -> MarkdownContent {
        // Parse frontmatter first
        let (frontmatter, contentWithoutFrontmatter) = FrontmatterParser.parse(markdown)
        
        let lines = contentWithoutFrontmatter.components(separatedBy: .newlines)
        
        // Extract title and collect media/links
        let (title, contentLines) = TitleExtractor.extractTitle(from: lines)
        let (images, videos, animatedMedia, wikilinks) = MediaExtractor.extractMedia(
            from: contentLines,
            basePath: basePath
        )
        
        // Parse hierarchical sections with order preservation
        let sections = SectionParser.parseSections(lines: contentLines)
        
        return MarkdownContent(
            title: title,
            sections: sections,
            images: images,
            videos: videos,
            animatedMedia: animatedMedia,
            wikilinks: wikilinks,
            metadata: frontmatter
        )
    }
}

// MARK: - Frontmatter Parser

private enum FrontmatterParser {
    /// Parse YAML frontmatter from markdown
    static func parse(_ markdown: String) -> ([String: String], String) {
        var metadata: [String: String] = [:]
        var content = markdown
        
        guard markdown.hasPrefix("---\n") else {
            return (metadata, content)
        }
        
        let components = markdown.components(separatedBy: "---\n")
        guard components.count >= 3 else {
            return (metadata, content)
        }
        
        let frontmatterText = components[1]
        content = components[2...].joined(separator: "---\n")
        
        // Simple YAML parsing (key: value format)
        let frontmatterLines = frontmatterText.components(separatedBy: .newlines)
        for line in frontmatterLines {
            guard line.contains(":") else { continue }
            
            let parts = line.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else { continue }
            
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespaces)
            // Remove quotes if present
            let cleanValue = value.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            metadata[key] = cleanValue
        }
        
        return (metadata, content)
    }
}

// MARK: - Title Extractor

private enum TitleExtractor {
    /// Extract title (first H1) from lines
    static func extractTitle(from lines: [String]) -> (title: String, contentLines: [String]) {
        var title = ""
        var contentLines: [String] = []
        
        for line in lines {
            if line.hasPrefix("# ") && title.isEmpty {
                title = String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                contentLines.append(line)
            } else {
                contentLines.append(line)
            }
        }
        
        return (title, contentLines)
    }
}

// MARK: - Media Extractor

private enum MediaExtractor {
    /// Extract images, videos, animated media, and wikilinks from content lines
    static func extractMedia(
        from lines: [String],
        basePath: String
    ) -> (images: [MarkdownImage], videos: [MarkdownVideo], animatedMedia: [MarkdownAnimatedMedia], wikilinks: [MarkdownWikilink]) {
        var images: [MarkdownImage] = []
        var videos: [MarkdownVideo] = []
        var animatedMedia: [MarkdownAnimatedMedia] = []
        var wikilinks: [MarkdownWikilink] = []
        
        for line in lines {
            // Extract videos
            if line.contains("![") && line.contains("youtube.com") {
                if let video = VideoParser.parse(line: line) {
                    videos.append(video)
                }
            }
            
            // Extract animated media and images
            if line.contains("![") {
                if let animated = AnimatedMediaParser.parse(line: line, basePath: basePath) {
                    animatedMedia.append(animated)
                } else if let image = ImageParser.parse(line: line, basePath: basePath) {
                    images.append(image)
                }
            }
            
            // Extract wikilinks
            let extractedLinks = WikilinkParser.extract(from: line)
            wikilinks.append(contentsOf: extractedLinks)
        }
        
        return (images, videos, animatedMedia, wikilinks)
    }
}

// MARK: - Section Parser

private enum SectionParser {
    /// Parse sections with hierarchical structure, preserving content order
    static func parseSections(lines: [String]) -> [MarkdownSection] {
        var parser = SectionParserState()
        
        for line in lines {
            parser.processLine(line)
        }
        
        parser.finalize()
        return parser.sections
    }
}

// MARK: - Section Parser State

private struct SectionParserState {
    var sections: [MarkdownSection] = []
    var currentH2: SectionBuilder?
    var currentH3: SectionBuilder?
    var prefaceSection: SectionBuilder?
    var listBuffer: [String] = []
    
    mutating func processLine(_ line: String) {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        // Skip title (H1) - already extracted
        if trimmedLine.hasPrefix("# ") {
            return
        }
        
        // Handle section headers
        if trimmedLine.hasPrefix("## ") {
            handleH2Section(line: trimmedLine)
            return
        }
        
        if trimmedLine.hasPrefix("### ") {
            handleH3Section(line: trimmedLine)
            return
        }
        
        if trimmedLine.hasPrefix("#### ") {
            handleH4Section(line: trimmedLine)
            return
        }
        
        // Handle horizontal rule
        if trimmedLine.hasPrefix("---") {
            return
        }
        
        // Handle list items
        if ListItemParser.isListItem(line) || trimmedLine.hasPrefix(">") {
            listBuffer.append(line)
            return
        }
        
        // Handle regular content
        if !trimmedLine.isEmpty {
            flushPendingListItems()
            addContentLine(line)
        } else if !listBuffer.isEmpty && trimmedLine.isEmpty {
            // Empty line might end a list block, but keep it in buffer
            listBuffer.append(line)
        }
    }
    
    mutating func handleH2Section(line: String) {
        flushPendingListItems()
        saveCurrentH3()
        saveCurrentH2()
        
        let sectionTitle = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        currentH2 = SectionBuilder(level: 2, title: sectionTitle)
    }
    
    mutating func handleH3Section(line: String) {
        flushPendingListItems()
        saveCurrentH3()
        
        let sectionTitle = String(line.dropFirst(4)).trimmingCharacters(in: .whitespaces)
        currentH3 = SectionBuilder(level: 3, title: sectionTitle)
    }
    
    mutating func handleH4Section(line: String) {
        flushPendingListItems()
        saveCurrentH3()
        
        let sectionTitle = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
        currentH3 = SectionBuilder(level: 4, title: sectionTitle)
    }
    
    mutating func flushPendingListItems() {
        guard !listBuffer.isEmpty else { return }
        
        let items = ListItemParser.parse(listBuffer)
        addItems(items)
        listBuffer.removeAll()
    }
    
    mutating func addContentLine(_ line: String) {
        let processedLine = InlineFormatter.process(line)
        
        if let h3 = currentH3 {
            h3.addContent(processedLine)
        } else if let h2 = currentH2 {
            h2.addContent(processedLine)
        } else {
            if prefaceSection == nil {
                prefaceSection = SectionBuilder(level: 1, title: nil)
            }
            prefaceSection?.addContent(processedLine)
        }
    }
    
    mutating func addItems(_ items: [MarkdownItem]) {
        if let h3 = currentH3 {
            h3.addItems(items)
        } else if let h2 = currentH2 {
            h2.addItems(items)
        } else {
            if prefaceSection == nil {
                prefaceSection = SectionBuilder(level: 1, title: nil)
            }
            prefaceSection?.addItems(items)
        }
    }
    
    mutating func saveCurrentH3() {
        guard let h3 = currentH3 else { return }
        
        if let h2 = currentH2 {
            h2.subsections.append(h3.build())
        } else {
            sections.append(h3.build())
        }
        currentH3 = nil
    }
    
    mutating func saveCurrentH2() {
        guard let h2 = currentH2 else { return }
        sections.append(h2.build())
        currentH2 = nil
    }
    
    mutating func finalize() {
        flushPendingListItems()
        saveCurrentH3()
        saveCurrentH2()
        
        if let preface = prefaceSection {
            sections.insert(preface.build(), at: 0)
        }
    }
}

// MARK: - Section Builder

private class SectionBuilder {
    let level: Int
    let title: String?
    var contentBlocks: [ContentBlock] = []
    var subsections: [MarkdownSection] = []
    
    init(level: Int, title: String?) {
        self.level = level
        self.title = title
    }
    
    func addContent(_ line: String) {
        // If last block is text, append to it with newline; otherwise create new text block
        if case .text(let existingText) = contentBlocks.last {
            // Merge with existing text block, preserving newlines
            contentBlocks[contentBlocks.count - 1] = .text(existingText + "\n" + line)
        } else {
            // Create new text block
            contentBlocks.append(.text(line))
        }
    }
    
    func addItems(_ items: [MarkdownItem]) {
        guard !items.isEmpty else { return }
        contentBlocks.append(.items(items))
    }
    
    func build() -> MarkdownSection {
        return MarkdownSection(
            level: level,
            title: title,
            contentBlocks: contentBlocks,
            subsections: subsections
        )
    }
}

// MARK: - List Item Parser

private enum ListItemParser {
    /// Check if a line is a list item
    static func isListItem(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("- ") ||
               trimmed.hasPrefix("* ") ||
               trimmed.hasPrefix("+ ") ||
               trimmed.hasPrefix("- [ ] ") ||
               trimmed.hasPrefix("- [x] ") ||
               trimmed.hasPrefix("- [X] ")
    }
    
    /// Parse list items with nesting support
    static func parse(_ lines: [String]) -> [MarkdownItem] {
        struct ListItemBuilder {
            let indentLevel: Int
            var title: String
            var contentLines: [String] = []
            var subitems: [MarkdownItem] = []
            
            func build() -> MarkdownItem {
                let content = contentLines.isEmpty
                    ? nil
                    : contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                return MarkdownItem(
                    title: title,
                    content: content,
                    imagePath: nil,
                    subitems: subitems
                )
            }
        }
        
        var items: [MarkdownItem] = []
        var stack: [ListItemBuilder] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines and blockquotes
            if trimmed.isEmpty || trimmed.hasPrefix(">") {
                continue
            }
            
            // Detect indentation level (count leading spaces)
            let leadingSpaces = line.prefix(while: { $0 == " " }).count
            let indentLevel = leadingSpaces / 2 // Assume 2 spaces per indent level
            
            if isListItem(line) {
                // Extract list item content
                var itemText = trimmed
                
                // Remove list markers
                if itemText.hasPrefix("- [ ] ") {
                    itemText = String(itemText.dropFirst(6))
                } else if itemText.hasPrefix("- [x] ") || itemText.hasPrefix("- [X] ") {
                    itemText = String(itemText.dropFirst(6))
                } else if itemText.hasPrefix("- ") || itemText.hasPrefix("* ") || itemText.hasPrefix("+ ") {
                    itemText = String(itemText.dropFirst(2))
                }
                
                itemText = itemText.trimmingCharacters(in: .whitespaces)
                let processedText = InlineFormatter.process(itemText)
                
                // Create new item builder
                let newItem = ListItemBuilder(indentLevel: indentLevel, title: processedText)
                
                // Handle nesting based on indentation
                while !stack.isEmpty && stack.last!.indentLevel >= indentLevel {
                    let completed = stack.removeLast()
                    if stack.isEmpty {
                        items.append(completed.build())
                    } else {
                        stack[stack.count - 1].subitems.append(completed.build())
                    }
                }
                
                stack.append(newItem)
            } else if !stack.isEmpty {
                // This is a continuation line (content) for the current item
                let processedLine = InlineFormatter.process(trimmed)
                stack[stack.count - 1].contentLines.append(processedLine)
            }
        }
        
        // Flush remaining items in stack
        while !stack.isEmpty {
            let completed = stack.removeLast()
            if stack.isEmpty {
                items.append(completed.build())
            } else {
                stack[stack.count - 1].subitems.append(completed.build())
            }
        }
        
        return items
    }
}

// MARK: - Inline Formatter

private enum InlineFormatter {
    /// Process inline formatting (bold, italic, wikilinks)
    /// Note: Bold text (**text**) is kept as-is for UI layer parsing
    static func process(_ text: String) -> String {
        return replaceWikilinksForDisplay(text)
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
                    let displayText = String(result[displayRange])
                    if let matchRange = Range(match.range, in: result) {
                        result.replaceSubrange(matchRange, with: "[\(displayText)]")
                    }
                } else if let linkRange = Range(match.range(at: 1), in: result) {
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
                    let displayText = String(result[displayRange])
                    if let matchRange = Range(match.range, in: result) {
                        result.replaceSubrange(matchRange, with: displayText)
                    }
                } else if let linkRange = Range(match.range(at: 1), in: result) {
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
}

// MARK: - Wikilink Parser

private enum WikilinkParser {
    /// Extract wikilinks from a line
    static func extract(from line: String) -> [MarkdownWikilink] {
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
}

// MARK: - Image Parser

private enum ImageParser {
    static func parse(line: String, basePath: String = "") -> MarkdownImage? {
        // Parse Obsidian format: ![[image.png]]
        if let match = line.range(of: #"!\[\[([^\]]+)\]\]"#, options: .regularExpression) {
            let imagePath = String(line[match])
                .replacingOccurrences(of: "![[", with: "")
                .replacingOccurrences(of: "]]", with: "")
            let resolvedPath = PathResolver.resolve(imagePath, basePath: basePath)
            return MarkdownImage(path: resolvedPath, alt: nil, caption: nil)
        }
        
        // Parse standard markdown: ![alt](path)
        let markdownImagePattern = #"!\[([^\]]*)\]\(([^\)]+)\)"#
        guard let regex = try? NSRegularExpression(pattern: markdownImagePattern, options: []),
              let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) else {
            return nil
        }
        
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
        
        guard !path.isEmpty else { return nil }
        
        let resolvedPath = PathResolver.resolve(path, basePath: basePath)
        return MarkdownImage(path: resolvedPath, alt: alt, caption: nil)
    }
}

// MARK: - Animated Media Parser

private enum AnimatedMediaParser {
    static func parse(line: String, basePath: String = "") -> MarkdownAnimatedMedia? {
        let animatedExtensions = ["gif", "mp4", "webm"]
        
        // Parse Obsidian format: ![[animation.gif]]
        if let match = line.range(of: #"!\[\[([^\]]+)\]\]"#, options: .regularExpression) {
            let mediaPath = String(line[match])
                .replacingOccurrences(of: "![[", with: "")
                .replacingOccurrences(of: "]]", with: "")
            let lowercased = mediaPath.lowercased()
            
            for ext in animatedExtensions {
                if lowercased.hasSuffix(".\(ext)") {
                    let resolvedPath = PathResolver.resolve(mediaPath, basePath: basePath)
                    let type = MarkdownAnimatedMedia.AnimatedMediaType.from(extension: ext)
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
        guard let regex = try? NSRegularExpression(pattern: markdownMediaPattern, options: []),
              let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) else {
            return nil
        }
        
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
        
        guard !path.isEmpty else { return nil }
        
        let lowercased = path.lowercased()
        for ext in animatedExtensions {
            if lowercased.hasSuffix(".\(ext)") {
                let resolvedPath = PathResolver.resolve(path, basePath: basePath)
                let type = MarkdownAnimatedMedia.AnimatedMediaType.from(extension: ext)
                return MarkdownAnimatedMedia(
                    url: resolvedPath,
                    path: resolvedPath,
                    type: type,
                    caption: caption
                )
            }
        }
        
        return nil
    }
}

extension MarkdownAnimatedMedia.AnimatedMediaType {
    static func from(extension ext: String) -> Self {
        switch ext {
        case "gif": return .gif
        case "mp4": return .mp4
        case "webm": return .webm
        default: return .gif
        }
    }
}

// MARK: - Video Parser

private enum VideoParser {
    static func parse(line: String) -> MarkdownVideo? {
        // Parse format: ![video](https://www.youtube.com/watch?v=VIDEO_ID)
        // or ![video](https://youtu.be/VIDEO_ID)
        let youtubePattern = #"!\[([^\]]*)\]\((https?://(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]+))\)"#
        
        guard let regex = try? NSRegularExpression(pattern: youtubePattern, options: []),
              let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) else {
            return nil
        }
        
        guard let urlRange = Range(match.range(at: 2), in: line),
              let videoIDRange = Range(match.range(at: 3), in: line) else {
            return nil
        }
        
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

// MARK: - Path Resolver

private enum PathResolver {
    /// Resolve relative image/media paths relative to markdown file location
    static func resolve(_ path: String, basePath: String) -> String {
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
        return (baseDir as NSString).appendingPathComponent(path)
    }
}
