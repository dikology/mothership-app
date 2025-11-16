# Mothership App

A comprehensive sailing charter management and education application for iOS.

## Overview

Mothership is a native iOS app designed to help sailing enthusiasts manage their charter experiences and access essential sailing knowledge. The app combines practical charter management with educational content, making it the perfect companion for both novice and experienced sailors.

## Features

### 🛥️ Charter Management
- **Create & Manage Charters**: Track multiple sailing charters with dates, locations, yacht details
- **Active Charter Detection**: Automatically identifies current charters based on dates
- **Charter Details**: Store yacht name, charter company, location, and custom notes
- **CRUD Operations**: Full create, read, update, and delete functionality

### ✅ Check-in Checklist
- **Comprehensive Yacht Acceptance**: 60+ items across 7 essential sections
  - Equipment and Documents
  - 12V Panel Systems
  - Engine Inspection
  - Sails Check
  - Navigation Equipment
  - Safety Equipment
  - Charter Manager Communication
- **Expandable Sections**: Tap to collapse/expand checklist sections
- **Item Notes**: 
  - Static informational notes for guidance
  - User-editable notes on any item
- **Progress Tracking**: Visual progress indicator showing completion percentage
- **Charter-Scoped State**: Each charter maintains independent checklist progress
- **Persistent Storage**: Checklist state saved between app sessions

### 📚 Practice Modules
- **Safety Briefings**: Essential safety procedures and protocols
- **Yacht Life Guide**: Living aboard best practices
- **Category Filtering**: Browse by briefing, knots, maneuvering, mooring
- **Rich Content Display**: 
  - Hierarchical sections (H2 → H3 → H4)
  - Bullet lists with formatting
  - Bold text support
  - Wikilinks for cross-references

### 🏠 Home Dashboard
- **Personalized Greeting**: Time-based greetings (morning, afternoon, evening, night)
- **Charter Quick Access**: View and access active charter details
- **Context-Aware Briefings**: Displays relevant briefing modules when charter is active

### 🌍 Localization
- **Bilingual Support**: Russian (default) and English
- **System Language Detection**: Automatically adapts to device language
- **International Terms**: Russian text includes English sailing terms as reference
- **Type-Safe Keys**: Compile-time checked localization strings

### 📄 Content Management
- **GitHub Integration**: Fetches practice content from remote repository
- **Obsidian Compatibility**: Supports Obsidian-style markdown formatting
- **Markdown Parser**: 
  - Hierarchical sections
  - Wikilinks with custom display text
  - Frontmatter metadata (YAML)
  - Bold formatting
  - Emoji support
- **Offline Caching**: Content cached for offline access

## Technical Highlights

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **Observation Framework**: SwiftUI @Observable for reactive state management
- **MVVM Pattern**: Clear separation of concerns
- **Environment-Based DI**: Clean dependency injection via SwiftUI environment
- **Type-Safe Navigation**: Enum-based navigation paths

### Data Persistence
- **UserDefaults**: Charter and checklist state storage
- **Codable Models**: JSON encoding/decoding for all data models
- **Charter Isolation**: Independent state per charter

### Testing
- **Unit Tests**: Comprehensive ChecklistStore test coverage
- **Test Isolation**: Proper setup/teardown for reliable tests
- **Persistence Testing**: Validates state retention across app sessions

### Content System
- **ContentFetcher**: Asynchronous GitHub content retrieval
- **MarkdownParser**: 
  - Two-pass parsing for accuracy
  - Recursive section hierarchy
  - Wikilink resolution
  - Rich text processing
- **Error Handling**: Graceful error states with user feedback

## Project Structure

```
mothership/
├── App/
│   ├── AppModel.swift              # App state and stores
│   └── AppView.swift               # Root view with navigation
├── Core/
│   ├── Models/
│   │   ├── Charter.swift           # Charter data model
│   │   ├── Checklist.swift         # Checklist models and default data
│   │   ├── Briefing.swift          # Briefing content model
│   │   └── PracticeContent.swift   # Practice module models
│   ├── Navigation/
│   │   └── AppPath.swift           # Type-safe navigation paths
│   └── Stores/
│       ├── CharterStore.swift      # Charter state management
│       ├── ChecklistStore.swift    # Checklist state management
│       └── EnvironmentKeys.swift   # SwiftUI environment keys
├── DesignSystem/
│   ├── AppSpacing.swift            # Spacing constants
│   ├── AppTheme.swift              # Theme configuration
│   ├── Colors.swift                # Color palette
│   ├── Typography.swift            # Font styles
│   └── Components/                 # Reusable UI components
│       ├── Button.swift
│       ├── Card.swift
│       └── CardIllustration.swift
├── Features/
│   ├── Charter/
│   │   ├── CharterCreationView.swift
│   │   ├── CharterDetailView.swift
│   │   ├── CharterEditView.swift
│   │   └── CheckInChecklistView.swift
│   ├── Home/
│   │   └── HomeView.swift          # Dashboard with active charter
│   └── Practice/
│       ├── PracticeView.swift       # Module browser
│       └── PracticeModuleDetailView.swift
├── Services/
│   ├── ContentFetcher.swift        # GitHub content retrieval
│   ├── MarkdownParser.swift        # Markdown to structured data
│   ├── LocalizationService.swift  # Localization system
│   └── LocalizationKeys.swift     # Type-safe string keys
└── Resources/
    ├── ru.lproj/
    │   └── Localizable.strings     # Russian translations
    └── en.lproj/
        └── Localizable.strings     # English translations
```

## Development

### Requirements

- **iOS**: 18.0+
- **Xcode**: 16.0+
- **Swift**: 5.10+

### Getting Started

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd mothership-app
   ```

2. Open in Xcode
   ```bash
   open mothership/mothership.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run (⌘R)

### Testing

Run unit tests in Xcode:
- **All Tests**: ⌘U
- **Test with Coverage**: ⌘⌃U

Or via command line:
```bash
cd mothership
xcodebuild test -scheme mothership -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Testing Different Languages

1. **System Language**: Settings → General → Language & Region
2. **Xcode**: Edit Scheme → Run → Options → App Language
3. **Runtime**: Switch language in app settings (when implemented)

## Content Sources

Practice content is fetched from the Captain's Locker repository:
- Repository: `captains-locker`
- Format: Obsidian-style Markdown
- Sections: Safety briefings, yacht procedures, sailing techniques

## Localization

### Quick Start

```swift
struct MyView: View {
    @Environment(\.localization) private var localization
    
    var body: some View {
        Text(localization.localized(L10n.Common.save))
    }
}
```

### Adding New Strings

1. Add key to `LocalizationKeys.swift`:
   ```swift
   enum MyFeature {
       static let newString = "my_feature.new_string"
   }
   ```

2. Add translations to both `Localizable.strings` files:
   ```
   // en.lproj/Localizable.strings
   "my_feature.new_string" = "My String";
   
   // ru.lproj/Localizable.strings
   "my_feature.new_string" = "Моя строка";
   ```

3. Use in code:
   ```swift
   Text(localization.localized(L10n.MyFeature.newString))
   ```

## Design System

The app uses a comprehensive design system with:
- **Color Palette**: Maritime-themed colors (ocean blue, lavender, sunset orange)
- **Typography Scale**: Consistent font sizes and weights
- **Spacing System**: 4px-based spacing scale
- **Card Components**: Reusable featured and grid cards
- **Illustrations**: Custom maritime illustrations

## Contributing

When adding new features:

1. **Models**: Create data models in `Core/Models/`
2. **Stores**: Add state management in `Core/Stores/`
3. **Views**: Implement UI in `Features/`
4. **Localization**: Add keys and translations
5. **Tests**: Write unit tests for business logic
6. **Documentation**: Update README and inline documentation

### Code Style

- Use SwiftUI for all UI
- Follow MVVM architecture
- Use `@Observable` for stores
- Environment-based dependency injection
- Type-safe navigation with `AppPath`
- Comprehensive error handling

## Known Limitations

- Practice content requires network connection for first load
- Content is cached but not synced across devices
- No CloudKit integration yet
- Manual language switching not yet implemented in UI

## Future Enhancements

- [ ] Daily checklists for ongoing charter management
- [ ] Photo attachments for checklist items
- [ ] Export checklist as PDF
- [ ] Additional practice content categories
- [ ] UGC system for content


## License

MIT

---

**Version**: 1.0  
**Platform**: iOS 18.0+  
**Language**: Swift 5.10  
**Framework**: SwiftUI
