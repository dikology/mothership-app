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
        // Get language code (ru or en)
        let languageCode = localization.effectiveLanguage.code
        
        // Check if module has a language-specific path mapping
        if let languagePaths = modulePathMapping[module.id.uuidString],
           let modulePath = languagePaths[languageCode] {
            // Use language-specific path: {language}/{path}
            return "\(languageCode)/\(modulePath)"
        }
        
        // Fallback: use default path generation
        let modulePath = defaultModulePath(for: module, localization: localization)
        return "\(languageCode)/\(modulePath)"
    }
    
    /// Mapping from module ID to language-specific file paths (relative to language folder)
    /// Modules that don't follow the default category/filename structure need explicit mappings
    private var modulePathMapping: [String: [String: String]] {
        [
            // Safety Briefing
            "00000000-0000-0000-0000-000000000001": [
                "ru": "безопасность/брифинг по безопасности.md",
                "en": "safety/safety briefing.md"
            ],
            // Life on Yacht
            "00000000-0000-0000-0000-000000000002": [
                "ru": "команда/жизнь на лодке.md",
                "en": "team/life on yacht.md"
            ],
            // First Aid Kit
            "00000000-0000-0000-0000-000000000003": [
                "ru": "безопасность/аптечка.md",
                "en": "safety/first aid kit.md"
            ],
            // Going Ashore
            "00000000-0000-0000-0000-000000000004": [
                "ru": "безопасность/сход на берег.md",
                "en": "safety/going ashore.md"
            ],
            // Mooring and Departure
            "00000000-0000-0000-0000-000000000005": [
                "ru": "безопасность/швартовка и отход.md",
                "en": "safety/mooring and departure.md"
            ],
            // Round Turn (Knot)
            "00000000-0000-0000-0000-000000000006": [
                "ru": "узлы/штык со шлагом.md",
                "en": "knots/round turn and two half hitches.md"
            ],
            // Pre-departure Preparation
            "00000000-0000-0000-0000-000000000007": [
                "ru": "чеклисты/подготовка к выходу.md",
                "en": "checklists/pre-departure preparation.md"
            ],
            // Departure from Pier
            "00000000-0000-0000-0000-000000000008": [
                "ru": "швартовки/отход от пирса.md",
                "en": "mooring/departure from pier.md"
            ],
            // Mediterranean Mooring
            "00000000-0000-0000-0000-000000000009": [
                "ru": "швартовки/швартовка по средиземноморски.md",
                "en": "mooring/mediterranean mooring.md"
            ],
            // Anchoring
            "00000000-0000-0000-0000-000000000010": [
                "ru": "швартовки/постановка на якорь.md",
                "en": "mooring/anchoring.md"
            ]
        ]
    }
    
    /// Default path generation for modules not in the mapping
    /// Uses category name and sanitized title based on the provided localization
    private func defaultModulePath(for module: PracticeModule, localization: LocalizationService) -> String {
        // Get localized category directory name
        let categoryPath = module.category.localizedContentDirectory(using: localization)
        
        // Sanitize title for filename
        let fileName = module.title
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: ",", with: "_")
        
        return "\(categoryPath)/\(fileName).md"
    }
}

