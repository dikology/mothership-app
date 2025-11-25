//
//  ContentFetcherStore.swift
//  mothership
//
//  ViewState-driven facade over ContentFetcher for Practice modules
//

import Foundation

@Observable
final class ContentFetcherStore {
    private let cache = ContentCache.shared
    
    private(set) var practiceContentState: ViewState<MarkdownContent> = .idle
    private(set) var practiceBannerSeverity: FeedbackSeverity?
    private(set) var practiceBannerMessageKeys: [String] = []
    private(set) var currentContentPath: String?
    
    // MARK: - Practice Module Loading
    
    func loadPracticeModule(_ module: PracticeModule, localization: LocalizationService) async {
        await MainActor.run {
            practiceContentState = .loading
            practiceBannerSeverity = nil
            practiceBannerMessageKeys = []
            currentContentPath = determineContentPath(for: module, localization: localization)
        }
        
        guard let contentPath = await currentContentPath, !contentPath.isEmpty else {
            await MainActor.run {
                practiceContentState = .error(.content(.notFound))
                practiceBannerSeverity = .error
                practiceBannerMessageKeys = [L10n.Error.contentUnavailable]
            }
            return
        }
        
        do {
            let markdown = try await ContentFetcher.fetchMarkdown(
                path: contentPath,
                useCache: true,
                forceRefresh: false
            )
            let parsedContent = normalizeContent(
                MarkdownParser.parse(markdown, basePath: contentPath),
                fallbackTitle: module.title
            )
            
            await MainActor.run {
                practiceContentState = parsedContent.sections.isEmpty && parsedContent.title.isEmpty
                    ? .empty
                    : .loaded(parsedContent)
                practiceBannerSeverity = nil
                practiceBannerMessageKeys = []
            }
        } catch let fetchError as ContentFetchError {
            if case .rateLimited = fetchError,
               let cachedContent = loadCachedContent(for: contentPath, module: module) {
                await MainActor.run {
                    practiceContentState = .loaded(cachedContent)
                    practiceBannerSeverity = .warning
                    practiceBannerMessageKeys = [L10n.Error.cacheFallback]
                }
                return
            }
            
            await MainActor.run {
                practiceContentState = .error(fetchError.asAppError)
                practiceBannerSeverity = .error
                practiceBannerMessageKeys = []
            }
        } catch {
            await MainActor.run {
                practiceContentState = .error(AppError.map(error))
                practiceBannerSeverity = .error
                practiceBannerMessageKeys = []
            }
        }
    }
    
    // MARK: - Helpers
    
    private func loadCachedContent(for path: String, module: PracticeModule) -> MarkdownContent? {
        let cacheKey = "markdown:\(path)"
        guard let cachedData = cache.load(for: cacheKey),
              let cachedMarkdown = String(data: cachedData, encoding: .utf8) else {
            return nil
        }
        
        let parsed = MarkdownParser.parse(cachedMarkdown, basePath: path)
        return normalizeContent(parsed, fallbackTitle: module.title)
    }
    
    private func normalizeContent(_ content: MarkdownContent, fallbackTitle: String) -> MarkdownContent {
        guard content.title.isEmpty else {
            return content
        }
        
        return MarkdownContent(
            title: fallbackTitle,
            sections: content.sections,
            images: content.images,
            videos: content.videos,
            animatedMedia: content.animatedMedia,
            wikilinks: content.wikilinks,
            metadata: content.metadata
        )
    }
    
    private func determineContentPath(for module: PracticeModule, localization: LocalizationService) -> String {
        switch module.title {
        case "Безопасность":
            return "безопасность/брифинг по безопасности.md"
        case "Жизнь на яхте":
            return "команда/жизнь на лодке.md"
        case "Подготовка к выходу":
            return "чеклисты/подготовка к выходу.md"
        default:
            let categoryPath = module.category.localizedContentDirectory(using: localization)
            return "\(categoryPath)/\(module.title.lowercased()).md"
        }
    }
}

