//
//  LearnView.swift
//  mothership
//
//  Learn section - Browse flashcard decks
//

import SwiftUI

struct LearnView: View {
    @Environment(\.localization) private var localization
    @Environment(\.flashcardStore) private var flashcardStore
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(localization.localized(L10n.Learn.learn))
                        .font(AppTypography.largeTitle)
                        .foregroundColor(AppColors.textPrimary)
                    Text(localization.localized(L10n.Learn.studyWithSpacedRepetition))
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.md)
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.dangerRed)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
                
                // Loading indicator
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
                
                // Decks Grid
                let columns = [
                    GridItem(.flexible(), spacing: AppSpacing.cardSpacing),
                    GridItem(.flexible(), spacing: AppSpacing.cardSpacing)
                ]
                
                LazyVGrid(columns: columns, spacing: AppSpacing.cardSpacing) {
                    ForEach(flashcardStore.decks) { deck in
                        NavigationLink(value: AppPath.flashcardDeck(deck.id)) {
                            FlashcardDeckCard(deck: deck)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.tabBarHeight)
            }
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadDecksIfNeeded()
        }
        .refreshable {
            await refreshDecks()
        }
    }
    
    private func loadDecksIfNeeded() async {
        // Only fetch if decks are empty
        guard flashcardStore.decks.isEmpty else { return }
        await refreshDecks()
    }
    
    private func refreshDecks() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Pass existing decks to preserve IDs and SRS progress
            let fetchedDecks = try await FlashcardFetcher.fetchAllDecks(
                using: localization,
                existingDecks: flashcardStore.decks
            )
            
            // Update store with fetched decks (preserves existing SRS progress)
            for deck in fetchedDecks {
                flashcardStore.updateDeck(deck)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to fetch decks: \(error)")
        }
    }
}

// MARK: - Flashcard Deck Card

struct FlashcardDeckCard: View {
    let deck: FlashcardDeck
    @Environment(\.flashcardStore) private var flashcardStore
    
    var stats: ReviewStats {
        flashcardStore.getReviewStats(for: deck.id)
    }
    
    var body: some View {
        GridCard(
            title: deck.displayName,
            subtitle: statsSubtitle,
            backgroundColor: backgroundColor,
            textColor: .white,
            illustrationType: .basics
        )
    }
    
    private var statsSubtitle: String {
        if stats.total == 0 {
            return "Загрузка..."
        }
        return "\(stats.due) к повторению • \(stats.total) карточек"
    }
    
    private var backgroundColor: Color {
        // Use different colors based on deck stats
        if stats.due > 0 {
            return AppColors.basicsCardColor
        } else if stats.mastered > 0 {
            return AppColors.recommendedCardGreen
        } else {
            return AppColors.relaxationCardColor
        }
    }
}

#Preview {
    LearnView()
        .environment(\.localization, LocalizationService())
        .environment(\.flashcardStore, FlashcardStore())
}

