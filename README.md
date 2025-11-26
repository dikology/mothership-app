# Mothership App

_EN · Native iOS companion for charter management and onboard education._

_RU · Нативное iOS‑приложение для управления чартером и обучения экипажа._

---

## Overview · Обзор

**EN** · Mothership keeps charter logistics, acceptance checklists, and practice content together so skippers and crews can plan, brief, and sail with confidence.

**RU** · Mothership объединяет планирование чартера, чек-листы и учебный контент, чтобы шкипер и экипаж могли готовиться и идти в море уверенно.

---

## Feature Highlights · Основные возможности

### 🛥️ Charter Management · Управление чартерами
- **EN** · Create, edit, and archive multiple charters with yacht data, charter company, location, and notes. Active trips are detected automatically from date ranges.
- **RU** · Создавайте и редактируйте несколько чартеров с данными яхты, чартерной компании, локацией и заметками. Текущий чартер определяется автоматически по датам.

### ✅ Check-in Checklist · Чек-листы приёмки
- **EN** · 60+ acceptance points across Equipment & Docs, Electrical, Engine, Sails, Navigation, Safety, and Handover communication. Sections collapse, each item stores guidance and crew notes, and completion is tracked per charter.
- **RU** · Более 60 пунктов по разделам: документы и оборудование, 12V панель, двигатель, паруса, навигация, безопасность и передача яхты. Разделы сворачиваются, у каждого пункта есть подсказки и заметки экипажа, прогресс фиксируется отдельно для каждого чартера.

### 📚 Practice Modules · Практика и брифинги
- **EN** · Safety briefings, knots, maneuvering, mooring, and yacht-life docs fetched from the Captain's Locker vault (Obsidian markdown). Supports section hierarchy (H2→H4), bullet formatting, bold text, and wikilinks.
- **RU** · Брифинги по безопасности, узлы, манёвры, швартовка и быт на борту загружаются из репозитория Captain's Locker (формат Obsidian). Поддерживаются заголовки H2–H4, списки, жирное начертание и вики‑ссылки.

### 🏠 Home Dashboard · Домашний экран
- **EN** · Shows time-based greeting, quick access card for the active charter, plus contextual practice modules when a trip is underway.
- **RU** · Отображает приветствие по времени суток, карточку текущего чартера и релевантные брифинги при активном рейсе.

### 🌍 Localization · Локализация
- **EN** · Russian default + English fallback, system language auto-detection, and type-safe localization keys. Russian copy includes English sailing terms for clarity.
- **RU** · Русский по умолчанию и английский при необходимости, автоматическое определение языка системы и типобезопасные ключи локализации. В русском тексте при необходимости приводятся английские термины.

### 📄 Content Management · Контент
- **EN** · GitHub integration keeps practice content up to date, YAML frontmatter is parsed, wikilinks resolve custom titles, and markdown is cached offline.
- **RU** · Интеграция с GitHub обновляет учебный контент, поддерживается YAML-фронтматтер, вики‑ссылки с кастомными подписями и офлайн-кеширование.

---

## Technical Highlights · Технические особенности

- **Architecture / Архитектура** · SwiftUI + MVVM, Observation framework (`@Observable`), environment-based DI, and enum-powered type-safe navigation via `AppPath`.
- **Data Persistence / Хранение данных** · `UserDefaults` + `Codable` модели содержат данные о чартерах, чек-листах и кеше контента. Прогресс изолирован на уровне отдельного чартера.
- **Testing / Тестирование** · ChecklistStore покрыт юнит-тестами (создание, прогресс, сохранение). 
- **Content System / Контентная система** · `ContentFetcher` загружает Markdown из GitHub асинхронно, `MarkdownParser` выполняет двухпроходный разбор, строит вложенные секции, разрешает вики‑ссылки и обрабатывает ошибки с понятной обратной связью.

---

## Project Structure · Структура проекта

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

## Development · Сборка и запуск

### Requirements · Требования

- **EN** · iOS 18.0+, Xcode 16.0+, Swift 5.10+
- **RU** · Требуется iOS 18.0+, Xcode 16.0+ и Swift 5.10+

### Getting Started · Быстрый старт

1. **EN** · Clone the repo  
   **RU** · Клонируйте репозиторий  
   ```bash
   git clone <repository-url>
   cd mothership-app
   ```
2. **EN** · Open the project in Xcode  
   **RU** · Откройте проект в Xcode  
   ```bash
   open mothership/mothership.xcodeproj
   ```
3. **EN** · Choose a target device or simulator  
   **RU** · Выберите устройство или симулятор
4. **EN** · Build & Run (⌘R)  
   **RU** · Соберите и запустите (⌘R)

### Testing · Тестирование

- **EN** · Run ⌘U for the full suite, ⌘⌃U for coverage.  
- **RU** · Запустите ⌘U для всех тестов или ⌘⌃U для покрытия.

```bash
cd mothership
xcodebuild test -scheme mothership -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Language Testing · Проверка локализации

1. **System** · Settings → General → Language & Region  
   _RU · Настройки → Основные → Язык и регион_
2. **Xcode** · Edit Scheme → Run → Options → App Language  
   _RU · Edit Scheme → Run → Options → App Language_
3. **Runtime** · Switch inside the app (upcoming UI toggle)  
   _RU · Переключение языка внутри приложения (фича в разработке)_

## Content Sources · Источники контента

- **EN** · Practice modules sync from the `captains-locker` Obsidian vault containing safety briefings, onboard life guides, and seamanship tutorials.  
- **RU** · Практические материалы синхронизируются с репозиторием `captains-locker` в формате Obsidian: брифинги по безопасности, жизнь на борту и материалы по судовождению.

## Localization · Работа со строками

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

## Design System · Дизайн-система

- **EN** · Maritime color palette, typography scale, 4pt spacing, reusable cards, and custom illustrations provide visual consistency.  
- **RU** · Морская цветовая палитра, типографика, 4‑пиксельная сетка отступов, переиспользуемые карточки и кастомные иллюстрации поддерживают единый стиль.

## Contributing · Вклад в проект

**Flow / Процесс**
1. **Models / Модели** · `Core/Models/`
2. **Stores / Хранилища** · `Core/Stores/`
3. **Views / Представления** · `Features/`
4. **Localization / Локализация** · `LocalizationKeys` + `Localizable.strings`
5. **Tests / Тесты** · Добавляйте юнит-тесты для бизнес-логики
6. **Docs / Документация** · Обновляйте README и комментарии

**Code Style / Стиль**
- SwiftUI everywhere · SwiftUI во всех экранах
- MVVM structure · Архитектура MVVM
- `@Observable` stores · Стора на Observation
- Environment-based DI · DI через Environment
- Type-safe navigation via `AppPath` · Безопасная навигация через `AppPath`
- Thorough error handling · Продуманная обработка ошибок

## Known Limitations · Ограничения

- **EN** · First content load needs network • Cache not synced across devices • CloudKit not yet integrated • Manual in-app language switch pending UI.  
- **RU** · Первая загрузка контента требует сети • Кеш не синхронизируется между устройствами • CloudKit ещё не подключён • Переключатель языка в приложении в работе.

## Future Enhancements · Планы

- [ ] **EN** Photos per checklist item · **RU** Фото к пунктам чек-листа
- [ ] **EN** Export checklist to PDF · **RU** Экспорт чек-листа в PDF
- [ ] **EN** More practice categories · **RU** Новые категории практики
- [ ] **EN** UGC system for content · **RU** Пользовательский контент


## License · Лицензия

MIT

---

**Version**: 1.0  
**Platform**: iOS 18.0+  
**Language**: Swift 5.10  
**Framework**: SwiftUI
