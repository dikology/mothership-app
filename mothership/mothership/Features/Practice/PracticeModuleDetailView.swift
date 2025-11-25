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
    @State private var errorMessage: String?
    @State private var isUsingCache = false
    
    private var module: PracticeModule? {
        PracticeModule.defaultModules.first(where: { $0.id == moduleID })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.xl)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.warningOrange)
                        Text("Ошибка загрузки")
                            .font(AppTypography.title2)
                            .foregroundColor(AppColors.textPrimary)
                        Text(errorMessage)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(AppSpacing.screenPadding)
                } 
                else if let content = content {
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
        errorMessage = nil
        
        guard let module = module else {
            await MainActor.run {
                self.errorMessage = "Модуль не найден"
                self.isLoading = false
            }
            return
        }
        
        await loadArticleContent(module: module)
        
    }
    
    private func loadArticleContent(module: PracticeModule) async {
        let contentPath = determineContentPath(for: module)
        
        guard !contentPath.isEmpty else {
            errorMessage = "Контент для этого модуля еще не доступен"
            isLoading = false
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
                        // Show warning but don't block
                        self.errorMessage = "⚠️ \(error.userFriendlyMessage)\nПоказан кэшированный контент."
                    }
                    return
                }
            }
            
            await MainActor.run {
                self.errorMessage = error.userFriendlyMessage
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Не удалось загрузить контент:\n\(error.localizedDescription)"
                self.isLoading = false
            }
        }
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


// MARK: - Preview

struct PracticeModuleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PracticeModuleDetailView(moduleID: PracticeModule.defaultModules.first!.id)
        }
    }
}

