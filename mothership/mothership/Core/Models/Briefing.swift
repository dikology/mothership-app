//
//  Briefing.swift
//  mothership
//
//  Core models for crew briefings
//

import Foundation
import SwiftUI

enum BriefingType: String, Codable, CaseIterable {
    case safety = "safety"
    case lifeOnBoard = "life_on_board"
}

struct Briefing: Identifiable, Hashable, Codable {
    let id: UUID
    var type: BriefingType
    var charterId: UUID
    var title: String
    var sections: [BriefingSection]
    var isCompleted: Bool
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        type: BriefingType,
        charterId: UUID,
        title: String,
        sections: [BriefingSection] = [],
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.charterId = charterId
        self.title = title
        self.sections = sections
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}

struct BriefingSection: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var content: String
    var items: [BriefingItem]
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        items: [BriefingItem] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.items = items
    }
}

struct BriefingItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isAcknowledged: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        isAcknowledged: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isAcknowledged = isAcknowledged
    }
}

