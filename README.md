# Mothership App

A sailing education and practice application.

## Features

- **Multilingual Support**: Russian (default) and English
- **System Language Detection**: Automatically adapts to device language
- **Manual Language Override**: Support for manual language selection in settings

## Localization

The app uses a comprehensive localization infrastructure:

- **Default Language**: Russian (ru)
- **Additional Languages**: English (en)
- **Auto-detection**: Uses system language preferences
- **Manual Override**: Prepared infrastructure for settings-based language switching

For detailed localization documentation, see [LOCALIZATION_GUIDE.md](mothership/LOCALIZATION_GUIDE.md)

### Quick Start with Localization

```swift
// In any SwiftUI view
struct MyView: View {
    @Environment(\.localization) private var localization
    
    var body: some View {
        Text(localization.localized(L10n.Common.cancel))
    }
}
```

### File Structure

```
mothership/
├── mothership/
│   ├── App/
│   │   ├── AppModel.swift        # Contains LocalizationService instance
│   │   └── AppView.swift         # Main app view with localized UI
│   ├── Services/
│   │   ├── LocalizationService.swift   # Core localization service
│   │   └── LocalizationKeys.swift      # Type-safe string keys
│   ├── Resources/
│   │   ├── ru.lproj/
│   │   │   └── Localizable.strings    # Russian translations
│   │   └── en.lproj/
│   │       └── Localizable.strings    # English translations
│   └── Features/
│       └── Home/
│           └── HomeView.swift    # Example of localized view
└── LOCALIZATION_GUIDE.md         # Comprehensive localization guide
```

## Development

### Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 5.10+

### Building

1. Open `mothership.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press Cmd+R to build and run

### Testing Different Languages

1. **System Language**: Change device language in Settings → General → Language & Region
2. **Xcode Testing**: Edit Scheme → Run → Options → App Language
3. **Manual Override**: Use settings (once implemented)

## Project Structure

- **App/**: Main app configuration and root views
- **Core/**: Core functionality and navigation
- **DesignSystem/**: UI components and styling
- **Features/**: Feature-specific views and logic
- **Services/**: Business logic and services (including localization)
- **Resources/**: Assets and localization files

## Contributing

When adding new features:

1. Add localization keys to `LocalizationKeys.swift`
2. Add translations to both `ru.lproj/Localizable.strings` and `en.lproj/Localizable.strings`
3. Use `L10n` enum for type-safe string access
4. Test in both languages

## License

