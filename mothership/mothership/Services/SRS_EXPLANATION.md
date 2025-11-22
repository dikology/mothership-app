# How SRS (Spaced Repetition System) Works

## Overview

The SRS system uses the **SM-2 algorithm** (SuperMemo 2) to schedule flashcard reviews based on how well you remember each card.

## How It Works

### 1. **Initial State**
When you first see a flashcard:
- `repetitions = 0` (new card)
- `interval = 1` (due tomorrow)
- `easeFactor = 2.5` (default ease)
- `nextReview = tomorrow`

### 2. **Review Quality Ratings**

When you review a card, you rate it:
- **Again (0)**: Forgot it completely → Reset to beginning
- **Hard (1)**: Remembered but difficult → Small progress
- **Good (2)**: Remembered well → Normal progress
- **Easy (3)**: Very easy → Fast progress

### 3. **SRS Algorithm Updates**

After rating, the algorithm updates:

**If rated "Again" or "Hard" (< 2):**
- `repetitions = 0` (reset)
- `interval = 1` (due tomorrow)
- `easeFactor` decreases slightly

**If rated "Good" or "Easy" (≥ 2):**
- `repetitions += 1` (increment)
- `interval` increases:
  - First review: `interval = 1` day
  - Second review: `interval = 6` days
  - Third+ reviews: `interval = interval × easeFactor`
- `easeFactor` increases slightly

### 4. **Next Review Date**

`nextReview = today + interval days`

Cards are only shown when `nextReview <= today`.

## Data Persistence

### How Progress is Saved

1. **Deck Matching**: Decks are matched by `folderName` (e.g., "звуковые сигналы"), not by UUID
   - This ensures that when you refresh content from GitHub, your progress is preserved

2. **Flashcard Matching**: Flashcards are matched by `fileName` (e.g., "один короткий звук.md")
   - When new content is fetched, existing flashcards keep their SRS data
   - Only the markdown content is updated if it changed

3. **Storage**: All data is saved to `UserDefaults` with key `FlashcardStore.v1`
   - Saved automatically after each review
   - Loaded when app starts

### Why Progress Was Lost Before

**Previous Issue:**
- Each fetch created new UUIDs for decks and flashcards
- The system couldn't match new data with old progress
- Result: Progress was lost on refresh

**Fixed:**
- Decks matched by `folderName` (stable identifier)
- Flashcards matched by `fileName` (stable identifier)
- SRS data preserved when updating content

## Example Timeline

### Day 1: First Review
- Card: "один короткий звук"
- Rate: **Good**
- Result: `interval = 1`, `repetitions = 1`
- Next review: **Day 2**

### Day 2: Second Review
- Rate: **Good**
- Result: `interval = 6`, `repetitions = 2`
- Next review: **Day 8**

### Day 8: Third Review
- Rate: **Easy**
- Result: `interval = 15` (6 × 2.5), `repetitions = 3`, `easeFactor = 2.6`
- Next review: **Day 23**

### Day 23: Fourth Review
- Rate: **Good**
- Result: `interval = 39` (15 × 2.6), `repetitions = 4`
- Next review: **Day 62**

As you review successfully, intervals get longer, spacing out reviews for cards you know well.

## Review Statistics

The system tracks:
- **Total**: All cards in deck
- **Due**: Cards ready for review today
- **New**: Cards never reviewed (`repetitions = 0`)
- **Learning**: Cards reviewed 1-2 times
- **Mastered**: Cards reviewed 3+ times and not due

## Tips

1. **Be Honest**: Rate cards accurately - the algorithm depends on it
2. **Review Daily**: Check "Due" cards regularly
3. **Don't Skip**: If you rate "Again", the card will be due again soon
4. **Trust the System**: Longer intervals mean you're remembering well

