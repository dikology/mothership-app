//
//  MarkdownParserTests.swift
//  MarkdownParserTests
//
//  Swift Testing version - avoids XCTest @Observable memory issues
//

import Testing
@testable import mothership

struct MarkdownParserTests {
    
    // MARK: - Title Parsing Tests
    
    @Test("Parse H1 header as title")
    func parseTitle_H1Header() async throws {
        // Given: Markdown with H1 title
        let markdown = """
        # Main Title
        
        Some content here.
        """
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Title should be extracted
        #expect(result.title == "Main Title")
    }
    
    @Test("Handle markdown without H1")
    func parseTitle_NoH1() async throws {
        // Given: Markdown without H1
        let markdown = """
        ## Section Title
        
        Some content.
        """
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Title should be empty
        #expect(result.title.isEmpty)
    }
    
    @Test("Take first H1 when multiple exist")
    func parseTitle_MultipleH1_TakesFirst() async throws {
        // Given: Markdown with multiple H1s
        let markdown = """
        # First Title
        
        ## Section
        
        # Second Title
        """
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Only first H1 should be used as title
        #expect(result.title == "First Title")
    }
    
    // MARK: - Section Parsing Tests
    
    @Test("Parse H2 sections")
    func parseSections_H2Sections() async throws {
        // Given: Markdown with H2 sections
        let markdown = """
        # Title
        
        ## First Section
        Content of first section.
        
        ## Second Section
        Content of second section.
        """
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Two H2 sections should be parsed
        #expect(result.sections.count == 2)
        #expect(result.sections[0].title == "First Section")
        #expect(result.sections[0].level == 2)
        #expect(result.sections[0].content.contains("Content of first section"))
        #expect(result.sections[1].title == "Second Section")
    }
    
    // MARK: - Inline Formatting Tests
    
    @Test("Preserve bold text markers")
    func inlineFormatting_BoldText() async throws {
        // Given: Markdown with bold text in list
        let markdown = """
        ### Section
        
        - Item with **bold text** inside
        """
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Bold markers should be preserved for display
        #expect(!result.sections.isEmpty)
        #expect(!result.sections[0].items.isEmpty)
        #expect(result.sections[0].items[0].title.contains("**bold text**"))
    }
    
    @Test("Extract wikilinks")
    func inlineFormatting_Wikilinks() async throws {
        // Given: Markdown with wikilinks
        let markdown = """
        ### Section
        
        See [[Other Page]] for more info.
        See also [[path/to/page|Custom Display Text]].
        """
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Wikilinks should be extracted
        #expect(result.wikilinks.count == 2)
        #expect(result.wikilinks[0].link == "Other Page")
        #expect(result.wikilinks[0].displayText == nil)
        #expect(result.wikilinks[1].link == "path/to/page")
        #expect(result.wikilinks[1].displayText == "Custom Display Text")
    }
    
    // MARK: - List Item Parsing Tests
    
    @Test("Parse flat list items")
    func parseListItems_FlatList() async throws {
        // Given: Markdown with flat list
        let markdown = """
        ### Section
        
        - Item 1
        - Item 2
        - Item 3
        """
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Three flat list items should be parsed
        #expect(result.sections.count == 1)
        #expect(result.sections[0].items.count == 3)
        #expect(result.sections[0].items[0].title == "Item 1")
        #expect(result.sections[0].items[1].title == "Item 2")
        #expect(result.sections[0].items[2].title == "Item 3")
        #expect(result.sections[0].items[0].subitems.isEmpty)
    }
    
    @Test("Parse nested list items")
    func parseListItems_NestedList() async throws {
        // Given: Markdown with nested list (2 spaces indentation)
        let markdown = """
        ### Section
        
        - Parent Item 1
          - Child Item 1.1
          - Child Item 1.2
        - Parent Item 2
          - Child Item 2.1
        """
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Nested structure should be preserved
        #expect(result.sections[0].items.count == 2)
        
        let parent1 = result.sections[0].items[0]
        #expect(parent1.title == "Parent Item 1")
        #expect(parent1.subitems.count == 2)
        #expect(parent1.subitems[0].title == "Child Item 1.1")
        #expect(parent1.subitems[1].title == "Child Item 1.2")
        
        let parent2 = result.sections[0].items[1]
        #expect(parent2.title == "Parent Item 2")
        #expect(parent2.subitems.count == 1)
        #expect(parent2.subitems[0].title == "Child Item 2.1")
    }
    
    // MARK: - Edge Cases
    
    @Test("Handle empty markdown")
    func emptyMarkdown() async throws {
        // Given: Empty markdown
        let markdown = ""
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Should return empty structure without crashing
        #expect(result.title.isEmpty)
        #expect(result.sections.isEmpty)
        #expect(result.images.isEmpty)
        #expect(result.videos.isEmpty)
    }
    
    @Test("Handle special characters (Cyrillic, emojis)")
    func markdownWithSpecialCharacters() async throws {
        // Given: Markdown with special characters
        let markdown = """
        ### Тестовая секция 🚢
        
        - Пункт 1 ⚓
        - Пункт 2 🌊
        """
        
        // When: Parsing the markdown
        let result = MarkdownParser.parse(markdown)
        
        // Then: Special characters should be preserved
        #expect(result.sections[0].title!.contains("🚢"))
        #expect(result.sections[0].items[0].title.contains("⚓"))
        #expect(result.sections[0].items[1].title.contains("🌊"))
    }
}

