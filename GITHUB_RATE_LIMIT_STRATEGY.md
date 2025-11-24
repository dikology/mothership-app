# GitHub Rate Limit Strategy Implementation

## Overview

This document describes the comprehensive rate limit handling, caching, and retry strategy implemented for GitHub API requests in the Mothership app. The solution works **without requiring GitHub tokens** at the MVP stage, making it suitable for open-source projects.

## Components

### 1. RateLimitTracker (`Services/RateLimitTracker.swift`)

Tracks GitHub API rate limit status by parsing HTTP response headers:
- `X-RateLimit-Remaining`: Number of requests remaining
- `X-RateLimit-Reset`: Unix timestamp when rate limit resets

**Features:**
- Singleton pattern for app-wide rate limit tracking
- Status checking: `ok`, `warning`, `rateLimited`
- User-friendly messages with time until reset
- Only processes rate limit headers from `api.github.com` (not `raw.githubusercontent.com`)
- Logs only significant events (rate limit exceeded, reset, low remaining)

**Usage:**
```swift
let status = RateLimitTracker.shared.checkRateLimit()
if status.isRateLimited {
    // Handle rate limit
}
```

### 2. RetryStrategy (`Services/RetryStrategy.swift`)

Implements exponential backoff with jitter for network retries.

**Features:**
- Configurable max retries, base delay, max delay
- Exponential backoff: `baseDelay * 2^(attempt-1)`
- Jitter (±20%) to prevent thundering herd
- Smart retry logic: retries network errors and 5xx errors, but not rate limits

**Presets:**
- `default`: 3 retries, 1s base delay, 30s max
- `aggressive`: 5 retries, 0.5s base delay, 60s max
- `conservative`: 2 retries, 2s base delay, 15s max

**Usage:**
```swift
let result = try await RetryStrategy.default.execute {
    // Network operation
} shouldRetry: { error in
    // Custom retry logic
    return true
}
```

### 3. Enhanced ContentCache (`Services/ContentFetcher.swift`)

Extended cache with metadata tracking:

**Features:**
- Cache metadata (last fetched timestamp)
- Stale detection (`isStale(key:maxAge:)`)
- Automatic cache cleanup
- Default expiration: 7 days

**Cache Keys:**
- Markdown: `markdown:{path}`
- Images: `image:{path}`
- Flashcards: `flashcards:{folderName}`

**Usage:**
```swift
// Check cache
if let cached = ContentCache.shared.load(for: "markdown:path/to/file.md") {
    // Use cached content
}

// Save to cache
try ContentCache.shared.save(data: data, for: "markdown:path/to/file.md")

// Check if stale
if ContentCache.shared.isStale(key: "markdown:path/to/file.md", maxAge: 3600) {
    // Refresh
}
```

### 4. Enhanced ContentFetcher (`Services/ContentFetcher.swift`)

All fetch methods now support:
- **Caching**: Check cache before network request
- **Rate limit detection**: Check rate limit before requests
- **Retry logic**: Automatic retries with exponential backoff
- **Fallback to cache**: Use cached content when rate limited

**Updated Methods:**

#### `fetchMarkdown(path:useCache:forceRefresh:)`
- Checks cache first (unless `forceRefresh`)
- Detects rate limits before request
- Retries on network/5xx errors
- Falls back to cache if rate limited

#### `fetchImage(path:useCache:forceRefresh:)`
- Same caching and retry logic as markdown
- Caches image data

#### `fetchFlashcardsFromFolder(folderName:deckID:useCache:forceRefresh:)`
- Caches entire flashcard deck
- Stops fetching files if rate limited mid-process
- Uses cached deck if rate limited
- Small delay (0.1s) between file fetches to be respectful

### 5. Enhanced FlashcardFetcher (`Services/FlashcardFetcher.swift`)

**Updated Methods:**

#### `fetchDeck(...)`
- Uses caching-aware `fetchFlashcardsFromFolder`
- Falls back to cached content on rate limit
- Preserves deck IDs and SRS progress

#### `fetchAllDecks(...)`
- Fetches all decks with error handling
- Continues fetching other decks if one fails
- Uses cached decks when rate limited
- Partial success: returns decks that succeeded

### 6. Enhanced Error Handling (`ContentFetchError`)

New error cases:
- `rateLimited(timeUntilReset:)`: Rate limit exceeded with reset time
- `cacheUnavailable`: Cache unavailable

**User-friendly messages:**
- Russian translations for all error types
- Time-based messages (hours/minutes until reset)
- Clear explanations of what went wrong

## Update Strategy

### Smart Refresh Pattern

1. **Initial Load**: Check cache first, fetch in background if stale
2. **Pull-to-Refresh**: Force refresh, but fallback to cache on error
3. **Background Refresh**: Check staleness, refresh if needed
4. **Rate Limited**: Always fallback to cache

### Cache Invalidation

- **Default**: 7 days
- **Manual**: User can clear cache in settings
- **Stale Detection**: Check `lastFetched` timestamp
- **Automatic Cleanup**: Remove stale entries

## Rate Limit Handling Flow

```
1. Check Rate Limit Status
   ├─ OK → Proceed with request
   ├─ Warning → Proceed but log warning
   └─ Rate Limited → Use cache or throw error

2. Make Request
   ├─ Success → Update rate limit tracker, cache result
   ├─ Rate Limited (403) → Update tracker, use cache
   ├─ Network Error → Retry with exponential backoff
   └─ 5xx Error → Retry with exponential backoff

3. On Rate Limit
   ├─ Check cache → Return cached content if available
   └─ No cache → Show user-friendly error message
```

## User Experience

### Error Messages

**Rate Limited:**
- "Превышен лимит запросов. Попробуйте снова через X часов/минут"
- Shows cached content if available
- Non-blocking: app continues to work with cached content

**Network Error:**
- "Ошибка сети. Проверьте подключение к интернету."
- Automatic retry with backoff
- Falls back to cache if available

**Other Errors:**
- Clear, localized error messages
- Actionable guidance for users

### Loading States

- Shows loading indicator during fetch
- Uses cached content immediately if available
- Background refresh doesn't block UI

## Best Practices

### 1. Cache-First Approach
Always check cache before making network requests:
```swift
if useCache && !forceRefresh {
    if let cached = cache.load(for: key) {
        return cached
    }
}
```

### 2. Rate Limit Awareness
Check rate limit before each request:
```swift
let status = rateLimitTracker.checkRateLimit()
if status.isRateLimited {
    // Use cache or throw error
}
```

### 3. Graceful Degradation
Always fallback to cache when possible:
```swift
catch ContentFetchError.rateLimited {
    if let cached = cache.load(for: key) {
        return cached // Use stale cache
    }
    throw error
}
```

### 4. Respectful API Usage
- Small delays between requests (0.1s for flashcard files)
- Stop fetching when rate limited
- Use cache aggressively

## Testing

### Test Scenarios

1. **Normal Operation**
   - Fetch content successfully
   - Cache is populated
   - Subsequent requests use cache

2. **Rate Limit**
   - Simulate rate limit (403 response)
   - Verify fallback to cache
   - Verify user-friendly error message

3. **Network Errors**
   - Simulate network failure
   - Verify retry logic
   - Verify exponential backoff

4. **Stale Cache**
   - Set cache to stale (>7 days)
   - Verify refresh on next request
   - Verify cache update

5. **Partial Failure**
   - Rate limit mid-fetch (flashcards)
   - Verify partial results returned
   - Verify cached content used

## Future Enhancements

### Post-MVP (with GitHub Token)

1. **Token Support**
   - Store token in Keychain
   - Use authenticated requests (5000/hour limit)
   - Fallback to unauthenticated if token fails

2. **Advanced Caching**
   - ETag support for conditional requests
   - Incremental updates
   - Cache versioning

3. **Background Refresh**
   - Background fetch when app launches
   - Silent updates
   - Push notifications for new content

4. **Analytics**
   - Track rate limit hits
   - Monitor cache hit rates
   - Measure fetch performance

## Configuration

### Cache Settings

```swift
// Default cache expiration
ContentCache.defaultMaxAge = 7 * 24 * 60 * 60 // 7 days

// Custom expiration per content type
let markdownMaxAge: TimeInterval = 24 * 60 * 60 // 1 day
let imageMaxAge: TimeInterval = 30 * 24 * 60 * 60 // 30 days
```

### Retry Settings

```swift
// Use default retry strategy
let strategy = RetryStrategy.default

// Or create custom
let customStrategy = RetryStrategy(
    maxRetries: 5,
    baseDelay: 1.0,
    maxDelay: 60.0,
    jitter: true
)
```

## Logging Strategy

### Best Practices

The implementation follows logging best practices:

1. **Structured Logging**: Uses `NSLog()` with `[Component]` prefixes for easy filtering
2. **Minimal Verbosity**: Only logs significant events:
   - Rate limit exceeded/reset
   - Low remaining requests (< 10)
   - Errors and failures
3. **No Header Dumping**: Rate limit headers are only processed for `api.github.com` responses, not `raw.githubusercontent.com` (CDN)
4. **Error Focus**: Logs focus on errors and warnings, not successful operations

### Log Format

```
[RateLimit] Rate limit exceeded. Remaining: 0
[RateLimit] Rate limit reset. Remaining: 60
[RateLimit] Low remaining requests: 5
[ContentFetcher] Failed to fetch 2 file(s) from folder: file1.md, file2.md
[FlashcardFetcher] Error fetching deck folder-name: Error description
[LearnView] Error refreshing decks: Error description
```

### Debugging

For debugging rate limit issues, check the `RateLimitTracker.shared.getDebugInfo()` method which provides current rate limit status information.

## Summary

This implementation provides:

✅ **Rate limit detection** - Tracks and responds to GitHub API limits  
✅ **Smart caching** - 7-day cache with metadata tracking  
✅ **Retry logic** - Exponential backoff with jitter  
✅ **Fallback to cache** - Always use cached content when rate limited  
✅ **User-friendly errors** - Clear, localized error messages  
✅ **No token required** - Works with unauthenticated requests (60/hour)  
✅ **Graceful degradation** - App continues to work with cached content  
✅ **Clean logging** - Minimal, structured logs focusing on errors and warnings  

The system is designed to be resilient, user-friendly, and respectful of GitHub's API limits while providing the best possible experience without requiring authentication tokens.

