//
//  PracticeModuleDetailView.swift
//  mothership
//
//  Detail view for learning modules with support for videos, images, and content
//

import SwiftUI

struct PracticeModuleDetailView: View {
    let moduleID: PracticeModule.ID
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
                                VStack(alignment: .leading, spacing: AppSpacing.md) {
                                    if let sectionTitle = section.title {
                                        Text(sectionTitle)
                                            .font(AppTypography.title2)
                                            .foregroundColor(AppColors.textPrimary)
                                            .padding(.horizontal, AppSpacing.screenPadding)
                                    }
                                    
                                    if !section.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text(section.content)
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textSecondary)
                                            .padding(.horizontal, AppSpacing.screenPadding)
                                    }
                                    
                                    // Items (for flashcards or lists)
                                    if !section.items.isEmpty {
                                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                            ForEach(Array(section.items.enumerated()), id: \.offset) { itemIndex, item in
                                                HStack(alignment: .top, spacing: AppSpacing.sm) {
                                                    Text("•")
                                                        .foregroundColor(AppColors.lavenderBlue)
                                                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                                        Text(item.title)
                                                            .font(AppTypography.body)
                                                            .foregroundColor(AppColors.textPrimary)
                                                        if let itemContent = item.content {
                                                            Text(itemContent)
                                                                .font(AppTypography.caption)
                                                                .foregroundColor(AppColors.textSecondary)
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, AppSpacing.screenPadding)
                                            }
                                        }
                                    }
                                }
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
        default:
            // Try to construct path from category
            let categoryPath = module.category.rawValue.lowercased()
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

