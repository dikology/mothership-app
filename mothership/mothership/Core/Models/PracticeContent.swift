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
    case lifeOnBoard = "lifeOnBoard"
    case knots = "knots"
    case safety = "safety"
    case maneuvering = "maneuvering"
    case mooring = "mooring"
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
