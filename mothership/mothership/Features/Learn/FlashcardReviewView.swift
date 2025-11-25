//
//  FlashcardReviewView.swift
//  mothership
//
//  Flashcard review interface with SRS
//

import SwiftUI

struct FlashcardReviewView: View {
    let deckID: FlashcardDeck.ID
    
    @Environment(\.localization) private var localization
    @Environment(\.flashcardStore) private var flashcardStore
    @Environment(\.dismiss) var dismiss
    
    @State private var currentIndex = 0
    @State private var showingCompletion = false
    
    private var deck: FlashcardDeck? {
        flashcardStore.getDeck(id: deckID)
    }
    
    private var dueCards: [Flashcard] {
        flashcardStore.getDueFlashcards(for: deckID)
    }
    
    private var currentCard: Flashcard? {
        guard currentIndex < dueCards.count else { return nil }
        return dueCards[currentIndex]
    }
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            if showingCompletion {
                completionView
            } else if let card = currentCard {
                cardReviewView(card: card)
            } else {
                emptyStateView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                if let deck = deck {
                    Text(deck.displayName)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if !dueCards.isEmpty {
                    Text("\(currentIndex + 1)/\(dueCards.count)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Card Review View
    
    private func cardReviewView(card: Flashcard) -> some View {
        VStack(spacing: AppSpacing.lg) {
            // Progress indicator
            ProgressView(value: Double(currentIndex), total: Double(dueCards.count))
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.lavenderBlue))
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.md)
            
            Spacer()
            
            // Flashcard
            FlashcardView(card: card)
                .padding(.horizontal, AppSpacing.screenPadding)
            
            Spacer()
            
            // Quality buttons (always visible)
            qualityButtons
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.lg)
        }
    }
    
    // MARK: - Quality Buttons
    
    private var qualityButtons: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                QualityButton(
                    quality: .again,
                    action: { rateCard(.again) }
                )
                QualityButton(
                    quality: .hard,
                    action: { rateCard(.hard) }
                )
            }
            
            HStack(spacing: AppSpacing.sm) {
                QualityButton(
                    quality: .good,
                    action: { rateCard(.good) }
                )
                QualityButton(
                    quality: .easy,
                    action: { rateCard(.easy) }
                )
            }
        }
    }
    
    private func rateCard(_ quality: ReviewQuality) {
        guard let card = currentCard else { return }
        
        // Update flashcard with review quality
        flashcardStore.updateFlashcard(card, quality: quality)
        
        // Move to next card
        withAnimation(.easeInOut) {
            if currentIndex < dueCards.count - 1 {
                currentIndex += 1
            } else {
                showingCompletion = true
            }
        }
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.successGreen)
            
            Text(localization.localized(L10n.Learn.reviewComplete))
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)
            
            Text(localization.localized(L10n.Learn.greatJob))
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text(localization.localized(L10n.Common.done))
                    .font(AppTypography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.lavenderBlue)
                    .cornerRadius(AppSpacing.buttonCornerRadius)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.lg)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.successGreen)
            
            Text(localization.localized(L10n.Learn.noCardsDue))
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(localization.localized(L10n.Learn.allCardsReviewed))
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text(localization.localized(L10n.Common.done))
                    .font(AppTypography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.lavenderBlue)
                    .cornerRadius(AppSpacing.buttonCornerRadius)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.lg)
        }
    }
}

// MARK: - Flashcard View

struct FlashcardView: View {
    let card: Flashcard
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                .fill(AppColors.cardBackground)
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 10,
                    x: 0,
                    y: 5
                )
            
            // Content
            VStack(spacing: AppSpacing.md) {
                // Title
                Text(card.displayTitle)
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.md)
                
                Divider()
                    .padding(.horizontal, AppSpacing.md)
                
                // Markdown content
                ScrollView {
                    MarkdownContentView(flashcard: card)
                        .padding(.horizontal, AppSpacing.md)
                }
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 400)
    }
}

// MARK: - Markdown Content View

struct MarkdownContentView: View {
    let flashcard: Flashcard
    
    var body: some View {
        // Use cached parsed content (parsed once when fetched)
        let parsed = FlashcardParsedContentCache.shared.getParsedContent(for: flashcard)
        
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Display sections
            ForEach(parsed.sections.indices, id: \.self) { index in
                let section = parsed.sections[index]
                MarkdownSectionView(section: section, showPadding: false, showAttributedText: true)
            }
        }
    }
}


// MARK: - Quality Button

struct QualityButton: View {
    let quality: ReviewQuality
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                Text(quality.displayName)
                    .font(AppTypography.caption)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(quality.color)
            .cornerRadius(AppSpacing.buttonCornerRadius)
        }
    }
    
    private var iconName: String {
        switch quality {
        case .again: return "arrow.counterclockwise"
        case .hard: return "exclamationmark.triangle"
        case .good: return "checkmark"
        case .easy: return "star.fill"
        }
    }
}

#Preview {
    NavigationStack {
        FlashcardReviewView(deckID: UUID())
            .environment(\.localization, LocalizationService())
            .environment(\.flashcardStore, FlashcardStore())
    }
}

