### **Phase 1: Architecture & Error Definitions**

We need a unified error system that wraps domain-specific errors (Network, Auth, Data) into a consumable format for the UI.

1.  **Create `AppError` Protocol & Enum**
    *   Define a global `AppError` enum that conforms to `LocalizedError`.
    *   **Categories**:
        *   `.network(NetworkError)`: Connectivity, timeouts, rate limits.
        *   `.auth(AuthError)`: Session expired, unauthorized, sign-in failed.
        *   `.content(ContentError)`: Not found, parsing failed, empty data.
        *   `.validation(ValidationError)`: Invalid input, missing fields.
        *   `.unknown(Error)`: Fallback.
    *   **Actionable Feedback**: Add a property `isRetryable: Bool` to `AppError` to automatically determine if the UI should show a "Retry" button.

2.  **Refactor Existing Errors**
    *   Map `ContentFetchError` (currently in `ContentFetcher.swift`) to this new system.
    *   Update `RetryStrategy` to work with `AppError` types.

### **Phase 2: Localization (User-Friendly Messages)**

Move hardcoded strings from code into the localization system to ensure consistent tone and multi-language support.

3.  **Update `LocalizationKeys.swift`**
    *   Add a new namespace `enum Error` within `L10n`.
    *   Define keys: `network_connection`, `server_error`, `not_found`, `unauthorized`, `generic_retry`, `rate_limit`.

4.  **Populate `Localizable.strings` (en & ru)**
    *   **English**: "Something went wrong", "Please check your internet connection", "Content not found".
    *   **Russian**: "Что-то пошло не так", "Проверьте соединение с интернетом", "Контент не найден".
    *   *Edge Case*: Ensure distinct messages for `Rate Limit` (GitHub API) vs generic `Timeout`.

### **Phase 3: UI Components (Design System)**

Create reusable components in `mothership/DesignSystem/Components` to standardize how errors and loading states differ visually.

5.  **Create `LoadingView`** ✅
    *   Delivered as `LoadingStateView` and already powering Learn/Practice blocking spinners.

6.  **Create `ErrorView`** ✅
    *   Delivered as `ErrorStateView` with severity-aware iconography and primary/secondary `FeedbackAction`s.

7.  **Create `ToastView` / `BannerView`** ✅
    *   Delivered as `FeedbackBanner` (info/warning/error) now surfacing cache fallbacks & retries in Learn/Practice.

### **Phase 4: State Management Integration**

Standardize how Views consume data to ensure Loading/Error states are never missed.

8.  **Introduce `ViewState<T>` Generic** ✅
    *   `ViewState<Value>` now lives in `Core/Models` with helpers for `data`, `errorValue`, `isLoading`, and `empty` states.

9.  **Refactor Stores & ViewModels** ✅ (Flashcards/Learn + Charter/Checklist)
    *   `FlashcardStore`, `CharterStore`, and `ChecklistStore` now publish `ViewState` plus helper hooks (`mark…Loading/Loaded/Error`).
    *   `LearnView`, `HomeView`, and `CheckInChecklistView` render loading/error banners via `FeedbackBanner` + `LoadingStateView`.
    *   **Next**: extend the same pattern to any remaining networked services (`ContentFetcher`, `UserStore`) as Phase 4b polish.

### **Phase 5: Edge Cases & Implementation**

Address specific failure scenarios defined in the requirements.

10. **Handling Empty Decks & Malformed Markdown**
    *   **Empty Decks**: If `FlashcardFetcher` returns 0 cards, return `.empty` state instead of `.error`. Create an `EmptyStateView` (distinct from `ErrorView`) inviting the user to check back later.
    *   **Malformed Markdown**: Update `MarkdownParser` to have a "safe mode" — if parsing fails, display raw text or a placeholder error block instead of crashing or showing blank space.

11. **Network Timeouts & Rate Limits**
    *   **Timeout**: Ensure `RetryStrategy` throws a clear `.timeout` error after retries are exhausted.
    *   **Rate Limits**: If `ContentFetchError.rateLimited` occurs, the `ErrorView` should explicitly show the cooldown time (e.g., "Please wait 5 minutes") rather than a generic error.

### **Phase 6: Final Polish**

12. **Audit & Testing**
    *   Manually trigger errors (airplane mode, bad URL) to verify `ErrorView` appears.
    *   Verify `Retry` buttons actually re-trigger the async function.
    *   Check VoiceOver accessibility for Error and Loading states.

