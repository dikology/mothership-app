# Authentication System Implementation

## Overview

Implemented a comprehensive authentication system with user types and community affiliations, serving as the foundation for crew building, adventure registration, and user-generated content features.

## Features Implemented

### 1. User Model (`Core/Models/User.swift`)

**User Types**:
- `captain` - Charter captains, yacht owners, experienced sailors
- `crew` - Sailors seeking crew positions
- `traveler` - Adventure seekers, passengers

**Community System**:
- `Community` model with predefined communities:
  - Sila Vetra
  - Sailing Virgins
- Users can belong to multiple communities
- Foundation for community-based matching

**Profile Information**:
- Experience level (beginner, intermediate, advanced, expert)
- Certifications (name, organization, dates)
- Sailing history (roles, vessel types, locations)
- Reputation and contribution tracking

### 2. Authentication Services

**TokenManager** (`Services/Authentication/TokenManager.swift`):
- Secure Keychain storage for user data and tokens
- User persistence across app sessions
- Apple Sign In token management

**AppleSignInProvider** (`Services/Authentication/AppleSignInProvider.swift`):
- Full Sign in with Apple implementation
- Handles authorization flow
- Creates User from Apple credentials
- Secure nonce generation for security

**AuthService** (`Services/Authentication/AuthService.swift`):
- Orchestrates authentication flow
- Manages user persistence
- Handles sign out

### 3. User Store (`Core/Stores/UserStore.swift`)

**State Management**:
- `@Observable` store for user state
- `isAuthenticated` computed property
- Automatic user loading on initialization

**Methods**:
- `signInWithApple()` - Sign in flow
- `signOut()` - Sign out and clear data
- `updateUserType()` - Change user type
- `addCommunity()` / `removeCommunity()` - Manage communities
- `updateExperienceLevel()` - Update experience
- `addCertification()` / `removeCertification()` - Manage certifications

### 4. Sign In View (`Features/Auth/SignInView.swift`)

**Features**:
- Clean, welcoming UI with app branding
- Sign in with Apple button
- Guest mode option (disabled for now - requires auth)
- Privacy policy link
- Loading states and error handling

### 5. Profile View (`Features/Profile/ProfileView.swift`)

**Features**:
- User profile display with avatar
- User type display and editing
- Community affiliations list
- Experience level and certifications
- Statistics (contributions, reputation)
- Edit profile and sign out options

**User Type Picker**:
- Modal sheet for selecting user type
- Visual icons for each type
- Current selection indicator

### 6. App Integration

**AppView Updates**:
- Shows `SignInView` when not authenticated
- Shows main app with Profile tab when authenticated
- Profile tab added to navigation

**Environment Setup**:
- `UserStore` added to environment
- Available throughout app via `@Environment(\.userStore)`

## Architecture

### Data Flow

```
SignInView
  ↓ (user action)
UserStore.signInWithApple()
  ↓
AuthService.signInWithApple()
  ↓
AppleSignInProvider.signIn()
  ↓ (Apple authorization)
TokenManager.saveUser()
  ↓
UserStore.currentUser = user
  ↓
AppView shows main app
```

### Security

- **Keychain Storage**: All sensitive data stored securely
- **Nonce Generation**: Secure random nonce for Apple Sign In
- **Token Management**: Secure token storage and retrieval
- **User Data**: Encrypted storage in Keychain

## Future Use Cases Enabled

### 1. Crew Building (Phase 4.1)
- Captains can post crew opportunities
- Crew members can browse and apply
- Matching based on user type, experience, communities

### 2. Adventure Registration (Phase 4.1)
- Organizers create adventures
- Travelers register for trips
- Community-based trip discovery

### 3. Charter Collaboration
- Multiple users join same charter
- Role assignment (captain, crew, passenger)
- Shared checklists and briefings

### 4. User-Generated Content (Phase 3)
- Reviews tied to user profiles
- Contribution tracking
- Reputation system
- Content moderation

## Localization

Added localization keys for:
- Auth flow (sign in, sign out, welcome message)
- Profile (user type, communities, experience, statistics)
- Both Russian and English translations

## Testing Considerations

**Manual Testing Required**:
1. Sign in with Apple flow
2. User persistence (restart app)
3. Sign out flow
4. User type selection
5. Community management (future)
6. Profile updates

**Future Test Cases**:
- Unit tests for UserStore methods
- Integration tests for auth flow
- UI tests for SignInView and ProfileView

## Next Steps

1. **Enable Guest Mode** (optional):
   - Allow browsing without authentication
   - Limited functionality
   - Prompt to sign in for full features

2. **Community Management UI**:
   - Community picker/browser
   - Join/leave communities
   - Community-specific content

3. **Profile Editing**:
   - Edit display name
   - Add/remove certifications
   - Update sailing history
   - Bio editing

4. **Cloud Sync** (Phase 2):
   - Sync user profiles to Firebase/Supabase
   - Multi-device support
   - Profile backup

5. **Crew Building Features** (Phase 4.1):
   - Crew opportunity posting
   - Application system
   - Matching algorithm

6. **Adventure Registration** (Phase 4.1):
   - Adventure creation
   - Registration flow
   - Trip management

## Files Created

1. `Core/Models/User.swift` - User model with types and communities
2. `Services/Authentication/TokenManager.swift` - Keychain storage
3. `Services/Authentication/AppleSignInProvider.swift` - Apple Sign In
4. `Services/Authentication/AuthService.swift` - Auth orchestration
5. `Core/Stores/UserStore.swift` - User state management
6. `Features/Auth/SignInView.swift` - Sign in UI
7. `Features/Profile/ProfileView.swift` - Profile UI

## Files Modified

1. `App/AppView.swift` - Auth gate, Profile tab
2. `App/mothershipApp.swift` - UserStore initialization
3. `Core/Stores/EnvironmentKeys.swift` - UserStore environment key
4. `Services/LocalizationKeys.swift` - Auth and Profile keys
5. `Resources/*/Localizable.strings` - Translations

## Known Limitations

1. **Guest Mode**: Currently disabled - requires authentication
2. **Community Management**: UI for adding communities not yet implemented
3. **Profile Editing**: Full profile editing UI not yet implemented
4. **Cloud Sync**: User data only stored locally (Keychain)
5. **Apple Sign In**: Requires proper App ID configuration with Sign in with Apple capability

## Configuration Required

**Xcode Project Setup**:
1. Enable "Sign in with Apple" capability in App ID
2. Configure in Xcode: Signing & Capabilities → + Capability → Sign in with Apple
3. Ensure proper provisioning profile

**Info.plist** (if needed):
- No additional configuration required for basic Apple Sign In

## Usage Example

```swift
// In any view
@Environment(\.userStore) private var userStore

// Check authentication
if userStore.isAuthenticated {
    // Show authenticated content
}

// Access user
if let user = userStore.currentUser {
    Text("Hello, \(user.displayName)")
    
    // Check user type
    if user.userType == .captain {
        // Show captain-specific features
    }
    
    // Check communities
    if user.communities.contains(.silaVetra) {
        // Show Sila Vetra content
    }
}
```

