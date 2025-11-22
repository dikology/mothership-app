//
//  MarkdownComponents.swift
//  mothership
//
//  Shared components for rendering markdown content
//

import SwiftUI

// MARK: - Section View Component

struct MarkdownSectionView: View {
    let section: MarkdownSection
    var showPadding: Bool = true
    var showAttributedText: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Section title
            if let sectionTitle = section.title {
                Text(sectionTitle)
                    .font(fontForLevel(section.level))
                    .foregroundColor(AppColors.textPrimary)
                    .fontWeight(weightForLevel(section.level))
                    .padding(.horizontal, showPadding ? AppSpacing.screenPadding : 0)
                    .padding(.top, section.level == 2 ? AppSpacing.sm : 0)
            }
            
            // Render content blocks in order (preserves markdown order)
            ForEach(Array(section.contentBlocks.enumerated()), id: \.offset) { index, block in
                switch block {
                case .text(let text):
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if showAttributedText {
                            Text(attributedString(from: text))
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, showPadding ? AppSpacing.screenPadding : 0)
                        } else {
                            Text(text)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, showPadding ? AppSpacing.screenPadding : 0)
                        }
                    }
                    
                case .items(let items):
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        ForEach(Array(items.enumerated()), id: \.offset) { itemIndex, item in
                            MarkdownListItemView(item: item, level: 0, showAttributedText: showAttributedText)
                                .padding(.horizontal, showPadding ? AppSpacing.screenPadding : 0)
                        }
                    }
                }
            }
            
            // Subsections (recursive)
            if !section.subsections.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    ForEach(Array(section.subsections.enumerated()), id: \.offset) { index, subsection in
                        MarkdownSectionView(
                            section: subsection,
                            showPadding: showPadding,
                            showAttributedText: showAttributedText
                        )
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

struct MarkdownListItemView: View {
    let item: MarkdownItem
    let level: Int
    var showAttributedText: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Main item
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Text("•")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.lavenderBlue)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    if showAttributedText {
                        Text(attributedString(from: item.title))
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                    } else {
                        Text(item.title)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    if let itemContent = item.content {
                        if showAttributedText {
                            Text(attributedString(from: itemContent))
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            Text(itemContent)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            
            // Nested subitems
            if !item.subitems.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(Array(item.subitems.enumerated()), id: \.offset) { index, subitem in
                        MarkdownListItemView(item: subitem, level: level + 1, showAttributedText: showAttributedText)
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

