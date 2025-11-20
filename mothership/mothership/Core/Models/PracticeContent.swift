//
//  PracticeContent.swift
//  mothership
//
//  Core models for practice content
//

import Foundation
import SwiftUI

enum PracticeModuleType: String, Codable {
    case checklist = "checklist"
    case briefing = "briefing"
    case document = "document"
}

enum PracticeCategory: String, Codable, CaseIterable {
    // New comprehensive categories
    case all = "all"
    case briefing = "briefing"
    case knots = "knots"
    case maneuvering = "maneuvering"
    case mooring = "mooring"
    case safety = "safety"
}

struct PracticeModule: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var category: PracticeCategory
    var type: PracticeModuleType
    var source: ContentSource
    var lastFetched: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        category: PracticeCategory,
        type: PracticeModuleType,
        source: ContentSource = .bundled,
        lastFetched: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.type = type
        self.source = source
        self.lastFetched = lastFetched
    }
}

enum ContentSource: String, Codable {
    case bundled
    case remote
    case userCreated
}

// MARK: - Localization Helpers

extension PracticeCategory {
    private var localizationKey: String {
        switch self {
        case .all:
            return L10n.Practice.all
        case .briefing:
            return L10n.Practice.briefing
        case .knots:
            return L10n.Practice.knots
        case .maneuvering:
            return L10n.Practice.maneuvering
        case .mooring:
            return L10n.Practice.mooring
        case .safety:
            return L10n.Practice.safety
        }
    }
    
    func displayName(using localization: LocalizationService) -> String {
        localization.localized(localizationKey)
    }
    
    func localizedContentDirectory(using localization: LocalizationService) -> String {
        displayName(using: localization)
            .lowercased()
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .briefing: return "shield"
        case .knots: return "figure.walk"
        case .maneuvering: return "arrow.triangle.2.circlepath"
        case .mooring: return "anchor"
        case .safety: return "shield"
        }
    }
}
