//
//  PracticeModuleDetailView.swift
//  mothership
//
//  Detail view for learning modules with support for videos, images, and content
//

import SwiftUI

struct PracticeModuleDetailView: View {
    let moduleID: PracticeModule.ID
    @Environment(\.localization) private var localization
    @Environment(\.contentFetcherStore) private var contentFetcherStore
    
    private var module: PracticeModule? {
        PracticeModule.defaultModules(using: localization).first(where: { $0.id == moduleID })
    }
    
    private var contentState: ViewState<MarkdownContent> {
        contentFetcherStore.practiceContentState
    }
    
    var body: some View {
        Group {
            if let module {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                        if contentState.isLoading {
                            LoadingStateView(message: nil, showsBackground: true)
                                .padding(.horizontal, AppSpacing.screenPadding)
                        }
                        
                        if let severity = contentFetcherStore.practiceBannerSeverity,
                           !bannerMessages.isEmpty {
                            FeedbackBanner(
                                severity: severity,
                                messages: bannerMessages,
                                action: bannerAction
                            )
                            .padding(.horizontal, AppSpacing.screenPadding)
                        }
                        
                        if let content = contentState.data {
                            if !content.title.isEmpty {
                                Text(content.title)
                                    .font(AppTypography.largeTitle)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, AppSpacing.screenPadding)
                                    .padding(.top, AppSpacing.md)
                            }
                            
                            if !content.sections.isEmpty {
                                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                                    ForEach(Array(content.sections.enumerated()), id: \.offset) { _, section in
                                        MarkdownSectionView(
                                            section: section,
                                            showPadding: true,
                                            showAttributedText: true
                                        )
                                    }
                                }
                                .padding(.vertical, AppSpacing.md)
                            }
                        } else if contentState.isEmpty {
                            FeedbackBanner(
                                severity: .info,
                                messages: [localization.localized(L10n.Error.contentUnavailable)]
                            )
                            .padding(.horizontal, AppSpacing.screenPadding)
                        }
                    }
                }
            } else {
                ErrorStateView(
                    severity: .error,
                    title: localization.localized(L10n.Error.contentUnavailable),
                    message: localization.localized(L10n.Error.moduleNotFound)
                )
                .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadContent()
        }
    }
    
    private func loadContent() async {
        guard let module else { return }
        await contentFetcherStore.loadPracticeModule(module, localization: localization)
    }
}

private extension PracticeModuleDetailView {
    var bannerMessages: [String] {
        var items: [String] = []
        if let error = contentState.errorValue {
            items.append(error.localizedDescription(using: localization))
        }
        contentFetcherStore.practiceBannerMessageKeys.forEach { key in
            items.append(localization.localized(key))
        }
        return items
    }
    
    var bannerAction: FeedbackAction? {
        guard contentFetcherStore.practiceBannerSeverity == .error else {
            return nil
        }
        return FeedbackAction(
            title: localization.localized(L10n.Error.retry),
            action: triggerReload
        )
    }
    
    func triggerReload() {
        Task { await loadContent() }
    }
}

// MARK: - Preview

struct PracticeModuleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let localization = LocalizationService()
        NavigationStack {
            PracticeModuleDetailView(moduleID: PracticeModule.defaultModules(using: localization).first!.id)
                .environment(\.contentFetcherStore, ContentFetcherStore())
                .environment(\.localization, localization)
        }
    }
}
