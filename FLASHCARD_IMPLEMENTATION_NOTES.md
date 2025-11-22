# Flashcard System Implementation Notes

## Overview

This document notes the implementation of the COLREGS Learning Module with Flashcard System and Spaced Repetition (SRS) for the Mothership app.

## Implementation Summary

### ✅ Completed Features

1. **Flashcard Models** (`Core/Models/LearningContent.swift`)
   - `Flashcard`: Stores markdown content with SRS metadata
   - `FlashcardDeck`: Represents a collection of flashcards from a GitHub folder
   - `ReviewQuality`: Enum for rating card difficulty

2. **Spaced Repetition Service** (`Services/SpacedRepetitionService.swift`)
   - SM-2 algorithm implementation
   - Calculates intervals and ease factors
   - Tracks review statistics

3. **Flashcard Store** (`Core/Stores/FlashcardStore.swift`)
   - Manages flashcards and decks
   - Persists data to UserDefaults
   - Provides review statistics

4. **Content Fetching** (`Services/ContentFetcher.swift` + `Services/FlashcardFetcher.swift`)
   - Fetches flashcards from GitHub folders using GitHub API v3
   - Automatically discovers markdown files in folders
   - Supports predefined deck configurations

5. **Views**
   - `LearnView`: Browse flashcard decks
   - `FlashcardReviewView`: Review interface with flip cards and quality buttons

6. **Localization**
   - Russian and English support
   - Deck names and descriptions localized

7. **Navigation**
   - Learn tab enabled in AppView
   - Navigation paths added for flashcard decks

## Design Decisions

### 1. Markdown Content as Flashcards
- **Decision**: Flashcards store full markdown content, not Q&A pairs
- **Rationale**: More flexible, allows rich content, matches existing content structure
- **Implementation**: `Flashcard.markdownContent` contains full markdown, `displayTitle` extracts title

### 2. Folder-Based Deck Discovery
- **Decision**: Fetch flashcards by folder name (e.g., "звуковые сигналы")
- **Rationale**: No need to hardcode file lists, automatic discovery
- **Implementation**: Uses GitHub API v3 to list directory contents, then fetches each `.md` file

### 3. SM-2 Algorithm
- **Decision**: Use SM-2 (SuperMemo 2) instead of FSRS
- **Rationale**: Simpler, well-tested, sufficient for MVP
- **Implementation**: `SpacedRepetitionService` calculates intervals and ease factors

### 4. Localized Deck Names
- **Decision**: Deck configurations include localization keys
- **Rationale**: Supports bilingual app (RU/EN)
- **Implementation**: `FlashcardFetcher.deckConfigurations` maps folder names to localized display names

## Potential Issues & Improvements

### 🔴 Critical Issues

1. **GitHub API Rate Limiting**
   - **Issue**: GitHub API v3 has rate limits (60 requests/hour unauthenticated)
   - **Impact**: May fail when fetching multiple decks
   - **Solution**: 
     - Add GitHub token support (authenticated requests: 5000/hour)
     - Cache deck listings
     - Add retry logic with exponential backoff

2. **Missing Error Handling**
   - **Issue**: Some error cases not handled gracefully
   - **Impact**: App may crash or show unclear errors
   - **Solution**: Add comprehensive error handling and user-friendly error messages

### 🟡 Medium Priority Issues

3. **Content Parsing Performance**
   - **Issue**: `MarkdownParser.parse()` called for each card during review
   - **Impact**: May be slow for large markdown files
   - **Solution**: Cache parsed markdown content in `Flashcard` model

4. **Deck Fetching Strategy**
   - **Issue**: Currently fetches all decks on first load
   - **Impact**: Slow initial load, high network usage
   - **Solution**: 
     - Lazy load decks (fetch on demand)
     - Show cached decks immediately, refresh in background
     - Add pull-to-refresh (already implemented)

5. **Flashcard Display Title Extraction**
   - **Issue**: `displayTitle` logic may not work for all markdown formats
   - **Impact**: Some cards may show filename instead of title
   - **Solution**: Improve parsing logic, handle more edge cases

6. **SRS Algorithm Tuning**
   - **Issue**: SM-2 parameters may need adjustment for sailing content
   - **Impact**: Cards may be reviewed too frequently or too rarely
   - **Solution**: 
     - Add user-configurable parameters
     - Monitor review statistics
     - Consider upgrading to FSRS for better accuracy

### 🟢 Low Priority / Future Enhancements

7. **Offline Support**
   - **Enhancement**: Cache flashcards for offline review
   - **Implementation**: Already partially implemented (UserDefaults), but could improve caching strategy

8. **Review Statistics Dashboard**
   - **Enhancement**: Show detailed stats (streak, mastery rate, etc.)
   - **Implementation**: Add `ReviewStatsView` component

9. **Card Filtering**
   - **Enhancement**: Filter cards by difficulty, due date, etc.
   - **Implementation**: Add filters to `FlashcardReviewView`

10. **Deck Customization**
    - **Enhancement**: Allow users to create custom decks
    - **Implementation**: Add deck creation UI, local storage

11. **Export/Import**
    - **Enhancement**: Export progress, import decks
    - **Implementation**: Add JSON export/import functionality

12. **Notifications**
    - **Enhancement**: Remind users to review due cards
    - **Implementation**: Add local notifications

## Code Quality Notes

### ✅ Good Practices

- Consistent use of `@Observable` for stores
- Type-safe navigation with `AppPath`
- Environment-based dependency injection
- Localization support from the start
- Design system consistency

### ⚠️ Areas for Improvement

1. **Error Handling**
   - Add more specific error types
   - Provide user-friendly error messages
   - Add retry mechanisms

2. **Testing**
   - Add unit tests for `SpacedRepetitionService`
   - Add tests for `FlashcardStore` persistence
   - Add UI tests for review flow

3. **Performance**
   - Optimize markdown parsing (cache results)
   - Lazy load decks
   - Optimize list rendering

4. **Accessibility**
   - Add VoiceOver labels
   - Improve button sizes for accessibility
   - Add Dynamic Type support

## Testing Checklist

- [ ] Fetch decks from GitHub (with network)
- [ ] Fetch decks offline (cached)
- [ ] Review flashcards (flip, rate quality)
- [ ] SRS algorithm (intervals update correctly)
- [ ] Persistence (restart app, progress saved)
- [ ] Localization (RU/EN switching)
- [ ] Error handling (network errors, empty decks)
- [ ] Edge cases (empty folders, malformed markdown)

## Known Limitations

1. **GitHub API Dependency**: Requires GitHub API access (may fail offline)
2. **No Authentication**: Uses unauthenticated GitHub API (rate limited)
3. **Simple SRS**: SM-2 is basic compared to modern algorithms
4. **No Cloud Sync**: Progress stored locally only
5. **Limited Formatting**: Markdown rendering is basic (no images, videos in flashcards)

## Migration Notes

If upgrading from a previous version:
- Flashcard data stored in UserDefaults with key `FlashcardStore.v1`
- Deck configurations defined in `FlashcardFetcher.deckConfigurations`
- To add new decks, update `FlashcardFetcher.deckConfigurations` and add localization keys

## Future Architecture Considerations

1. **Backend Integration**: Consider moving to a backend for:
   - Better rate limiting handling
   - Cloud sync
   - Analytics
   - Content management

2. **Advanced SRS**: Consider FSRS (Free Spaced Repetition Scheduler) for:
   - Better retention predictions
   - Adaptive difficulty
   - More accurate intervals

3. **Content Management**: Consider:
   - Admin dashboard for content updates
   - Version control for flashcards
   - A/B testing for SRS parameters

