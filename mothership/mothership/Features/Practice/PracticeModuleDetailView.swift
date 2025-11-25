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
    @State private var content: MarkdownContent?
    @State private var isLoading = true
    @State private var currentError: AppError?
    @State private var messageKeys: [String] = []
    @State private var bannerSeverity: FeedbackSeverity?
    @State private var isUsingCache = false
    
    private var module: PracticeModule? {
        PracticeModule.defaultModules.first(where: { $0.id == moduleID })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                if isLoading {
                    LoadingStateView(message: nil, showsBackground: true)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
                
                if let severity = bannerSeverity, !bannerMessages.isEmpty {
                    FeedbackBanner(
                        severity: severity,
                        messages: bannerMessages,
                        action: bannerAction
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
                
                if let content = content, !isLoading {
                    // Title
                    if !content.title.isEmpty {
                        Text(content.title)
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal, AppSpacing.screenPadding)
                            .padding(.top, AppSpacing.md)
                    }
                    
                    // Sections
                    if !content.sections.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.lg) {
                            ForEach(Array(content.sections.enumerated()), id: \.offset) { index, section in
                                MarkdownSectionView(section: section, showPadding: true, showAttributedText: true)
                            }
                        }
                        .padding(.vertical, AppSpacing.md)
                    }
                }
            }
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadContent()
        }
    }
    
    private func loadContent() async {
        isLoading = true
        currentError = nil
        messageKeys = []
        bannerSeverity = nil
        
        guard let module = module else {
            await MainActor.run {
                self.messageKeys = [L10n.Error.moduleNotFound]
                self.bannerSeverity = .error
                self.isLoading = false
            }
            return
        }
        
        await loadArticleContent(module: module)
        
    }
    
    private func loadArticleContent(module: PracticeModule) async {
        let contentPath = determineContentPath(for: module)
        
        guard !contentPath.isEmpty else {
            await MainActor.run {
                self.messageKeys = [L10n.Error.contentUnavailable]
                self.bannerSeverity = .warning
                self.isLoading = false
            }
            return
        }
        
        do {
            // Try to fetch with cache first, fallback to cached if rate limited
            let markdown = try await ContentFetcher.fetchMarkdown(
                path: contentPath,
                useCache: true,
                forceRefresh: false
            )
            var parsedContent = MarkdownParser.parse(markdown, basePath: contentPath)
            
            if parsedContent.title.isEmpty {
                parsedContent = MarkdownContent(
                    title: module.title,
                    sections: parsedContent.sections,
                    images: parsedContent.images,
                    videos: parsedContent.videos,
                    animatedMedia: parsedContent.animatedMedia,
                    wikilinks: parsedContent.wikilinks,
                    metadata: parsedContent.metadata
                )
            }
            
            await MainActor.run {
                self.content = parsedContent
                self.isLoading = false
                self.isUsingCache = ContentCache.shared.hasCached(key: "markdown:\(contentPath)")
                self.currentError = nil
                self.messageKeys = []
                self.bannerSeverity = nil
            }
        } catch let error as ContentFetchError {
            // Handle rate limit gracefully - try to use cache
            if case .rateLimited = error {
                // Try to load from cache even if stale
                if let cachedData = ContentCache.shared.load(for: "markdown:\(contentPath)"),
                   let cachedMarkdown = String(data: cachedData, encoding: .utf8) {
                    var parsedContent = MarkdownParser.parse(cachedMarkdown, basePath: contentPath)
                    
                    if parsedContent.title.isEmpty {
                        parsedContent = MarkdownContent(
                            title: module.title,
                            sections: parsedContent.sections,
                            images: parsedContent.images,
                            videos: parsedContent.videos,
                            animatedMedia: parsedContent.animatedMedia,
                            wikilinks: parsedContent.wikilinks,
                            metadata: parsedContent.metadata
                        )
                    }
                    
                    await MainActor.run {
                        self.content = parsedContent
                        self.isLoading = false
                        self.isUsingCache = true
                        self.currentError = error.asAppError
                        self.messageKeys = [L10n.Error.cacheFallback]
                        self.bannerSeverity = .warning
                    }
                    return
                }
            }
            
            await MainActor.run {
                self.currentError = error.asAppError
                self.messageKeys = []
                self.bannerSeverity = .error
                self.isLoading = false
                self.content = nil
            }
        } catch {
            await MainActor.run {
                self.currentError = AppError.map(error)
                self.messageKeys = []
                self.bannerSeverity = .error
                self.isLoading = false
                self.content = nil
            }
        }
    }

    private var bannerMessages: [String] {
        var items: [String] = []
        if let currentError = currentError {
            items.append(currentError.localizedDescription(using: localization))
        }
        messageKeys.forEach { key in
            items.append(localization.localized(key))
        }
        return items
    }
    
    private var bannerAction: FeedbackAction? {
        guard bannerSeverity == .error else {
            return nil
        }
        return FeedbackAction(
            title: localization.localized(L10n.Error.retry),
            action: triggerReload
        )
    }

    private func determineContentPath(for module: PracticeModule) -> String {
        // Map module titles to GitHub paths
        switch module.title {
        case "Безопасность":
            return "безопасность/брифинг по безопасности.md"
        case "Жизнь на яхте":
            return "команда/жизнь на лодке.md"
        case "Подготовка к выходу":
            return "чеклисты/подготовка к выходу.md"
        default:
            // Try to construct path from category
            let categoryPath = module.category.localizedContentDirectory(using: localization)
            return "\(categoryPath)/\(module.title.lowercased()).md"
        }
    }
}

private extension PracticeModuleDetailView {
    func triggerReload() {
        Task {
            await loadContent()
        }
    }
}

// MARK: - Preview

struct PracticeModuleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PracticeModuleDetailView(moduleID: PracticeModule.defaultModules.first!.id)
        }
    }
}

