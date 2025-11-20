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
    
    private let contentCache = ContentCache()
    
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
                                SectionView(section: section)
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
            let markdown = try await ContentFetcher.fetchMarkdown(path: contentPath)
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
            }
        } catch {
            let errorDetails: String
            if let fetchError = error as? ContentFetchError {
                errorDetails = fetchError.errorDescription ?? error.localizedDescription
            } else {
                errorDetails = error.localizedDescription
            }
            
            await MainActor.run {
                self.errorMessage = "Не удалось загрузить контент:\n\(errorDetails)"
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

// MARK: - Section View Component

struct SectionView: View {
    let section: MarkdownSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Section title
            if let sectionTitle = section.title {
                Text(sectionTitle)
                    .font(fontForLevel(section.level))
                    .foregroundColor(AppColors.textPrimary)
                    .fontWeight(weightForLevel(section.level))
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, section.level == 2 ? AppSpacing.sm : 0)
            }
            
            // Section content
            if !section.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(attributedString(from: section.content))
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.screenPadding)
            }
            
            // Section items (lists)
            if !section.items.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    ForEach(Array(section.items.enumerated()), id: \.offset) { itemIndex, item in
                        ListItemView(item: item, level: 0)
                            .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }
            }
            
            // Subsections (recursive)
            if !section.subsections.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    ForEach(Array(section.subsections.enumerated()), id: \.offset) { index, subsection in
                        SectionView(section: subsection)
                    }
                }
            }
        }
    }
    
    private func fontForLevel(_ level: Int) -> Font {
        switch level {
        case 2: return AppTypography.title2
        case 3: return AppTypography.title3
        default: return AppTypography.body
        }
    }
    
    private func weightForLevel(_ level: Int) -> Font.Weight {
        switch level {
        case 2: return .bold
        case 3: return .semibold
        default: return .regular
        }
    }
    
    private func attributedString(from markdown: String) -> AttributedString {
        var result = AttributedString(markdown)
        
        // Apply bold formatting for **text**
        let boldPattern = #"\*\*([^*]+)\*\*"#
        if let regex = try? NSRegularExpression(pattern: boldPattern, options: []) {
            let nsString = markdown as NSString
            let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0, length: nsString.length))
            
            // Process matches in reverse to maintain correct indices
            for match in matches.reversed() {
                if let contentRange = Range(match.range(at: 1), in: markdown),
                   let fullRange = Range(match.range, in: markdown) {
                    let boldText = String(markdown[contentRange])
                    
                    // Find the range in AttributedString
                    if let attrRange = result.range(of: "**\(boldText)**") {
                        var boldAttrString = AttributedString(boldText)
                        boldAttrString.font = .body.weight(.bold)
                        result.replaceSubrange(attrRange, with: boldAttrString)
                    }
                }
            }
        }
        
        return result
    }
}

// MARK: - List Item View Component

struct ListItemView: View {
    let item: MarkdownItem
    let level: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Main item
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Text("•")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.lavenderBlue)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(attributedString(from: item.title))
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let itemContent = item.content {
                        Text(attributedString(from: itemContent))
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            // Nested subitems
            if !item.subitems.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(Array(item.subitems.enumerated()), id: \.offset) { index, subitem in
                        ListItemView(item: subitem, level: level + 1)
                            .padding(.leading, AppSpacing.md)
                    }
                }
            }
        }
    }
    
    private func attributedString(from markdown: String) -> AttributedString {
        var result = AttributedString(markdown)
        
        // Apply bold formatting for **text**
        let boldPattern = #"\*\*([^*]+)\*\*"#
        if let regex = try? NSRegularExpression(pattern: boldPattern, options: []) {
            let nsString = markdown as NSString
            let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0, length: nsString.length))
            
            // Process matches in reverse to maintain correct indices
            for match in matches.reversed() {
                if let contentRange = Range(match.range(at: 1), in: markdown),
                   let fullRange = Range(match.range, in: markdown) {
                    let boldText = String(markdown[contentRange])
                    
                    // Find the range in AttributedString
                    if let attrRange = result.range(of: "**\(boldText)**") {
                        var boldAttrString = AttributedString(boldText)
                        boldAttrString.font = .body.weight(.bold)
                        result.replaceSubrange(attrRange, with: boldAttrString)
                    }
                }
            }
        }
        
        return result
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

