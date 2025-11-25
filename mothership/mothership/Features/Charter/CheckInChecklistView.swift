//
//  CheckInChecklistView.swift
//  mothership
//
//  Check-in checklist view for charter acceptance
//

import SwiftUI

struct CheckInChecklistView: View {
    let charterId: UUID
    
    @Environment(\.localization) private var localization
    @Environment(\.checklistStore) private var checklistStore
    @State private var checklist: Checklist?
    @State private var expandedSections: Set<UUID> = []
    @State private var expandedSubsections: Set<UUID> = []
    
    private var checklistState: ViewState<[Checklist]> {
        checklistStore.checklistState
    }
    
    var body: some View {
        ScrollView {
            if let checklist = checklist {
                VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                    // Header
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(checklist.title)
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                        Text(localization.localized(L10n.Checklist.checkAllItemsWhenReceivingYacht))
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, AppSpacing.md)
                    
                    // Progress indicator
                    if let progress = calculateProgress() {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            HStack {
                                Text(localization.localized(L10n.Checklist.progress))
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Text("\(Int(progress * 100))%")
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.lavenderBlue)
                            }
                            ProgressView(value: progress)
                                .tint(AppColors.lavenderBlue)
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppSpacing.cardCornerRadius)
                        .padding(.horizontal, AppSpacing.screenPadding)
                    }
                    
                    // Sections
                    ForEach(checklist.sections) { section in
                        ChecklistSectionView(
                            section: section,
                            isExpanded: expandedSections.contains(section.id),
                            expandedSubsections: $expandedSubsections,
                            onToggleExpand: {
                                if expandedSections.contains(section.id) {
                                    expandedSections.remove(section.id)
                                } else {
                                    expandedSections.insert(section.id)
                                }
                            },
                            onToggleItem: { itemId in
                                checklistStore.toggleItem(for: charterId, checklistId: checklist.id, itemId: itemId)
                                updateChecklist()
                            },
                            onUpdateNote: { itemId, note in
                                checklistStore.updateItemNote(for: charterId, checklistId: checklist.id, itemId: itemId, note: note)
                                updateChecklist()
                            }
                        )
                    }
                }
                .padding(.bottom, AppSpacing.xl)
            } else if checklistState.isLoading {
                LoadingStateView(message: nil, showsBackground: true)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, AppSpacing.lg)
            } else if let error = checklistState.errorValue {
                FeedbackBanner(
                    severity: .error,
                    messages: [error.localizedDescription(using: localization)],
                    action: FeedbackAction(
                        title: localization.localized(L10n.Error.retry),
                        action: reloadChecklist
                    )
                )
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)
            } else {
                FeedbackBanner(
                    severity: .info,
                    messages: [localization.localized(L10n.Error.contentUnavailable)]
                )
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)
            }
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadChecklist()
        }
    }
    
    private func loadChecklist() {
        checklistStore.markChecklistsLoading()
        let loadedChecklist = checklistStore.getCheckInChecklist(for: charterId)
        checklist = loadedChecklist
        if loadedChecklist != nil {
            checklistStore.markChecklistsLoaded()
        } else {
            checklistStore.markChecklistsError(.content(.notFound))
        }
    }
    
    private func updateChecklist() {
        checklist = checklistStore.getCheckInChecklist(for: charterId)
    }
    
    private func reloadChecklist() {
        loadChecklist()
    }
    
    private func calculateProgress() -> Double? {
        guard let checklist = checklist else { return nil }
        return checklistStore.calculateProgress(for: checklist)
    }
}

// MARK: - Checklist Section View

struct ChecklistSectionView: View {
    let section: ChecklistSection
    let isExpanded: Bool
    @Binding var expandedSubsections: Set<UUID>
    let onToggleExpand: () -> Void
    let onToggleItem: (UUID) -> Void
    let onUpdateNote: (UUID, String?) -> Void
    
    @Environment(\.localization) private var localization
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            Button(action: onToggleExpand) {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(section.title)
                            .font(AppTypography.sectionTitle)
                            .foregroundColor(AppColors.textPrimary)
                        Text("\(section.items.count) \(localization.localized(L10n.Checklist.items))")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.textSecondary)
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(AppSpacing.md)
                .background(AppColors.cardBackground)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Subsections
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(section.subsections) { subsection in
                        ChecklistSubsectionView(
                            subsection: subsection,
                            isExpanded: expandedSubsections.contains(subsection.id),
                            onToggleExpand: {
                                if expandedSubsections.contains(subsection.id) {
                                    expandedSubsections.remove(subsection.id)
                                } else {
                                    expandedSubsections.insert(subsection.id)
                                }
                            },
                            onToggleItem: onToggleItem,
                            onUpdateNote: onUpdateNote
                        )
                    }
                }
                .background(AppColors.secondaryBackground)
            }
        }
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(
            color: Color.black.opacity(AppSpacing.cardShadowOpacity),
            radius: AppSpacing.cardShadowRadius,
            x: 0,
            y: 2
        )
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

// MARK: - Checklist Subsection View

struct ChecklistSubsectionView: View {
    let subsection: ChecklistSubsection
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onToggleItem: (UUID) -> Void
    let onUpdateNote: (UUID, String?) -> Void
    
    @Environment(\.localization) private var localization
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Show subsection header only if it has a title
            if !subsection.title.isEmpty {
                Button(action: onToggleExpand) {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(subsection.title)
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)
                            Text("\(subsection.items.count) \(localization.localized(L10n.Checklist.items))")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up.circle" : "chevron.down.circle")
                            .foregroundColor(AppColors.lavenderBlue)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.cardBackground.opacity(0.5))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Subsection Items
            if isExpanded || subsection.title.isEmpty {
                ForEach(subsection.items) { item in
                    ChecklistItemRowView(
                        item: item,
                        onToggle: { onToggleItem(item.id) },
                        onUpdateNote: { note in onUpdateNote(item.id, note) }
                    )
                }
            }
        }
    }
}

// MARK: - Checklist Item Row View

struct ChecklistItemRowView: View {
    let item: ChecklistItem
    let onToggle: () -> Void
    let onUpdateNote: (String?) -> Void
    
    @Environment(\.localization) private var localization
    @State private var isExpanded = false
    @State private var userNoteText: String = ""
    @FocusState private var isNoteFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                // Checkbox
                Button(action: onToggle) {
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isChecked ? AppColors.lavenderBlue : AppColors.textSecondary)
                        .font(.system(size: 24, weight: .medium))
                }
                .buttonStyle(.plain)
                
                // Title and note
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(item.title)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                        .strikethrough(item.isChecked)
                        .opacity(item.isChecked ? 0.6 : 1.0)
                    
                    if !isExpanded {
                        if let note = item.note, !note.isEmpty {
                            Text(note)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(2)
                        }
                        
                        if let userNote = item.userNote, !userNote.isEmpty {
                            Text(userNote)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.lavenderBlue)
                                .italic()
                                .lineLimit(2)
                        }
                    }
                }
                
                Spacer()
                
                // Expand button (if note exists or can add user note)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.textSecondary)
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.plain)
            }
            .padding(AppSpacing.md)
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Divider()
                        .padding(.horizontal, AppSpacing.md)
                    
                    // Static note
                    if let note = item.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(localization.localized(L10n.Checklist.information))
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                                .textCase(.uppercase)
                            
                            Text(note)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal, AppSpacing.md)
                    }
                    
                    // User notes section
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(localization.localized(L10n.Checklist.yourNotes))
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .textCase(.uppercase)
                        
                        TextField(localization.localized(L10n.Checklist.addNote), text: $userNoteText, axis: .vertical)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(AppSpacing.sm)
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                            .focused($isNoteFocused)
                            .lineLimit(3...6)
                            .onChange(of: userNoteText) { oldValue, newValue in
                                onUpdateNote(newValue.isEmpty ? nil : newValue)
                            }
                    }
                    .padding(.horizontal, AppSpacing.md)
                }
                .padding(.bottom, AppSpacing.md)
            }
        }
        .background(AppColors.secondaryBackground)
        .onAppear {
            userNoteText = item.userNote ?? ""
        }
        .onChange(of: item.userNote) { oldValue, newValue in
            if userNoteText != (newValue ?? "") {
                userNoteText = newValue ?? ""
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CheckInChecklistView(charterId: UUID())
            .environment(\.checklistStore, ChecklistStore())
    }
}

