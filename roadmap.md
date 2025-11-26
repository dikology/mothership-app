# Mothership Roadmap

## 🚀 Phase 1: Production MVP Stabilization (Current)

### Refactoring & Technical Debt
- [ ] **Error Handling**: Standardize error presentation across all views (currently mixed `FeedbackBanner` and alerts).
- [ ] **Content Caching**:
  - Implement smarter cache invalidation (ETag support for GitHub API) to reduce rate limiting.
  - Pre-download essential decks (Colregs, Lights) on first launch to avoid "offline" feeling.
- [ ] **UI/UX Polish**:
  - Add "Empty States" for Charters and Practice tabs.
  - Improve transition animations between flashcards.
  - Fix markdown rendering glitches (tables, complex lists).
- [ ] **Performance**:
  - Optimize `MarkdownParser` to run off main thread for large documents.
  - Reduce memory footprint of loaded images in `ContentCache`.

### Tests & Quality Assurance
- [ ] **Unit Tests**:
- [ ] **UI Tests**:
  - *Missing*: No XCUITest suite exists.
  - *Action*: Add UI tests for critical flows: "Create Charter", "Check-in Flow", and "Flashcard Review".
- [ ] **Snapshot Testing**:
  - Consider adding snapshot tests to catch visual regressions in markdown rendering.

### CI/CD Pipeline
- [ ] **Continuous Integration**:
  - Set up **GitHub Actions** to run unit tests on every PR.
  - Add **SwiftLint** build phase to enforce code style.
- [ ] **Continuous Delivery**:
  - Initialize **Fastlane** (`gym`, `pilot`) to automate TestFlight uploads.
  - Automate version bumping (`agvtool`).

## 🚁 Phase 2: Post-Release Enhancements

### Features
1.  **Cloud Sync (iCloud/CloudKit)**
    *   *Why*: Currently data is local-only. Users lose data if they reinstall.
    *   *Plan*: Sync `Charter` and `User` models via CloudKit. Keep heavy assets (images) cached locally.
2.  **Crew Management**
    *   *Why*: Sailing is a team sport.
    *   *Plan*: Allow inviting other users to a Charter via Deep Link. Shared checklists.
3.  **Advanced Logbook**
    *   *Why*: Captains need to log miles for licenses (RYA/IYT).
    *   *Plan*: Auto-log GPS tracks, weather data, and miles sailed. Export to PDF.
4.  **Weather Integration**
    *   *Why*: Critical for sailing safety.
    *   *Plan*: Integrate Windy.com or OpenWeatherMap API into the Charter dashboard.

### Infrastructure
- **Localization**: Add more languages
- **Analytics**: Add privacy-focused telemetry (e.g., TelemetryDeck) to track feature usage without collecting personal data.
- **Crash Reporting**: Integrate a lightweight crash reporter (e.g., Sentry or Firebase Crashlytics) to monitor stability in production.
- **Accessibility**: Conduct an accessibility audit (VoiceOver support, Dynamic Type) to ensure the app is usable by everyone.

## 🔭 Phase 3: Future Ideas & Blue Sky

### User Generated Content (UGC) & Community
- **Community Charters Board**: A space for captains to post upcoming trips and find crew members, or for beginners to find open spots on charters.
- **Yacht & Company Reviews**: "Yelp for Yachting" — verify reviews based on completed app charters. Rate specific boats (e.g., "The Lagoon 40 'Sea Breeze' has a broken water maker").

### Smart Tools
- **Defect Tracker**: A dedicated flow for logging issues during the charter (photos + description) to generate a PDF report for the charter company at checkout.
- **Expense Splitter**: Built-in "Kitty" management to track provisions, fuel, and mooring fees, and calculate who owes what.

### Open Source Contribution
- **In-App Editing**: Allow users to propose edits to educational content directly in the app, creating Issues orPull Requests to the `captains-locker` repository automatically.
