# TestFlight Information

## App Information
- **App Name**: Mothership
- **Subtitle**: Your companion for charter management and sailing education
- **Category**: Lifestyle / Education / Sports
- **Primary Language**: English (US)
- **Secondary Language**: Russian
- **Age Rating**: 4+

## Test Information
- **Testing Goal**: Evaluate usability of charter management workflow and spaced repetition learning system.

## What to Test
1. **Charter Management**:
   - Create a new charter with details (location, yacht name, dates).
   - Use the Check-in Checklist during a mock boat takeover.

2. **Learning & Practice**:
   - Try the "Flashcards" feature with Sound Signals or Navigation Lights decks.
   - Review the "Spaced Repetition" logic (answer "Again", "Hard", "Good", "Easy").
   - Read a practical guide (e.g., "Safety Briefing") in the Practice tab.
   - Verify that markdown content renders correctly (images, text formatting).

3. **Offline Capability**:
   - Turn off Wi-Fi/Cellular after initial content load.
   - Verify that previously opened guides and flashcards remain accessible.

4. **Account Management**:
   - Sign In with Apple.
   - Edit Profile (DisplayName, User Type).
   - Delete Account (Settings -> Delete Account).

## Known Issues / Limitations
- **Content**: Some educational content is fetched from a public GitHub repository and may be subject to API rate limits (60 requests/hour for unauthenticated IP).
- **Data Sync**: No cloud sync currently enabled; all data is local to the device. Deleting the app deletes all data.

## Beta Review Notes
- **Sign In**: Uses "Sign In with Apple" exclusively.
- **Data Privacy**: All data stored locally (Keychain/UserDefaults). No external analytics.
- **External Content**: Educational materials are dynamically fetched from [dikology/captains-locker](https://github.com/dikology/captains-locker).

