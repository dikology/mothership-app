# Product Requirements Document: Charters Section (Marketplace)

> **Parent Document:** [Product Requirements](/docs/product_requirements.md)  
> **Status:** Future Feature (Post-MVP)  
> **Dependencies:** Core Charter Management, User Profiles, Authentication

## Executive Summary

The **Charters Section** transforms Mothership from a solo captain's utility into a multi-user adventure marketplace. This feature extends the existing charter management capabilities documented in the main [Product Requirements](/docs/product_requirements.md).

Starting with **Phase 1: Captain's Dashboard**, captains review their own created charters in a dedicated hub. **Phase 2: Marketplace Discovery** enables crew and travelers to discover public charters, research captains and vessels, and request to join adventures. **Phase 3: Adventure Management** adds real-time tracking, mapping, and social discovery features.

This phased approach validates demand with minimal dependency on payment infrastructure while building the trust layer (profiles, reviews, verification) essential for a peer-to-peer marketplace.

**Note:** This feature builds on the existing `Charter`, `User`, `Checklist`, and design system components. All new UI should use the established `AppColors`, `AppTypography`, `AppSpacing`, and card components.

---

## 1. Problem Statement & Objectives

### Current State

Captains use Mothership to plan and manage single charters offline. Crew and travelers discover sailing opportunities through fragmented channels: Telegram groups, word-of-mouth.

### Problems Solved

| User | Problem | Solution |
|------|---------|----------|
| **Captain** | No centralized view of all past/future charters | Dedicated dashboard with timeline, past charters, and earnings insights |
| **Captain** | Difficulty filling empty berths on cost-share trips | Public charter listings with audience of crew and travelers |
| **Crew** | No structured way to find sailing opportunities | Searchable charter board filtered by location, dates, experience level |
| **Traveler** | Intimidated by sailing culture; unsure which captains to trust | Verified captain profiles with reviews, certifications, trip history |

### Success Metrics

- **Phase 1:** 80% of active captains use the Dashboard within 4 weeks of release.
- **Phase 2:** 30% of travelers complete at least one "Request to Join" application.
- **Phase 3:** 10% of published charters reach full capacity through in-app discovery.
- **Retention:** >50% of users who post a charter post a second one within 90 days.
- **Trust:** Average Captain Review score ≥ 4.5/5.0 across ≥50 reviews.

---

## 2. Scope by Phase

### Phase 1: Captain's Dashboard

**Goal:** Provide captains with a unified view of their charter history and upcoming trips.

#### Core Features

1. **Charter Timeline View**
   - Chronological list of all user-created charters (past and future).
   - Each charter shows: Boat name, location, dates, status badge (Draft, Scheduled, In Progress, Completed, Archived).
   - Quick action buttons: Edit, View Checklist, Archive.

2. **Charter Detail Card**
   - Vessel info (name, model, HIN).
   - Crew list (if any crew added manually).
   - Itinerary summary.
   - Checklist progress bar.
   - Notes/logs from previous instances.

3. **Statistics Dashboard**
   - Total charters organized (lifetime).
   - Hours logged / miles sailed (if available from data).
   - Upcoming charters (next 90 days).
   - Average crew satisfaction (placeholder for Phase 2 reviews).

4. **Quick Actions**
   - "+ Create Charter" button (existing feature, prominent placement).
   - "Archive Old Charters" bulk action.
   - "Export Charter History" (PDF or CSV).

#### Non-Goals for Phase 1

- Publishing charters to a public marketplace.
- Receiving join requests.
- Crew profiles or reviews.
- Payment or booking mechanics.

---

### Phase 2: Marketplace Discovery

**Goal:** Enable crew and travelers to discover and request charters; establish trust through profiles and reviews.

#### Core Features

1. **Adventure Board (Public Charter Listings)**
   - List view of published charters (captains opt into publishing).
   - Each card displays: Hero image, charter title, location, dates, price/person, crew capacity, experience level tag.
   - Filters: Region (Mediterranean, Caribbean, etc.), Date range, Price range, Experience level, Boat size.
   - Sort options: Newest, Soonest, Lowest price, Highest rating.

2. **Charter Detail Page (Public Listing)**
   - High-res gallery of boat and destination.
   - Itinerary map (Google Maps integration or custom sailing route map).
   - Boat specifications: Length, model, year, amenities checklist.
   - Captain bio card: Certifications, years sailing, trip count, average rating, short bio.
   - Crew list (anonymized until booking approved).
   - Pricing breakdown: Base cost, optional add-ons (meals, equipment rental, etc.).
   - "Request to Join" button (leads to application form).

3. **Captain Profiles**
   - Public profile with:
     - Full name, photo, bio (editable).
     - Certifications verified (RYA, IYT, etc.).
     - Sailing experience: Years sailing, miles logged, charters completed.
     - Reviews and ratings (average score, number of reviews, filterable by topic: Safety, Teaching, Vibe, Organization).
     - Verification badge if captain is ID-verified and background-checked.
   - Private dashboard:
     - Publish/unpublish individual charters.
     - Edit pricing and availability.
     - Manage join requests (approve, decline with feedback).

4. **Crew & Traveler Profiles**
   - Sailing experience level: None, Novice (0–10 trips), Competent (10+ trips), Instructor.
   - Preferences: Preferred sailing regions, trip duration, budget range, dietary restrictions.
   - Verification: Email confirmed, optional phone number.
   - Reviews received from captains (safety, contributions, compatibility).

5. **Join Request Workflow**
   - Traveler fills form: Name, experience level, dietary restrictions, questions for captain, optional bio.
   - Captain receives notification.
   - Captain reviews and approves/declines.
   - Approved applicant sees "Pending Payment" status (Phase 3).
   - Upon payment, status changes to "Booked" (both parties see in dashboard).

6. **Reviews System**
   - Review eligibility: Only after charter completion (end date passed).
   - Captain reviews crew member: Safety awareness, helpfulness, compatibility (1–5 stars each + text).
   - Crew/traveler reviews captain: Safety, teaching quality, vibe, organization (1–5 stars each + text, ≥50 characters).
   - Moderation: Community flagging, Admin dashboard to review flagged reviews.
   - Fake review detection: Flag reviews that seem automated or from new accounts.

7. **In-App Messaging**
   - Direct messages between captain and interested crew/traveler.
   - Replaces or complements email for coordination.
   - Notifications for new messages and join requests.

#### Non-Goals for Phase 2

- Payment processing (collect via Stripe later).
- Vessel/boat reviews (Phase 3).
- Scheduled automatic departures or real-time tracking.
- Integration with external sailing platforms (e.g., OpenCPN).

---

### Phase 3: Adventure Management & Social Discovery

**Goal:** Enhance the marketplace with real-time visibility, social proof, and operational tools for both captains and crew.

#### Core Features

1. **Live Charter Map**
   - Map of all charters in-progress during the selected week.
   - Show charter route, waypoints, current position (opt-in by captain).
   - Crew and friends can follow in real-time (pending privacy controls).
   - Notifications if charter reaches interesting waypoints (e.g., "Arriving in Santorini").

2. **Vessel Reviews & History**
   - Captains and crew can leave reviews tied to specific boat (by HIN or registration).
   - Reviews include: Condition, equipment quality, layout comfort, maintenance issues (1–5 stars + text).
   - Boat profile shows: Owner(s), service records (if available), history of reviews.

3. **Crew Marketplace**
   - Captains can post "Looking for Crew" listings separate from full charters.
   - Filtering by role: Navigator, Chef, Rigger, Deckhand, etc. (optional tags).
   - Similar request/approval workflow as charters.

4. **Social Proof & Gamification**
   - "Trending Charters" widget (most-favorited, most-reviewed).
   - Captain badges: "Verified," "5+ Charters," "Featured Instructor."
   - Crew badges: "Certified," "10+ Charters," "Helpful Crew."
   - Leaderboards (opt-in): Miles sailed, charters completed, reviews received.

5. **Trip Reports & Storytelling**
   - Post-charter optional feature: Share photos, journal entries, highlights from the adventure.
   - Appears on captain profile and charter detail page.
   - Crew can contribute photos/updates during the trip.

6. **Payment Integration**
   - Secure checkout for booking deposits or full payment.
   - Escrow protection (funds held until charter completion).
   - Refund policies per charter.
   - Captain earnings dashboard.

#### Non-Goals for Phase 3

- Crew skill certification system.
- Complex routing/weather APIs (lightweight integration only).
- Insurance or liability coordination.

---

## 3. User Experience & Design Guidelines

### Design Principles

1. **Trust-First Design**
   - Verification badges, review aggregates, and captain profiles are prominent on every listing.
   - Privacy controls are transparent (users know who can see their data).

2. **Progressive Disclosure**
   - Beginners see high-level info (cost, dates, captain name). Advanced users can toggle detailed specs (sail plans, technical equipment).

3. **Offline-First (Phase 1–2)**
   - Captain dashboard syncs charter data even with poor connectivity.
   - Public listings cache recent updates so browsing works offline.

4. **Mobile-First (Portrait & Landscape)**
   - All screens designed for iPhone 12–15 series (base case), tested on SE and iPad.
   - Horizontal scrolling avoided except for galleries.

### Key User Flows (Wireframe Descriptions)

#### Flow 1: Captain Dashboard (Phase 1)

**Tab Bar:** Home / Learn / Practice / Profile (existing)

**New:** Charters Dashboard accessed via Home tab or Profile

```
Charters Dashboard
├─ Header: "Your Charters" (title1) + "Create New" button (lavenderBlue)
├─ CategoryChip filter row: Upcoming / Past / All
├─ List view:
│  ├─ FeaturedCard per charter:
│  │   ├─ Status badge (color-coded):
│  │   │   ├─ Draft: textSecondary
│  │   │   ├─ Scheduled: lavenderBlue
│  │   │   ├─ In Progress: relaxationCardColor
│  │   │   ├─ Completed: recommendedCardGreen
│  │   ├─ Charter name (cardTitle), location (caption)
│  │   ├─ Date range (caption)
│  │   ├─ Quick actions row: Edit, Checklist, Archive (SF Symbols)
│  │   └─ Tap → CharterDetailView
│  └─ [Pagination / infinite scroll]
│
├─ Statistics panel (MaritimeCard, collapsible):
│  ├─ Total charters (lifetime)
│  ├─ Days sailed (aggregated from charter durations)
│  ├─ Upcoming charters count (next 90 days)
│  └─ Tap → Expanded analytics view
│
└─ Empty state:
   ├─ CardIllustration (basics type)
   ├─ "You haven't created a charter yet" (body)
   └─ FeaturedCard CTA: "+ Create Your First Charter"
```

#### Flow 2: Browse & Request Adventure (Phase 2 – Crew/Traveler)

**Tab Bar:** Home / Learn / Browse / Profile (Browse replaces Practice for marketplace users)

```
Browse Adventures
├─ Header: "Find an Adventure" (largeTitle)
├─ Search bar: TextField with search icon
├─ CategoryChip filter row (horizontal scroll):
│   ├─ Region chips (Mediterranean, Caribbean, etc.)
│   ├─ Experience Level chips
│   └─ Price Range chips
├─ Sort dropdown: Soonest / Nearest / Lowest Price / Highest Rated
├─ Grid view (2-column LazyVGrid, spacing: cardSpacing):
│  ├─ GridCard per adventure:
│  │   ├─ Hero image (AsyncImage with placeholder)
│  │   ├─ Title (cardTitle), location (caption)
│  │   ├─ Date range (caption2)
│  │   ├─ Price badge: "€X/person" (lavenderBlue background)
│  │   ├─ Captain row: Avatar (24pt) + name + verified badge (checkmark.seal.fill)
│  │   ├─ Rating: star.fill (anchorGold) + score + "(X reviews)"
│  │   └─ Tap → Adventure Detail
│  └─ [Infinite scroll with LoadingStateView]
│
└─ Adventure Detail Page:
   ├─ Image carousel (PageTabViewStyle)
   ├─ MaritimeCard: "Meet Captain {Name}":
   │   ├─ Large avatar (60pt)
   │   ├─ Name (title3), certifications badges
   │   ├─ Bio preview (body, 3 lines max)
   │   ├─ Rating summary: Stars + "X reviews"
   │   └─ "View Full Profile" button (lavenderBlue)
   ├─ MaritimeCard: Itinerary:
   │   ├─ Map view (MapKit)
   │   └─ Waypoint list
   ├─ MaritimeCard: Boat Specs:
   │   ├─ Model, Year, Length
   │   ├─ Amenities list (horizontal chips)
   │   └─ Accommodations
   ├─ MaritimeCard: Pricing:
   │   ├─ Price per person (title2, lavenderBlue)
   │   ├─ What's included list
   │   └─ Spots remaining: "X of Y spots left"
   ├─ DailyCard: "Request to Join" CTA (lavenderBlue)
   └─ Share button (square.and.arrow.up)
```

#### Flow 3: Captain Approves Join Request (Phase 2)

**Entry:** Profile tab → Notifications badge (dangerRed dot with count)

```
Notifications / Join Requests
├─ Header: "Join Requests" (title1) + filter chips (Pending / All)
├─ List view:
│  ├─ MaritimeCard per request:
│  │   ├─ Applicant row:
│  │   │   ├─ Avatar (44pt)
│  │   │   ├─ Name (headline)
│  │   │   ├─ Experience badge (CategoryChip style)
│  │   │   └─ Time ago (caption2, textSecondary)
│  │   ├─ Application text preview (body, 2 lines, textSecondary)
│  │   ├─ Charter reference: Icon + name (caption, lavenderBlue)
│  │   ├─ Action row:
│  │   │   ├─ "View" button (outline)
│  │   │   ├─ "Approve" button (successGreen)
│  │   │   └─ "Decline" button (dangerRed, outline)
│  │   └─ Tap → Full Request Detail
│  └─ Empty state: "No pending requests" + illustration
│
└─ Approved Crew View (separate section or tab):
   ├─ MaritimeCard per approved participant:
   │   ├─ Avatar + Name + Status badge:
   │   │   ├─ Approved: lavenderBlue
   │   │   ├─ Awaiting Payment: warningOrange (Phase 3)
   │   │   └─ Booked: successGreen (Phase 3)
   │   ├─ Contact: email (if shared)
   │   └─ "Message" button (paperplane.fill)
```

**Request Detail Modal:**
```
├─ Header: "Join Request" + Close button
├─ Applicant Profile Card:
│   ├─ Large avatar (80pt)
│   ├─ Name (title2)
│   ├─ Experience level + certifications
│   ├─ Bio (if available)
│   └─ Rating (if has prior reviews)
├─ Application Section:
│   ├─ "Why I want to join" (application text, full)
│   ├─ Cabin preference (if specified)
│   └─ Dietary restrictions (if specified)
├─ Charter Summary:
│   ├─ Charter name, dates
│   └─ Current crew count vs. max
└─ Actions (sticky footer):
   ├─ "Approve" button (successGreen, primary)
   └─ "Decline with Feedback" button (dangerRed, secondary)
       └─ Opens feedback input modal
```

### Design System & Accessibility

The Charters section follows the app-wide design system defined in `/docs/product_requirements.md`. Key references:

- **Color Palette:** Aligned with `AppColors`:
  - **Primary Action:** `lavenderBlue` (#8E97FD) – buttons, selected states, links
  - **Semantic Colors:**
    - `successGreen` (#33B34D) – approved status, positive actions
    - `warningOrange` (#FF9900) – pending status, warnings
    - `dangerRed` (#CC3333) – declined status, destructive actions
  - **Backgrounds:** Adaptive for Dark Mode
    - `background` – Light: #FAFAFA, Dark: #1C1C1E
    - `cardBackground` – Light: #FFFFFF, Dark: #2C2C2E
  - **Card Colors:** Use existing palette for status differentiation
    - `basicsCardColor` (#8E97FD) – Default charter cards
    - `recommendedCardGreen` (#85D485) – Completed/successful charters
    - `relaxationCardColor` (#F4A17C) – In-progress charters
    - `dailyThoughtBackground` (#333242) – Dark horizontal cards
- **Typography:** Uses `AppTypography` system (8pt base grid):
  - **Headings:** `title1` (28pt Bold), `title2` (22pt Semibold), `title3` (20pt Semibold)
  - **Body:** `body` (17pt Regular), `bodyBold` (17pt Semibold)
  - **Detail:** `caption` (12pt Regular), `caption2` (11pt Regular)
  - **Cards:** `cardTitle` (18pt Semibold), `cardSubtitle` (12pt Regular)
- **Spacing:** Based on `AppSpacing` (8pt grid):
  - `sm` (8pt), `md` (16pt), `lg` (24pt), `xl` (32pt)
  - `cardPadding` (20pt), `screenPadding` (20pt), `cardSpacing` (16pt)
  - `cardCornerRadius` (25pt), `buttonCornerRadius` (25pt)
- **Components:** Reuse existing card components:
  - `FeaturedCard` – Charter cards on dashboard
  - `GridCard` – Browse adventure grid items
  - `DailyCard` – Horizontal list items
  - `MaritimeCard` – Generic content cards
  - `CategoryChip` – Filter chips
- **Icons:** SF Symbols (consistent line weight):
  - Status: checkmark.circle.fill, clock.fill, xmark.circle.fill
  - Navigation: chevron.right, arrow.left
  - Actions: plus, pencil, trash, paperplane.fill
  - Profiles: person.fill, star.fill, checkmark.seal.fill
- **Accessibility:**
  - Minimum contrast ratio 4.5:1 for normal text
  - Interactive elements ≥44pt touch targets
  - All images have descriptive alt text (localized)
  - Form labels tied to inputs with accessibility labels
  - Color never sole means of conveying info (icons + text labels)
  - Status badges include both color and icon/text

---

## 4. Dependent Features & Data Model

**Note:** This section extends the core data models defined in `/docs/product_requirements.md`. The existing `Charter`, `User`, and related models form the foundation; marketplace features add new properties and entities.

### Data Model Overview

#### Existing Models (Extended for Marketplace)

```
Charter (Extended from Core)
├─ id: UUID                         // Existing
├─ name: String                     // Existing
├─ startDate: Date                  // Existing (maps to date_start)
├─ endDate: Date?                   // Existing (maps to date_end)
├─ location: String?                // Existing (maps to location_start)
├─ yachtName: String?               // Existing
├─ charterCompany: String?          // Existing
├─ notes: String?                   // Existing (maps to description)
├─ createdAt: Date                  // Existing
├─ isActive: computed Bool          // Existing
│
│  // NEW: Marketplace Extensions (Phase 2+)
├─ captainId: UUID?                 // FK → User (owner/organizer)
├─ boatId: UUID?                    // FK → Boat (detailed vessel info)
├─ title: String?                   // Public listing title (if different from name)
├─ description: String?             // Public description (extended)
├─ locationEnd: String?             // Destination (for point-to-point charters)
├─ maxCrew: Int?                    // Maximum participants
├─ pricePerPerson: Decimal?         // Cost share amount
├─ experienceLevel: CharterExperienceLevel? // Relaxed, Training, Mixed
├─ isPublished: Bool = false        // Opt-in to marketplace visibility
├─ status: CharterStatus            // Draft, Published, InProgress, Completed, Cancelled
├─ heroImages: [URL]?               // Public listing images
├─ checklistId: UUID?               // FK → Checklist (existing relationship)
├─ itineraryId: UUID?               // FK → Itinerary (future)
└─ updatedAt: Date?                 // Last modification
```

```
User (Extended from Core)
├─ id: UUID                         // Existing
├─ appleUserID: String              // Existing
├─ email: String?                   // Existing
├─ displayName: String              // Existing (maps to name)
├─ userType: UserType               // Existing (captain, crew, traveler)
├─ communities: [Community]         // Existing
├─ createdAt: Date                  // Existing
├─ lastUpdated: Date                // Existing
├─ bio: String?                     // Existing
├─ experienceLevel: ExperienceLevel? // Existing (maps to sailing_experience)
├─ certifications: [Certification]  // Existing
├─ sailingHistory: [SailingExperience] // Existing
├─ reputation: Int                  // Existing (placeholder)
├─ contributionsCount: Int          // Existing
├─ githubUsername: String?          // Existing (UGC)
│
│  // NEW: Marketplace Extensions (Phase 2+)
├─ avatarUrl: URL?                  // Profile photo
├─ phone: String?                   // Contact (optional)
├─ idVerified: Bool = false         // ID verification status
├─ backgroundChecked: Bool = false  // Background check status
├─ averageRating: Double?           // Aggregated from reviews
├─ reviewCount: Int = 0             // Total reviews received
└─ preferences: UserPreferences?    // Matching preferences
    └─ {regions, tripDurationRange, budgetRange, dietaryRestrictions}
```

#### New Entities (Phase 2+)

```
JoinRequest ← Phase 2
├─ id: UUID
├─ charterId: UUID                  // FK → Charter
├─ applicantId: UUID                // FK → User
├─ applicationText: String          // Personal message to captain
├─ status: JoinRequestStatus        // Pending, Approved, Declined, Booked
├─ captainFeedback: String?         // Feedback on decline (optional)
├─ cabinPreference: String?
├─ dietaryRestrictions: String?
├─ createdAt: Date
├─ approvedAt: Date?
└─ updatedAt: Date
```

```
Review ← Phase 2
├─ id: UUID
├─ revieweeId: UUID                 // FK → User (person being reviewed)
├─ reviewerId: UUID                 // FK → User (reviewer)
├─ charterId: UUID                  // FK → Charter (context)
├─ ratings: ReviewRatings           // Structured ratings
│   ├─ safety: Int? (1–5)
│   ├─ teaching: Int? (1–5)
│   ├─ vibe: Int? (1–5)
│   └─ organization: Int? (1–5)
├─ textContent: String              // ≥50 characters required
├─ isFlagged: Bool = false
├─ moderationNotes: String?
├─ createdAt: Date
└─ updatedAt: Date?
```

```
Boat (Extended from yachtName) ← Phase 3
├─ id: UUID
├─ captainId: UUID                  // FK → User (primary owner)
├─ name: String                     // Existing yachtName promoted
├─ model: String?
├─ year: Int?
├─ length: Double?                  // Meters
├─ beam: Double?                    // Meters
├─ hin: String?                     // Hull Identification Number (unique)
├─ amenities: [String]              // ["Hot Water", "Saloon TV", "Genset", ...]
├─ accommodations: [Accommodation]
│   └─ {bunkType, count}
├─ averageRating: Double?           // Aggregated from boat reviews
└─ reviewCount: Int = 0
```

```
Message ← Phase 2
├─ id: UUID
├─ senderId: UUID                   // FK → User
├─ recipientId: UUID                // FK → User
├─ threadContext: MessageContext?   // JoinRequest, Charter, General
├─ contextId: UUID?                 // ID of related entity
├─ body: String
├─ readAt: Date?
└─ createdAt: Date
```

#### Supporting Enums (Phase 2+)

```swift
enum CharterExperienceLevel: String, Codable {
    case relaxed    // Leisure sailing, minimal crew work
    case training   // Learning-focused, hands-on experience
    case mixed      // Combination of both
}

enum CharterStatus: String, Codable {
    case draft      // Not yet published
    case published  // Visible on marketplace
    case inProgress // Charter dates active
    case completed  // End date passed
    case cancelled  // Manually cancelled
}

enum JoinRequestStatus: String, Codable {
    case pending    // Awaiting captain review
    case approved   // Accepted, awaiting payment (Phase 3)
    case declined   // Rejected by captain
    case booked     // Payment complete (Phase 3)
}

enum MessageContext: String, Codable {
    case joinRequest
    case charter
    case general
}
```

### Dependent Features

The marketplace builds upon existing app infrastructure. See `/docs/product_requirements.md` for core feature specifications.

1. **User Profiles** (Phase 1.5) ✅ Partially Implemented
   - **Existing:** User model with `userType` (captain, crew, traveler), `experienceLevel`, `certifications`, `bio`
   - **Needed:** Editable profile UI, avatar upload, public profile view
   - **Gap:** Public profiles not yet exposed; avatar storage not implemented

2. **Authentication Upgrade** (Phase 2 prerequisite)
   - **Existing:** Sign in with Apple (local storage)
   - **Needed:** Cross-user auth backend (Supabase/Firebase Auth)
   - **Gap:** Users cannot currently discover each other; no central user directory
   - **Requirement:** Email verification for marketplace participants

3. **Image Storage & CDN** (Phase 2)
   - **Existing:** None (images not stored)
   - **Needed:** 
     - S3 or Supabase Storage for charter hero images, boat photos, avatars
     - CDN for global delivery
     - Client-side compression before upload
   - **Spec:** Max 5 images per charter, max 10MB each, JPEG/PNG/HEIC

4. **Real-Time Sync** (Phase 2–3)
   - **Existing:** Local-only data (UserDefaults)
   - **Needed:**
     - Supabase Realtime or Firebase Firestore for live updates
     - WebSocket for messaging
     - Push notification delivery
   - **Priority:** Join request notifications > messaging > charter updates

5. **Geolocation & Maps** (Phase 2–3)
   - **Existing:** Location stored as String (freeform)
   - **Needed:**
     - Google Maps API or MapKit for itinerary visualization
     - Geocoding service (location names → lat/lon)
     - Optional: Sailing-specific route display (waypoints)
   - **Note:** Consider MapBox for nautical chart overlays (Phase 3)

6. **Notifications** (Phase 2)
   - **Existing:** None
   - **Needed:**
     - APNs integration for push notifications
     - In-app notification center
     - Notification preferences (per-type opt-out)
   - **Priority notifications:**
     - Join request received (captain)
     - Join request status change (applicant)
     - New message
     - Charter start reminder (24h before)

7. **Analytics & Moderation** (Phase 2–3)
   - **Existing:** Basic logging (`AppLogger`)
   - **Needed:**
     - Privacy-focused analytics (TelemetryDeck or similar)
     - Admin dashboard for moderation
     - Review flagging and dispute workflow
     - Fraud detection (duplicate accounts, review patterns)

8. **Offline Sync Strategy** (Phase 2)
   - **Existing:** Offline-first for charters, checklists, flashcards
   - **Needed:**
     - Conflict resolution for marketplace data
     - Optimistic updates with rollback
     - Queue for actions taken offline (join requests, messages)
   - **Principle:** Core charter management must remain offline-capable

---

## 5. Implementation Phases

### Phase 1: Captain's Dashboard 

**Deliverables:**
1. UI for Charters tab within main app.
2. Backend endpoints:
   - `GET /charters?user_id=...` (list user's charters).
   - `GET /charter/:id` (fetch detail + associated data).
3. Local data sync (charters created offline persist on sync).
4. Statistics calculation (lifetime charters, hours logged).

**Dependencies:**
- Existing charter creation logic.
- Local database schema.

**Testing Scope:**
- Unit tests: Charter list filtering, sorting, statistics calculations.
- UI tests: Tab navigation, empty state, card rendering.
- Integration tests: Create charter → verify it appears in dashboard.

**Go-Live Criteria:**
- 90% of active captains see their charters displayed correctly.
- No performance regressions (list loads in <1s, even with 100+ charters).

---

### Phase 2: Marketplace Discovery & Requests 

**Deliverables:**
1. Backend schema: User profiles, JoinRequest, Review, Message tables.
2. Auth upgrade: Multi-user support (Supabase/Firebase).
3. API endpoints:
   - `POST /charters/:id/publish` (opt-in to marketplace).
   - `GET /marketplace/charters` (public list with filters).
   - `POST /join-requests` (submit application).
   - `POST /reviews` (post charter review).
   - `POST /messages` (send message to captain/crew).
4. UI:
   - Browse Adventures tab.
   - Captain profile pages (public + editable).
   - Join request flow & status tracking.
   - Review form & display.
   - Messaging interface.
5. Moderation tools: Admin dashboard for flagging, review validation.

**Dependencies:**
- Phase 1 complete.
- Cloud backend (Supabase or Firebase) operational.
- S3 or alternative for images.
- Email service for notifications & verification.

**Testing Scope:**
- Unit tests: Review aggregation, join request state machine, message queries.
- UI tests: Browse flow, filtering, application submission.
- Integration tests: Publish charter → appears in marketplace; request → captain receives notification.
- Load tests: 1000+ concurrent users browsing marketplace.
- Security tests: Cross-user authorization (crew can't approve their own join requests).

**Go-Live Criteria:**
- >50 captains publish a charter within first week.
- Zero unauthorized access incidents (auth tests pass 100%).
- Marketplace loads in <2s with filters applied.

---

### Phase 3: Advanced Features & Social 

**Deliverables:**
1. Real-time Charter Map (WebSocket, optional GPS tracking).
2. Boat/Vessel Reviews & history.
3. Crew Marketplace (separate job postings).
4. Social proof (trending charters, badges, leaderboards).
5. Payment integration (Stripe/PayPal escrow).
6. Trip Reports & media sharing (Phase 3B, optional).

**Dependencies:**
- Phase 2 complete and stable.
- Payment processor agreement (Stripe/PayPal).
- Maps API keys & quota.
- Advanced analytics infrastructure.

**Testing Scope:**
- Load tests: Real-time map with 100+ active charters.
- Payment tests: End-to-end checkout, refunds, dispute resolution.
- Security: PCI compliance for payment handling.
- Fraud detection: Automated review flagging (duplicate content, new account abuse).

**Go-Live Criteria:**
- >10% of charters reach full capacity through in-app bookings.
- Payment success rate >98%.
- Fewer than 5 fraud reports per 1000 transactions.

---

## 6. Open Questions & Risks

### Product & Business

1. **Monetization Model:**
   - Will Mothership take a commission on charters (e.g., 10–15%)?
   - Premium captain features (promoted listings, priority search placement)?
   - What is the fee/commission structure? How transparent?

2. **Geographic Scope & Localization:**
   - Launch in Mediterranean and Caribbean?
   - When to add other regions (South Pacific, Atlantic)?
   - Multi-language support needed from day one, or Phase 3?

3. **Pricing Strategy:**
   - Will in-app charter pricing be visible to competitors (other booking platforms)?
   - Price transparency vs. captain autonomy?

4. **Liability & Insurance:**
   - Does Mothership hold liability insurance for charters booked through the app?
   - Terms of service: Is the app merely a listing service (no liability), or active facilitator?
   - What happens if a charter cancels or a participant is injured?

5. **Crew Vetting:**
   - How is crew/traveler safety ensured before joining a captain?
   - Background check requirement? Photo verification?
   - Phased vetting: Email verification (Phase 2) → ID verification (Phase 3)?

### Technical

1. **Real-Time Sync Strategy:**
   - Supabase vs. Firebase vs. custom backend? (Decision impacts Phase 2 timeline.)
   - How to handle offline edits on captain side? Conflict resolution?

2. **Image Storage & Scaling:**
   - Will charters have 5+ hero photos, or just 1–2?
   - Compression & resizing needed to keep app size and bandwidth low.

3. **Maps Integration:**
   - Google Maps vs. MapBox vs. open-source (Leaflet)?
   - Cost at scale (especially for real-time charter tracking)?

4. **Review Spam & Moderation:**
   - Automated detection rules (new account, identical text, timing)?
   - Human review cycle for flagged content?
   - Escalation process for disputes between captain/crew?

5. **Data Privacy & GDPR:**
   - Captain bio, certifications, reviews: What's public vs. private?
   - Crew/traveler data: How long retained if they cancel?
   - GDPR compliance for EU users (charter routes, messages)?

### UX & Design

1. **Charter Status States:**
   - What happens to a charter if the captain dies or disappears mid-trip?
   - Can a traveler "cancel for cause" if the captain is unsafe?
   - Refund/dispute process clarity?

2. **Messaging:**
   - Is in-app messaging mandatory, or can captain/crew exchange outside the app?
   - If outside: How to handle disputes (no record in app)?

3. **Notifications:**
   - How aggressive should push notifications be? Risk of user opt-out.
   - Frequency caps to avoid notification fatigue?

4. **Customization:**
   - Should charters have multiple pricing tiers (e.g., "Basic" vs. "Deluxe" cabin)?
   - Or one price per charter, crew picks their own bunk?

### Market & Go-To-Market

1. **Captain Adoption:**
   - Will captains willingly publish charters to a semi-public marketplace?
   - Concerns: Liability, competition, loss of control over pricing?
   - Needs: Clear benefit communication, insurance clarity.

2. **Crew & Traveler Adoption:**
   - How to attract first crew members to an empty marketplace?
   - Consider: Influencer partnerships, sailing schools, waitlist.

3. **Network Effects:**
   - Chicken-and-egg problem: No crew → captains don't publish → no marketplace.
   - Mitigation: Early outreach to sailing clubs, instructor networks.

---

## 7. Testing Strategy

### Unit Tests

Charter Service
├─ test_charter_list_sorts_by_date_asc
├─ test_charter_list_filters_by_status
├─ test_statistics_calculation_lifetime_charters
├─ test_statistics_calculation_hours_logged
└─ test_charter_archive_marks_as_archived

User Profile Service
├─ test_profile_creation_with_certifications
├─ test_profile_update_bio_and_avatar
├─ test_verification_badge_logic (id_verified AND background_checked)
└─ test_user_type_restriction (can't change after X time)

Review Service
├─ test_review_aggregation_average_rating
├─ test_review_eligibility_after_charter_end_date
├─ test_review_min_length_validation (≥50 chars)
├─ test_review_flagging_workflow
└─ test_fake_review_detection (new account + similar text)

Join Request Service
├─ test_join_request_status_transitions
├─ test_captain_approval_workflow
├─ test_capacity_limit_prevents_approval
├─ test_duplicate_request_prevention
└─ test_applicant_experience_level_validation

### UI Tests (SwiftUI / XCTest)

Charters Dashboard
├─ test_tab_navigation_to_charters_dashboard
├─ test_empty_state_shown_for_new_captain
├─ test_charter_cards_display_correctly
├─ test_filter_by_status_works
├─ test_sort_by_date_works
├─ test_quick_actions_edit_button_navigates
├─ test_statistics_panel_expands_and_collapses
└─ test_long_list_performance (100+ charters)

Browse Adventures
├─ test_filter_toolbar_shows_all_filter_options
├─ test_apply_filter_updates_list
├─ test_adventure_card_layout_matches_design
├─ test_pagination_or_infinite_scroll_works
├─ test_search_filters_by_title_and_location
├─ test_hero_image_loads_and_renders
└─ test_loading_state_shown_during_fetch

Detail Page
├─ test_image_carousel_swipe_navigation
├─ test_map_renders_itinerary
├─ test_boat_specs_table_displays_correctly
├─ test_reviews_tab_shows_aggregated_rating
├─ test_join_button_enabled_if_spots_available
├─ test_join_button_disabled_if_full
└─ test_share_button_opens_share_menu

Captain Profile
├─ test_profile_page_loads_user_data
├─ test_certifications_display_with_verification_badges
├─ test_sailing_experience_summary_calculated
├─ test_reviews_filtered_by_topic
├─ test_edit_profile_for_captain_user
└─ test_view_only_for_non_captain

### Integration Tests

Charter Publishing Workflow
├─ test_captain_creates_draft_charter
├─ test_captain_publishes_charter_to_marketplace
├─ test_published_charter_appears_in_browse_listings
├─ test_unpublished_charter_removed_from_browse
└─ test_publish_validation_prevents_missing_fields

Join Request Workflow
├─ test_crew_submits_join_request
├─ test_captain_receives_notification
├─ test_captain_approves_request
├─ test_crew_sees_approved_status
├─ test_captain_declines_request_with_feedback
├─ test_declined_crew_notified
└─ test_duplicate_requests_prevented

Review Submission Workflow
├─ test_crew_submits_review_post_charter_end
├─ test_review_appears_on_captain_profile
├─ test_captain_review_aggregation_updates
├─ test_crew_cannot_review_uncompleted_charter
├─ test_captain_can_reply_to_review (Phase 3)
└─ test_flagged_review_removed_temporarily

Messaging Workflow
├─ test_captain_sends_message_to_applicant
├─ test_applicant_receives_notification
├─ test_applicant_replies_to_captain
├─ test_message_history_persists
└─ test_messages_cleared_after_user_deletion (GDPR)

### Performance Tests

Phase 1 Dashboard
├─ test_list_loads_in_<1s (100 charters)
├─ test_statistics_calculation_in_<500ms
├─ test_archive_action_in_<500ms
└─ test_no_memory_leaks_on_repeated_opens

Phase 2 Marketplace
├─ test_browse_list_loads_in_<2s (1000+ charters)
├─ test_filters_applied_in_<1s
├─ test_search_results_in_<1s
├─ test_map_renders_in_<3s
├─ test_concurrent_100_users_browsing
└─ test_no_crash_on_rapid_filter_changes

Real-Time Features (Phase 3)
├─ test_live_map_updates_in_<5s
├─ test_join_notification_delivered_in_<2s
├─ test_message_delivery_in_<1s
└─ test_websocket_reconnect_after_network_loss

### Security & Privacy Tests

Authorization
├─ test_crew_cannot_approve_own_join_request
├─ test_crew_cannot_view_captain_earnings_dashboard
├─ test_captain_cannot_view_other_captain_private_data
├─ test_traveler_cannot_message_random_captain
└─ test_profile_visibility_respects_privacy_settings

Payment (Phase 3)
├─ test_payment_data_not_logged_or_exposed
├─ test_refund_request_requires_valid_reason
├─ test_dispute_escalation_to_admin
└─ test_PCI_compliance_scan_passes

Data Privacy (GDPR)
├─ test_user_can_export_their_data
├─ test_user_can_delete_account_and_data
├─ test_deleted_account_messages_anonymized
├─ test_location_data_not_retained_beyond_90_days
└─ test_crew_data_cleared_if_charter_cancelled

---

## 8. Success Criteria & Metrics

### Phase 1 Go-Live (Captain's Dashboard)

| Metric | Target | Rationale |
|--------|--------|-----------|
| Captain dashboard adoption | >80% of active captains within 4 weeks | Validates core feature utility. |
| App performance | List renders <1s (100 charters) | Users expect snappy dashboards. |
| Data accuracy | 100% of charters display correctly | Trust-breaking if data wrong. |
| Feature completion | 0 critical bugs at launch | Sets tone for marketplace launch. |

### Phase 2 Go-Live (Marketplace & Requests)

| Metric | Target | Rationale |
|--------|--------|-----------|
| Captain publish rate | >50 charters published in week 1 | Validates captain willingness to list. |
| Browse usage | >1000 unique browse sessions in week 1 | Indicates crew/traveler interest. |
| Join request rate | >10 requests by end of week 2 | Early signal of conversion. |
| Request approval rate | >70% captain approval rate | Validates matching algorithm / application quality. |
| Review completion rate | >40% of completed charters reviewed | Establishes trust layer. |
| Average review rating | ≥4.5/5 (if ≥50 reviews) | Ensures positive user sentiment. |
| Auth reliability | 99.9% uptime | Marketplace depends on login. |
| Marketplace latency | Listings load in <2s | Performance threshold for user retention. |
| Fraud detection | <5 fraudulent accounts per 1000 signups | Keeps marketplace trustworthy. |
| User support tickets | <2% of users open support ticket | Indicates UX clarity. |

### Phase 3 Go-Live (Maps, Payment, Social)

| Metric | Target | Rationale |
|--------|--------|-----------|
| Capacity fulfillment | >10% of charters reach full capacity via app | Payment integration + marketplace driving bookings. |
| Payment success rate | >98% transaction completion | Minimizes lost revenue to failed checkouts. |
| Refund dispute rate | <1% of transactions disputed | Indicates captain/crew satisfaction. |
| Real-time map adoption | >30% of captains opt into real-time tracking | Social proof & engagement. |
| Vessel review count | >500 reviews (across all boats) | Establishes boat-level trust data. |
| Crew marketplace usage | >20% of charters post crew-only listings | Validates separate marketplace feature. |
| Monthly active users | >5000 (charter platform alone) | Growth signal. |
| User retention (90 days) | >50% of users who book once, book again | Repeat-booking metric. |

---

## 9. Risk Mitigation

### Risk: Low Captain Adoption of Publishing

**Likelihood:** Medium | **Impact:** High (marketplace dies without supply)

**Mitigation:**
- Phase 2a (pre-launch): Outreach to 20 pilot captains, get written commitment to publish.
- In-app education: Tutorial on "Why publish" (reach more crew, fill empty berths, build reputation).
- Captain incentives: First 100 charters published → featured listing (no commission charge).
- Alternative: Allow crew to post on behalf of captain (for share).

---

### Risk: Toxic Reviews & Moderation Overload

**Likelihood:** Medium | **Impact:** Medium (erodes marketplace trust)

**Mitigation:**
- Phase 2: Implement automated flagging (new account + harsh language).
- Require review ≥50 characters (filters low-effort abuse).
- Community flagging: Users report inappropriate reviews.
- Phase 3: Hire 2–3 part-time moderators for review cycles.
- Clear appeals process: Captain can dispute review, respond publicly.

---

### Risk: Payment Processing Delays / Failures

**Likelihood:** Low | **Impact:** High (lost revenue, user frustration)

**Mitigation:**
- Phase 3: Extensive Stripe API testing before launch.
- Implement retry logic (automatic rebill after transient failure).
- Clear error messaging: Tell user exact reason for failure (e.g., "Card declined by issuer").
- Escrow holding: Funds held until charter completion, not captain payout day-1 (reduces risk if charter cancelled).
- Fallback: Manual invoice option (captain sends invoice, crew pays out-of-app, then confirms in app).

---

### Risk: GDPR / Privacy Violations

**Likelihood:** Low | **Impact:** Critical (regulatory fines, app removal)

**Mitigation:**
- Phase 2: Legal review of data handling (messages, location, reviews).
- Privacy policy clear & concise.
- Implement user data export (GDPR Article 20) in Phase 2.
- Implement user deletion in Phase 2 (data anonymized or removed).
- No location tracking without explicit opt-in.
- Data retention policy: Delete inactive account data after 2 years.

---

### Risk: Duplicate Bookings or Overbooking

**Likelihood:** Medium | **Impact:** Medium (customer satisfaction issue)

**Mitigation:**
- Capacity counter is atomic (database transaction).
- When charter reaches max capacity, "Request to Join" button disables immediately.
- Pre-flight check: When captain approves join request, re-check capacity (prevent approval if now full).
- Clear messaging: If user attempts to join full charter, show waitlist option.

---

### Risk: Slow Marketplace Scaling

**Likelihood:** Low | **Impact:** Medium (missed growth window)

**Mitigation:**
- Phase 2 backend: Use PostgreSQL (Supabase) with proper indexing on charter filters (location, date, price).
- Load testing in staging before launch: Simulate 10k concurrent users.
- CDN for images: Lazy load charter hero photos.
- Pagination or infinite scroll (not load all 10k charters at once).
- Cache strategy: Cache "trending charters" for 1 hour, user-specific lists for 5 mins.

---

## 10. Roadmap & Timeline

Phase 1: Captain's Dashboard
├─ Weeks 1–2: Design & spec finalization
├─ Weeks 3–6: Core implementation (UI + backend)
├─ Weeks 7–8: Testing & QA
└─ Late January: Public beta with 10 pilot captains

Phase 2: Marketplace Discovery
├─ Weeks 1–4: Auth upgrade & user profile infrastructure
├─ Weeks 5–10: Marketplace UI, charter publishing, join requests
├─ Weeks 11–14: Reviews, messaging, moderation tools
├─ Late May: Closed beta (50 captains + 200 crew/travelers)
└─ Early June: Public launch

Phase 3a: Live Tracking & Payment
├─ Weeks 1–4: Payment integration (Stripe) & testing
├─ Weeks 5–8: Real-time charter map (websockets)
├─ Weeks 9–12: Vessel reviews & crew marketplace
├─ Late August: Phase 3a launch

Phase 3b: Social & Polish
├─ Trip reports & storytelling
├─ Gamification (badges, leaderboards)
├─ Analytics dashboard for captains
├─ International expansion (phase 1)
└─ 2027 roadmap planning

---

## 11. Conclusion

The **Charters Section** transforms Mothership from a personal utility into a vibrant, trust-based marketplace for sailing adventures. By rolling out in three phased stages—starting with captain-centric tools, then marketplace discovery, and finally advanced features—we validate each layer before over-investing in infrastructure. 

**Critical success factors:**
1. **Trust:** Verified profiles, transparent reviews, and clear safety policies are non-negotiable.
2. **Network effects:** Early outreach to sailing communities to bootstrap the supply-demand loop.
3. **Clarity:** Transparent monetization, liability, and refund policies to avoid legal / reputational risks.
4. **Iteration:** Close monitoring of early adopters, rapid response to friction, and willingness to pivot features if data shows lower-than-expected adoption.

Success in Phase 1 validates the captain dashboard. Success in Phase 2 validates the marketplace. Success in Phase 3 validates scalability and payment mechanics. Each gate must be met before proceeding to the next.