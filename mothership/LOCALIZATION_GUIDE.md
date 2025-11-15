# Localization Guide

This guide explains how to use the localization infrastructure in the mothership app.

## Overview

The app supports multiple languages with:
- **Default language**: Russian (ru)
- **Additional languages**: English (en)
- **System language detection**: Automatically uses device language
- **Manual override**: Support for settings to manually choose language

## Architecture

### Core Components

1. **LocalizationService** (`Services/LocalizationService.swift`)
   - Manages current language state
   - Detects system language
   - Provides localization methods
   - Persists language preference

2. **LocalizationKeys** (`Services/LocalizationKeys.swift`)
   - Type-safe string keys using `L10n` enum
   - Organized by feature/section

3. **Localizable.strings** (`Resources/{lang}.lproj/Localizable.strings`)
   - String translations for each language
   - Russian: `ru.lproj/Localizable.strings`
   - English: `en.lproj/Localizable.strings`

## Usage

### Basic String Localization

#### In SwiftUI Views

```swift
struct MyView: View {
    @Environment(\.localization) private var localization
    
    var body: some View {
        Text(localization.localized(L10n.Common.cancel))
    }
}
```

#### With String Formatting

```swift
let message = localization.localized("user.welcome", userName)
```

### Adding New Strings

1. **Add key to LocalizationKeys.swift**:
```swift
enum L10n {
    enum MyFeature {
        static let title = "myfeature.title"
        static let description = "myfeature.description"
    }
}
```

2. **Add translations to Localizable.strings**:

**ru.lproj/Localizable.strings**:
```
"myfeature.title" = "Заголовок";
"myfeature.description" = "Описание";
```

**en.lproj/Localizable.strings**:
```
"myfeature.title" = "Title";
"myfeature.description" = "Description";
```

3. **Use in code**:
```swift
Text(localization.localized(L10n.MyFeature.title))
```

## Language Switching

### System Language (Default)

The app automatically detects and uses the system language:
- Supported: Russian, English
- Fallback: Russian (if system language is unsupported)

### Manual Override (For Settings)

To implement language switching in settings:

```swift
struct LanguageSettingsView: View {
    @Environment(\.localization) private var localization
    
    var body: some View {
        Picker("Language", selection: binding) {
            // System language option
            Text(localization.localized(L10n.Settings.systemLanguage))
                .tag(Optional<AppLanguage>.none)
            
            // Manual language options
            ForEach(AppLanguage.allCases) { language in
                Text(language.displayName)
                    .tag(Optional(language))
            }
        }
    }
    
    private var binding: Binding<AppLanguage?> {
        Binding(
            get: { localization.currentLanguage },
            set: { localization.setLanguage($0) }
        )
    }
}
```

### Programmatic Language Change

```swift
// Set to specific language
localization.setLanguage(.english)

// Reset to system language
localization.useSystemLanguage()

// Check effective language
let current = localization.effectiveLanguage
```

## Best Practices

1. **Always use L10n keys**: Don't use string literals directly
   ```swift
   // ✅ Good
   Text(localization.localized(L10n.Common.cancel))
   
   // ❌ Bad
   Text(localization.localized("cancel"))
   ```

2. **Group keys by feature**: Organize keys in L10n enum by feature
   ```swift
   enum L10n {
       enum Home { ... }
       enum Profile { ... }
       enum Settings { ... }
   }
   ```

3. **Use descriptive key names**: Make keys self-documenting
   ```swift
   // ✅ Good
   static let saveSuccess = "settings.save.success"
   
   // ❌ Bad
   static let msg1 = "msg1"
   ```

4. **Keep translations in sync**: When adding a key, add translations for all languages

5. **Format strings properly**: Use format specifiers for dynamic content
   ```
   "user.welcome" = "Welcome, %@!";
   ```

## Testing Different Languages

### During Development

1. **Change device language**: Settings → General → Language & Region
2. **Use manual override** (once settings are implemented)
3. **Restart app** to see system language change

### In Xcode

1. Edit scheme → Run → Options → App Language
2. Select language to test
3. Run app

## Adding New Languages

1. **Create new .lproj folder**:
   ```
   Resources/es.lproj/Localizable.strings
   ```

2. **Add language to AppLanguage enum**:
   ```swift
   enum AppLanguage: String, CaseIterable {
       case russian = "ru"
       case english = "en"
       case spanish = "es"  // New language
       
       var displayName: String {
           switch self {
           case .spanish: return "Español"
           // ...
           }
       }
   }
   ```

3. **Add translations** to new Localizable.strings file

4. **Update system language detection** if needed in LocalizationService

## File Structure

```
mothership/
├── Services/
│   ├── LocalizationService.swift
│   └── LocalizationKeys.swift
└── Resources/
    ├── ru.lproj/
    │   └── Localizable.strings
    └── en.lproj/
        └── Localizable.strings
```

## Current Localized Strings

### Greetings
- `greeting.morning` - Morning greeting
- `greeting.day` - Afternoon greeting
- `greeting.evening` - Evening greeting
- `greeting.night` - Night greeting
- `greeting.subtitle` - Greeting subtitle

### Tab Bar
- `tab.home` - Home tab
- `tab.learn` - Learn tab
- `tab.practice` - Practice tab
- `tab.profile` - Profile tab

### Common
- `common.coming_soon` - Coming soon message
- `common.cancel` - Cancel button
- `common.save` - Save button
- `common.done` - Done button
- `common.back` - Back button

### Settings
- `settings.title` - Settings title
- `settings.language` - Language option
- `settings.system_language` - System language option

## Troubleshooting

### Strings not updating
1. Clean build folder (Cmd+Shift+K)
2. Restart Xcode
3. Check that .strings files are included in target

### Wrong language showing
1. Check `localization.effectiveLanguage`
2. Verify UserDefaults for saved preference
3. Check device language settings

### Missing translations
1. Verify key exists in both .strings files
2. Check spelling of key
3. Ensure .strings file has correct format

