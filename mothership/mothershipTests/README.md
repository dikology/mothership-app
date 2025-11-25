# Mothership Tests

This directory contains unit tests for the Mothership app.

## Running Tests

### From Xcode
1. Open `mothership.xcodeproj` in Xcode
2. Press `⌘+U` to run all tests
3. Or use the Test Navigator (⌘+6) to run specific tests

### From Terminal
```bash
cd mothership
xcodebuild test -scheme mothership -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Files

### MarkdownParserTests.swift
Comprehensive tests for the MarkdownParser to prevent regression during refactoring.

**Test Coverage:**
- ✅ Title parsing (H1 headers)
- ✅ Section parsing (H2, H3, H4)
- ✅ Flat list items
- ✅ **Nested list items** (multi-level, with indentation)
- ✅ List items with content/descriptions
- ✅ Checkbox list items
- ✅ Real-world complex examples (e.g., аптечка.md structure)
- ✅ Frontmatter parsing (YAML)
- ✅ Inline formatting (bold text)
- ✅ Wikilinks (with and without display text)
- ✅ Images (Obsidian and standard markdown)
- ✅ Animated media (GIF, MP4, WebM)
- ✅ Videos (YouTube)
- ✅ Edge cases (empty markdown, whitespace, special characters)
- ✅ Performance tests

**Key Tests for New Features:**
- `testParseListItems_NestedList`: Validates 2-level nesting
- `testParseListItems_DeeplyNestedList`: Validates 3+ level nesting
- `testParseListItems_RealWorldExample`: Tests actual аптечка.md structure
- `testParseListItems_WithContent`: Tests list items with descriptions

### CharterTests.swift
Tests for the Charter model including date logic and encoding/decoding.

### CharterStoreTests.swift
Tests for Charter storage and retrieval.

### ChecklistStoreTests.swift
Tests for Checklist storage operations.

### ContentCacheTests.swift
Tests for ContentCache - caching strategy and staleness detection.

**Test Coverage:**
- ✅ Save and load operations
- ✅ Cache existence detection
- ✅ Last fetched timestamp tracking
- ✅ Staleness detection
- ✅ Cache clearing (all and stale only)
- ✅ Special character handling in keys

### RateLimitTrackerTests.swift
Tests for RateLimitTracker - rate limit detection and tracking.

**Test Coverage:**
- ✅ Initialization with defaults
- ✅ Updates from API responses
- ✅ Ignores CDN responses (raw.githubusercontent.com)
- ✅ Rate limit detection when remaining = 0
- ✅ Warning when remaining < 10
- ✅ Time until reset calculation
- ✅ Reset functionality
- ✅ User message formatting

### RetryStrategyTests.swift
Tests for RetryStrategy - exponential backoff and retry logic.

**Test Coverage:**
- ✅ Success on first attempt
- ✅ Retries on transient errors
- ✅ No retry on non-retriable errors
- ✅ Respects max retries
- ✅ Exponential backoff calculation
- ✅ Delay capping at maxDelay
- ✅ Jitter addition (±20%)
- ✅ Preset configurations (default, aggressive, conservative)

## Best Practices

### When Refactoring MarkdownParser
1. Run all tests before starting: `⌘+U`
2. Make your changes incrementally
3. Run tests after each significant change
4. If a test fails, understand why before modifying the test
5. Add new tests for new functionality
6. Keep tests focused and independent

### Test Naming Convention
- Use descriptive names: `test<WhatIsBeingTested>_<Scenario>`
- Example: `testParseListItems_NestedList`

### Test Structure (AAA Pattern)
```swift
func testSomething() {
    // Given: Setup test data and context
    let markdown = "..."
    
    // When: Execute the action being tested
    let result = MarkdownParser.parse(markdown)
    
    // Then: Assert the expected outcome
    XCTAssertEqual(result.sections.count, 1)
}
```

## Adding New Tests

When adding new functionality to MarkdownParser:

1. Write the test first (TDD approach recommended)
2. Run the test and see it fail
3. Implement the feature
4. Run the test and see it pass
5. Refactor if needed, keeping tests green

## Performance Testing

The `testParsePerformance_LargeDocument` test measures parsing performance for large documents. If you make changes that significantly impact performance, investigate and optimize.

## CI/CD

These tests should be run automatically on:
- Every commit to main branch
- Every pull request
- Before releases

Ensure all tests pass before merging.
