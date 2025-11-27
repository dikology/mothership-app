# Product Requirements Document: Mothership App

## Executive Summary

**Mothership** is a native iOS companion app for charter yacht management and crew education. It serves three user types—**Captains**, **Crew**, and **Travelers**—by providing charter logistics management, comprehensive acceptance checklists, spaced-repetition learning tools, and practical sailing guides. The app operates offline-first with selective cloud sync for educational content.

The app is structured into four main pillars:
1. **Charter Management** – Create, manage, and track sailing trips
2. **Check-in Checklists** – Comprehensive yacht acceptance workflows
3. **Practice Modules** – Briefings, safety guides, and procedural documentation
4. **Learn (Flashcards)** – Spaced repetition system for maritime knowledge retention

---

## 1. Problem Statement & Objectives

### Current State

Sailors preparing for charter trips face fragmented tools: paper checklists get lost, educational content is scattered across websites and YouTube, and trip coordination happens across multiple apps. No single tool combines trip logistics, acceptance workflows, and onboard education.

### Problems Solved

| User | Problem | Solution |
|------|---------|----------|
| **Captain** | No standardized yacht acceptance process | 60+ item check-in checklist with section-specific guidance and crew notes |
| **Captain** | Forgetting critical safety briefing points | Pre-departure and safety briefing modules available offline |
| **Crew** | Difficulty remembering navigation rules and signals | Spaced repetition flashcards (SM-2 algorithm) for COLREGs, lights, sounds |
| **Crew** | Unsure about proper mooring procedures | Step-by-step practice guides for Mediterranean mooring, anchoring |
| **Traveler** | Intimidated by unfamiliar yacht environment | Life-on-yacht briefing and safety essentials in accessible format |
| **All** | Internet unavailable at sea or in remote marinas | Offline-first architecture with cached content |

### Success Metrics

- **Adoption:** 80% of users who create a charter use the check-in checklist.
- **Learning Engagement:** Average user completes ≥10 flashcard reviews per charter.
- **Retention:** 60% of users who complete one charter return to create another within 6 months.
- **Content Quality:** Average practice module rating ≥4.5/5 (when ratings implemented).
- **Offline Reliability:** ≥95% of core features functional without network.

---

## 2. User Types & Personas

### Captain

The primary user. Responsible for yacht acceptance, crew safety, and trip coordination.

**Needs:**
- Comprehensive acceptance checklist to document yacht condition
- Quick access to safety briefing points
- Reference materials for navigation rules
- Charter history and statistics

**Experience Level:** Intermediate to Expert (holds RYA/IYT certification or equivalent)

### Crew

Active sailing participants who assist the captain.

**Needs:**
- Understanding of their responsibilities during maneuvers
- Knowledge of knots and line handling
- Familiarity with safety equipment location and usage
- Learning tools for navigation theory

**Experience Level:** Beginner to Intermediate

### Traveler

Guests on charter trips with minimal sailing background.

**Needs:**
- Life-on-yacht orientation (heads, galley, safety)
- Understanding of safety procedures
- Clarity on expectations and etiquette

**Experience Level:** None to Beginner

---

## 3. Feature Specifications

### 3.1 Home Dashboard

**Purpose:** Provide contextual entry point based on user's current charter state.

#### Core Elements

1. **Time-Based Greeting**
   - Morning (5–12): "Good Morning"
   - Afternoon (12–17): "Good Afternoon"
   - Evening (17–22): "Good Evening"
   - Night (22–5): "Good Night"

2. **Active Charter Card**
   - Displays when a charter's date range includes today
   - Shows: Charter name, location, yacht name (if set)
   - Tap navigates to Charter Detail
   - Uses `FeaturedCard` component with `basicsCardColor` background

3. **Create Charter CTA**
   - Displays when no active charter exists
   - Uses same `FeaturedCard` layout for visual consistency
   - Text: "Create Charter" / "Создать чартер"

4. **Contextual Practice Modules**
   - Appears only when active charter exists
   - Shows briefing-category modules (Safety, Life on Yacht, Pre-Departure)
   - Grid layout (2-column) with category-appropriate colors

#### Wireframe

```
Home
├─ Header: Time-based greeting + subtitle
├─ Active Charter Card (if active) OR Create Charter CTA
├─ Briefing Section (if active charter):
│   ├─ Section title + subtitle
│   ├─ Daily Checklist Card (horizontal, dark background)
│   └─ 2-column grid of briefing modules
```

---

### 3.2 Charter Management

**Purpose:** Create, edit, and track charter trips with yacht and company details.

#### Data Model

```
Charter
├─ id: UUID
├─ name: String (required)
├─ startDate: Date (required)
├─ endDate: Date? (optional)
├─ location: String? (optional)
├─ yachtName: String? (optional)
├─ charterCompany: String? (optional)
├─ notes: String? (optional)
├─ createdAt: Date
└─ isActive: computed (based on current date within date range)
```

#### Features

1. **Charter Creation**
   - Required: Name, Start Date
   - Optional: End Date, Location, Yacht Name, Charter Company, Notes
   - Validation: End date must be ≥ start date

2. **Charter Detail View**
   - Displays all charter information
   - Quick actions: Edit, Check-in Checklist
   - Shows checklist completion progress
   - Actions: Archive, Delete

3. **Charter Edit**
   - Inline editing of all fields
   - Date picker with sensible defaults
   - Save/Cancel actions

4. **Active Charter Detection**
   - Automatic detection based on date range
   - Only one charter can be active at a time (first match wins)
   - Used to surface contextual content on Home

#### User Flows

```
Charter Creation Flow
├─ Home → "Create Charter" card
├─ CharterCreationView
│   ├─ Name field (required)
│   ├─ Start/End date pickers
│   ├─ Location field
│   ├─ Yacht Name field
│   ├─ Charter Company field
│   ├─ Notes field (multiline)
│   └─ "Create" button (disabled until name filled)
└─ Success → Navigate to Charter Detail

Charter Detail Flow
├─ Home → Active Charter card
├─ CharterDetailView
│   ├─ Charter info display
│   ├─ Checklist progress indicator
│   ├─ "Start Check-in" button
│   ├─ Edit action
│   └─ Archive/Delete actions
```

---

### 3.3 Check-in Checklists

**Purpose:** Comprehensive yacht acceptance process with 60+ checklist items across multiple sections.

#### Data Model

```
Checklist
├─ id: UUID
├─ title: String
├─ type: ChecklistType (charterScoped | reference)
├─ charterType: CharterChecklistType? (preCharter | checkIn | daily | postCharter)
├─ sections: [ChecklistSection]
├─ source: ChecklistSource (bundled | remote | userCreated)
└─ lastFetched: Date?

ChecklistSection
├─ id: UUID
├─ title: String
└─ subsections: [ChecklistSubsection]

ChecklistSubsection
├─ id: UUID
├─ title: String
└─ items: [ChecklistItem]

ChecklistItem
├─ id: UUID
├─ title: String
├─ note: String? (guidance text)
├─ isChecked: Bool
├─ userNote: String? (crew-added notes)
└─ checkedAt: Date?
```

#### Default Check-in Sections

1. **Equipment and Documents**
   - Boat documents (Registration, Insurance, Charter agreement, etc.)
   - Safety Equipment (Life jackets, Fire extinguishers, EPIRB, etc.)
   - Engine spares (Impeller, Alternator belt)
   - Sails (Winch handles, Repair kit)
   - Electronics and Navigation (Chartplotter, VHF, Compass, etc.)
   - Hull and deck (Swimming ladder, Gangway, Fenders, etc.)
   - Dinghy (Air pump, Oars, Outboard motor)

2. **Inside the Boat**
   - 12V Panel (Water pump, Bilge pump, Navigation, etc.)
   - 220V Panel (Battery charger, Sockets, Shore cable)
   - Saloon & Cabins (Lights, Hatches, Cushions, Floors)
   - Toilets (Pump, Lights, Hatches, Doors)
   - Galley (Gas stove, Fridges)
   - Engine compartment (Cleanliness, Oil, Coolant, Belt)
   - Steering (Ropes condition)

3. **Outside the Boat**
   - Stern (Pulpit, Guardrails, Lights, Fenders, Mooring lines)
   - Sides (Guardrails, Stanchions, Damage documentation)
   - Bow (Pulpit, Navigation lights)
   - Windlass (Hatch, Anchor, Chain, Operation test)
   - Engine test (Start, Wet exhaust, Gears, Engine hours)
   - Navigation instruments (Echo sounder, Speed, Autopilot, Windex)
   - Post-check shutdown (Engine, Nav lights, Navigation, Windlass)
   - Rig (Winches, Ropes, Clutches, Blocks, Cars, Boom)

4. **Sails**
   - Jib/Genoa inspection
   - Mainsail (battens) inspection
   - Furling mainsail inspection

5. **Optional Equipment**
   - Generator operation
   - Air conditioner
   - Watermaker

6. **Safety Equipment Check**
   - Life jackets count and condition
   - Safety harnesses
   - Life raft inspection date
   - Life ring and MOB beacon
   - Visual distress signals
   - Fire extinguishers
   - Smoke/CO detectors
   - First aid kit

7. **Communication with Charter Manager**
   - Document issues
   - Ask operational questions
   - Clarify required documents
   - Collect emergency contacts

#### Features

1. **Charter-Scoped Progress**
   - Each charter maintains separate checklist state
   - Progress persists across app sessions
   - Completion percentage displayed in Charter Detail

2. **Item Guidance**
   - Each item can have built-in guidance note
   - Guidance shown on item expansion
   - Bilingual support (English + Russian)

3. **User Notes**
   - Add custom notes to any checklist item
   - Notes persist per charter
   - Useful for documenting defects or deviations

4. **Section Collapsing**
   - Sections collapse/expand for navigation
   - Expand all/Collapse all actions
   - Subsections within sections

#### User Flow

```
CheckInChecklistView
├─ Header: Charter name, completion progress (X/Y items)
├─ Section list (collapsible):
│   ├─ Section title + completion count
│   ├─ Subsection title
│   └─ ChecklistItem rows:
│       ├─ Checkbox toggle
│       ├─ Item title
│       ├─ Guidance note (expandable)
│       └─ User note input (expandable)
└─ Footer: Overall progress, Export button (future)
```

---

### 3.4 Practice Modules

**Purpose:** Educational content for sailing procedures, safety briefings, and seamanship skills.

#### Data Model

```
PracticeModule
├─ id: UUID
├─ title: String
├─ subtitle: String
├─ category: PracticeCategory
├─ type: PracticeModuleType (checklist | briefing | document)
├─ source: ContentSource (bundled | remote | userCreated)
└─ lastFetched: Date?

PracticeCategory (enum)
├─ all
├─ briefing
├─ knots
├─ maneuvering
├─ mooring
└─ safety
```

#### Default Modules

| Module | Category | Type | Source |
|--------|----------|------|--------|
| Safety Briefing | Briefing | Document | Remote (GitHub) |
| Life on Yacht | Briefing | Document | Remote |
| First Aid Kit | Safety | Document | Remote |
| Going Ashore | Safety | Document | Remote |
| Mooring and Departure | Safety | Document | Remote |
| Round Turn & Two Half-Hitches | Knots | Document | Remote |
| Pre-Departure Checklist | Briefing | Checklist | Remote |
| Departure from Pier | Mooring | Document | Remote |
| Mediterranean Mooring | Mooring | Document | Remote |
| Anchoring | Mooring | Document | Remote |

#### Features

1. **Category Filtering**
   - Horizontal scrollable category chips
   - "All" shows complete catalog
   - Category-specific icons

2. **Content Rendering**
   - Markdown parsing with hierarchy support (H2–H4)
   - WikiLinks resolution
   - Bullet list formatting
   - Bold text styling
   - YAML frontmatter parsing

3. **Offline Caching**
   - Content cached after first fetch
   - Cache invalidation via ETag (future)
   - Manual refresh via pull-to-refresh

4. **Content Source**
   - GitHub integration with Captain's Locker repository
   - Obsidian markdown format support
   - Custom titles via WikiLinks

#### User Flow

```
PracticeView
├─ Header: "Practice" title + subtitle
├─ Category chips (horizontal scroll)
├─ 2-column grid of module cards:
│   └─ Tap → PracticeModuleDetailView
│       ├─ Title
│       ├─ Rendered markdown content
│       └─ Back navigation

Module Card Colors (by category):
├─ Briefing: relaxationCardColor (#F4A17C)
├─ Knots: recommendedCardRed (#F05D48)
├─ Maneuvering: basicsCardColor (#8E97FD)
├─ Mooring: recommendedCardGreen (#85D485)
└─ Safety: recommendedCardRed (#F05D48)
```

---

### 3.5 Learn (Flashcards)

**Purpose:** Spaced repetition learning for navigation rules, signals, lights, and maritime knowledge.

#### Data Model

```
FlashcardDeck
├─ id: UUID
├─ folderName: String (GitHub folder name)
├─ displayName: String (localized)
├─ description: String?
├─ flashcards: [Flashcard]
└─ lastFetched: Date?

Flashcard
├─ id: UUID
├─ fileName: String
├─ markdownContent: String
├─ deckID: FlashcardDeck.ID
├─ easeFactor: Double (SM-2, default 2.5)
├─ interval: Int (days until next review)
├─ repetitions: Int (successful review count)
├─ lastReviewed: Date?
├─ nextReview: Date?
└─ lastQuality: Int? (0-3)
└─ isDue: computed Bool

ReviewQuality (enum)
├─ again = 0 (forgot, repeat immediately)
├─ hard = 1 (difficult recall)
├─ good = 2 (normal recall)
└─ easy = 3 (effortless recall)
```

#### Spaced Repetition Algorithm (SM-2)

The app implements the SuperMemo 2 (SM-2) algorithm:

1. **Initial State:** easeFactor=2.5, interval=1, repetitions=0
2. **On Review:**
   - If quality ≥ 2: Increase repetitions, calculate new interval
   - If quality < 2: Reset repetitions to 0, interval to 1
3. **Interval Calculation:**
   - First success: interval = 1
   - Second success: interval = 6
   - Subsequent: interval = previous × easeFactor
4. **Ease Factor Adjustment:**
   - EF' = EF + (0.1 - (3 - quality) × (0.08 + (3 - quality) × 0.02))
   - Minimum EF = 1.3

#### Deck Configuration

Decks are fetched from GitHub directories:
- Sound Signals (звуковые сигналы)
- Navigation Lights (навигационные огни)
- COLREGs Rules (МППСС)
- Day Shapes (дневные фигуры)

#### Features

1. **Deck Browser**
   - Grid view of available decks
   - Card colors based on review status:
     - `basicsCardColor`: Cards due for review
     - `recommendedCardGreen`: All cards mastered
     - `relaxationCardColor`: No cards due

2. **Review Session**
   - Card-by-card presentation
   - Tap to reveal answer
   - Four response buttons (Again, Hard, Good, Easy)
   - Progress indicator (X of Y due)

3. **Statistics**
   - Due cards count
   - Mastered cards count
   - Total cards count
   - Per-deck and global stats

4. **Progress Persistence**
   - SRS progress saved locally (UserDefaults)
   - Deck IDs preserved across content refreshes
   - Progress survives app reinstall (future: iCloud sync)

#### User Flow

```
LearnView
├─ Header: "Learn" title + subtitle
├─ 2-column deck grid:
│   └─ FlashcardDeckCard
│       ├─ Deck name
│       ├─ Stats subtitle ("X due • Y cards")
│       └─ Tap → FlashcardReviewView

FlashcardReviewView
├─ Progress bar (X of Y)
├─ Card content (front or front+back)
├─ "Show Answer" button (tap to reveal)
├─ Response buttons (when revealed):
│   ├─ Again (red)
│   ├─ Hard (orange)
│   ├─ Good (green)
│   └─ Easy (purple)
└─ Session complete state
```

---

### 3.6 User Profile & Authentication

**Purpose:** Identity management, user type selection, and personalization.

#### Data Model

```
User
├─ id: UUID
├─ appleUserID: String
├─ email: String?
├─ displayName: String
├─ userType: UserType (captain | crew | traveler)
├─ communities: [Community]
├─ createdAt: Date
├─ lastUpdated: Date
├─ bio: String?
├─ experienceLevel: ExperienceLevel?
├─ certifications: [Certification]
├─ sailingHistory: [SailingExperience]
├─ reputation: Int
├─ contributionsCount: Int
└─ githubUsername: String? (for UGC)

ExperienceLevel (enum)
├─ beginner
├─ intermediate
├─ advanced
└─ expert

Certification
├─ id: UUID
├─ name: String
├─ issuingOrganization: String (RYA, IYT, etc.)
├─ issueDate: Date?
├─ expiryDate: Date?
└─ certificateNumber: String?

Community
├─ id: UUID
├─ name: String
├─ displayName: String
├─ description: String?
└─ icon: String?
```

#### Features

1. **Sign In with Apple**
   - Primary (and only) authentication method
   - Email and name extraction (if user permits)
   - Apple User ID stored for identity

2. **User Type Selection**
   - Captain, Crew, or Traveler
   - Affects future personalization (content recommendations)
   - Changeable after signup

3. **Profile Display**
   - Display name and email
   - User type with icon
   - Communities list
   - Experience level and certifications (if set)
   - Statistics (contributions, reputation)

4. **Settings**
   - Edit Profile
   - Sign Out
   - Delete Account

#### User Flow

```
ProfileView (not authenticated)
└─ SignInView
    ├─ App logo/branding
    ├─ Sign in with Apple button
    └─ Privacy note

ProfileView (authenticated)
├─ Profile header (avatar, name, email)
├─ User Type section (with edit)
├─ Communities section
├─ Experience section (if set)
├─ Statistics section
└─ Settings section
    ├─ Edit Profile
    ├─ Sign Out
    └─ Delete Account
```

---

## 4. Design System

### 4.1 Color Palette

#### Primary Colors

| Name | Hex | Usage |
|------|-----|-------|
| `lavenderBlue` | #8E97FD | Primary actions, selected states, tab bar highlight |
| `deepBlue` | #003366 | Deep nautical accents (future) |
| `skyBlue` | #80B3E6 | Secondary nautical accents |
| `sailWhite` | #FAFAFA | Light mode backgrounds |

#### Semantic Colors

| Name | Hex | Usage |
|------|-----|-------|
| `successGreen` | #33B34D | Success states, mastered items |
| `warningOrange` | #FF9900 | Warnings, "hard" difficulty |
| `dangerRed` | #CC3333 | Errors, destructive actions, "again" button |

#### Background Colors (Adaptive)

| Name | Light | Dark | Usage |
|------|-------|------|-------|
| `background` | #FAFAFA | #1C1C1E | Screen backgrounds |
| `secondaryBackground` | #F2F2F5 | #2C2C2E | Section backgrounds |
| `cardBackground` | #FFFFFF | #2C2C2E | Card surfaces |

#### Text Colors (Adaptive)

| Name | Light | Dark | Usage |
|------|-------|------|-------|
| `textPrimary` | #3F414E | #EBEBF5 | Main text |
| `textSecondary` | #A1A4B2 | #8C8C93 | Secondary text, captions |

#### Card Colors

| Name | Hex | Usage |
|------|-----|-------|
| `basicsCardColor` | #8E97FD | Featured cards, maneuvering modules |
| `relaxationCardColor` | #F4A17C | Briefing modules |
| `dailyThoughtBackground` | #333242 | Horizontal daily cards |
| `recommendedCardGreen` | #85D485 | Mooring modules, mastered state |
| `recommendedCardOrange` | #76C79E | Teal accent cards |
| `recommendedCardRed` | #F05D48 | Safety/knots modules |

### 4.2 Typography

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `largeTitle` | 34pt | Bold | Screen titles |
| `title1` | 28pt | Bold | Section headers |
| `title2` | 22pt | Semibold | Subsection headers |
| `title3` | 20pt | Semibold | Card titles (large) |
| `greeting` | 30pt | Bold | Home greeting |
| `greetingSubtitle` | 22pt | Regular | Home subtitle |
| `headline` | 17pt | Semibold | Emphasized body text |
| `body` | 17pt | Regular | Main content |
| `callout` | 16pt | Regular | Contextual notes |
| `subheadline` | 15pt | Regular | Supporting text |
| `footnote` | 13pt | Regular | Tertiary information |
| `caption` | 12pt | Regular | Small labels, timestamps |
| `caption2` | 11pt | Regular | Minimal text |
| `cardTitle` | 18pt | Semibold | Card titles |
| `cardSubtitle` | 12pt | Regular | Card descriptions |
| `button` | 17pt | Semibold | Button labels |
| `tabBar` | 10pt | Medium | Tab bar labels |

### 4.3 Spacing System

8-point grid system:

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4pt | Tight spacing, inline elements |
| `sm` | 8pt | Base unit, compact spacing |
| `md` | 16pt | Standard spacing, component gaps |
| `lg` | 24pt | Section spacing |
| `xl` | 32pt | Large gaps |
| `xxl` | 40pt | Extra large gaps |
| `xxxl` | 48pt | Maximum spacing |

#### Component-Specific

| Token | Value | Usage |
|-------|-------|-------|
| `cardPadding` | 20pt | Internal card padding |
| `cardSpacing` | 16pt | Gap between cards |
| `sectionSpacing` | 24pt | Gap between sections |
| `screenPadding` | 20pt | Horizontal screen margins |
| `buttonPadding` | 16pt | Button internal padding |
| `buttonHeight` | 50pt | Standard button height |
| `buttonHeightSmall` | 35pt | Small button height |
| `cardCornerRadius` | 25pt | Card corner radius |
| `buttonCornerRadius` | 25pt | Pill-shaped buttons |
| `tabBarHeight` | 88pt | Tab bar total height |

### 4.4 Component Library

#### Cards

| Component | Usage | Key Props |
|-----------|-------|-----------|
| `FeaturedCard` | Home active charter, CTA cards | backgroundColor, illustrationType, content |
| `GridCard` | 2-column grid items | title, subtitle, backgroundColor, textColor, illustrationType |
| `DailyCard` | Horizontal cards (like checklists) | title, subtitle, backgroundColor, showPlayButton |
| `MaritimeCard` | Generic card wrapper | style, backgroundColor, textColor, content |
| `RecommendedCard` | Small recommendation cards | backgroundColor, textColor, illustration, content |

#### Illustrations

| Type | Usage |
|------|-------|
| `basics` | Default/maneuvering modules |
| `relaxation` | Safety modules |
| `focus` | Briefing/knots modules |
| `dailyThought` | Maneuvering modules |

#### Controls

| Component | Usage |
|-----------|-------|
| `CategoryChip` | Filter categories in Practice view |
| `CustomTabBar` | Main navigation |
| `TabBarItem` | Individual tab items |

#### Feedback

| Component | Usage |
|-----------|-------|
| `FeedbackBanner` | Errors, warnings, info messages |
| `LoadingStateView` | Loading indicators |

### 4.5 Icons

SF Symbols (Apple system icons) used throughout:

| Context | Icons |
|---------|-------|
| Tab Bar | house.fill, book.fill, checklist, person.fill |
| User Types | person.fill.checkmark, person.2.fill, suitcase.fill |
| Categories | shield, figure.walk, arrow.triangle.2.circlepath, anchor |
| Actions | plus, pencil, trash, checkmark |
| Status | checkmark.circle.fill, exclamationmark.triangle.fill |

### 4.6 Accessibility

- Minimum contrast ratio: 4.5:1 for normal text
- Touch targets: ≥44pt minimum
- Dynamic Type: Font scaling support (future)
- VoiceOver: Semantic labels on interactive elements
- Color: Never sole means of conveying information

---

## 5. Localization

### Supported Languages

1. **Russian (ru)** – Primary language
2. **English (en)** – Fallback language

### Implementation

- Type-safe localization keys (`LocalizationKeys.swift`)
- Environment-based service (`LocalizationService`)
- Automatic system language detection
- Russian content includes English sailing terms for clarity

### Key Namespaces

```
L10n
├─ Common (save, cancel, edit, delete, error)
├─ Tab (home, learn, practice, profile)
├─ Greeting (morning, day, evening, night, subtitle)
├─ Charter (createCharter, editCharter, etc.)
├─ Checklist (title, sections, items)
├─ Practice (categories, modules)
├─ Learn (title, stats)
├─ Profile (userType, communities, settings)
├─ Auth (signIn, signOut)
└─ Error (generic, network, retry)
```

---

## 6. Architecture & Data Flow

### Architecture Pattern

**MVVM + Environment DI**

- SwiftUI views
- `@Observable` stores for state management
- Environment-based dependency injection
- Type-safe navigation via `AppPath` enum

### Data Persistence

| Data Type | Storage | Sync Strategy |
|-----------|---------|---------------|
| Charters | UserDefaults (Codable) | Local only (future: CloudKit) |
| Checklist State | UserDefaults (Codable) | Per-charter, local only |
| Flashcard Progress | UserDefaults (Codable) | Local only (future: CloudKit) |
| User Profile | UserDefaults (Codable) | Local only (future: Supabase) |
| Content Cache | UserDefaults (Codable) | Refresh from GitHub on demand |

### Content Pipeline

```
GitHub (Captain's Locker)
    ↓ (GitHub API, raw content)
ContentFetcher
    ↓ (String markdown)
MarkdownParser
    ↓ (Structured sections, resolved wikilinks)
ContentCache (UserDefaults)
    ↓
View Layer
```

### Navigation

```swift
enum AppPath: Hashable {
    case charterDetail(UUID)
    case charterEdit(UUID)
    case charterCreation
    case checkInChecklist(UUID)
    case practiceModule(String)
    case flashcardDeck(UUID)
}
```

### Store Architecture

| Store | Responsibilities |
|-------|------------------|
| `CharterStore` | Charter CRUD, active charter detection |
| `ChecklistStore` | Checklist templates, per-charter state |
| `FlashcardStore` | Deck management, SRS progress |
| `UserStore` | Authentication, profile management |
| `ContentFetcherStore` | Content cache state |

---

## 7. Technical Requirements

### Platform

- **OS:** iOS 18.0+
- **Framework:** SwiftUI
- **Language:** Swift 5.10+
- **IDE:** Xcode 16.0+

### Dependencies

Minimal external dependencies (pure Swift):
- No third-party package managers required
- GitHub API for content fetching (native URLSession)
- Apple Sign In framework (AuthenticationServices)

### Performance Targets

| Metric | Target |
|--------|--------|
| App launch | < 2s to interactive |
| Charter list load | < 1s (100 charters) |
| Checklist render | < 500ms (60+ items) |
| Markdown parsing | Off main thread |
| Memory footprint | < 100MB typical use |

### Offline Capabilities

| Feature | Offline Support |
|---------|-----------------|
| Charter management | ✅ Full |
| Checklist use | ✅ Full |
| Flashcard review | ✅ Full (cached decks) |
| Practice modules | ✅ Partial (cached content) |
| Profile view | ✅ Full |
| Content fetch | ❌ Requires network |

---

## 8. Testing Strategy

### Unit Tests

```
CharterStore
├─ test_create_charter_success
├─ test_update_charter_success
├─ test_delete_charter_success
├─ test_active_charter_detection
└─ test_charter_persistence

ChecklistStore
├─ test_load_default_checklist
├─ test_toggle_item
├─ test_add_user_note
├─ test_progress_calculation
└─ test_per_charter_isolation

FlashcardStore
├─ test_review_updates_srs_fields
├─ test_due_cards_calculation
├─ test_ease_factor_adjustment
└─ test_progress_persistence

MarkdownParser
├─ test_header_hierarchy
├─ test_wikilink_resolution
├─ test_bullet_list_formatting
└─ test_bold_text_styling
```

### UI Tests (Future)

```
Critical Flows
├─ test_create_charter_flow
├─ test_checkin_checklist_completion
├─ test_flashcard_review_session
├─ test_practice_module_navigation
└─ test_sign_in_sign_out_flow
```

---

## 9. Roadmap

### Phase 1: MVP Stabilization (Current)

- [x] Charter management
- [x] Check-in checklist
- [x] Practice modules
- [x] Flashcard learning
- [x] Basic user profiles
- [x] Localization (RU/EN)
- [ ] Error handling standardization
- [ ] Content caching improvements
- [ ] UI/UX polish (empty states, animations)
- [ ] Performance optimization

### Phase 2: Post-Release Enhancements

- [ ] CloudKit sync (Charters, SRS progress)
- [ ] Crew management (invite via Deep Link)
- [ ] Advanced logbook (GPS tracks, miles)
- [ ] Weather integration
- [ ] More languages
- [ ] Analytics (privacy-focused)
- [ ] Crash reporting
- [ ] Accessibility audit

### Phase 3: Future Ideas

- [ ] Community Charters Board (marketplace)
- [ ] Yacht & Company Reviews
- [ ] Defect Tracker
- [ ] Expense Splitter
- [ ] UGC system (in-app content editing)

---

## 10. Open Questions & Risks

### Product

1. **Content Strategy:**
   - How frequently should educational content be updated?
   - Should users be able to contribute/edit content?
   - Licensing for content used in flashcards?

2. **Monetization:**
   - Free tier vs. premium features?
   - Subscription model or one-time purchase?

3. **Localization:**
   - Which languages to prioritize after EN/RU?
   - Should all content be professionally translated?

### Technical

1. **Sync Strategy:**
   - CloudKit vs. custom backend for multi-device sync?
   - Conflict resolution for checklist state?

2. **Content Delivery:**
   - GitHub API rate limits at scale?
   - CDN for production content delivery?

3. **Offline-First:**
   - How to handle sync conflicts when coming back online?
   - Pre-download strategy for essential content?

### UX

1. **Onboarding:**
   - How to educate new users on app capabilities?
   - Should onboarding differ by user type?

2. **Checklist Customization:**
   - Should users be able to add/remove checklist items?
   - Template sharing between users?

---

## 11. Success Criteria

### MVP Launch

| Metric | Target |
|--------|--------|
| Crash-free sessions | > 99% |
| App Store rating | ≥ 4.5 |
| Checklist completion rate | > 70% of started checklists |
| Daily active users (D7 retention) | > 30% |

### 90-Day Post-Launch

| Metric | Target |
|--------|--------|
| Monthly active users | > 1,000 |
| Charters created | > 500 |
| Flashcard reviews | > 10,000 |
| Feature requests addressed | > 50% of top 10 |

---

## 12. Conclusion

Mothership addresses a genuine gap in the sailing software market by combining trip logistics, acceptance checklists, and educational content in a single, offline-capable iOS app. The phased approach—starting with core charter management and expanding to community features—allows validation at each stage before investing in complex infrastructure.

**Key success factors:**
1. **Offline Reliability:** Sailors often lack connectivity; the app must work flawlessly offline.
2. **Content Quality:** Educational material must be accurate, practical, and well-organized.
3. **Checklist Comprehensiveness:** The acceptance checklist is the core value proposition; it must cover all critical items.
4. **User Trust:** Sailors are safety-conscious; the app must feel professional and reliable.

The roadmap prioritizes stability and polish before expanding to community features, ensuring the foundation is solid before building a marketplace.
