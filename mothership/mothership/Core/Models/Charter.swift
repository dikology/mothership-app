//
//  Charter.swift
//  mothership
//
//  Core model for managing charters
//

import Foundation
//import Tagged
import SwiftUI

struct Charter: Identifiable, Hashable, Codable {
    //let id: Tagged<Self, UUID>
    let id: UUID
    var name: String
    var startDate: Date
    var endDate: Date?
    var location: String?
    var yachtName: String?
    var charterCompany: String?
    var notes: String?
    var createdAt: Date
    
    var isActive: Bool {
        let now = Date()
        return startDate <= now && (endDate == nil || endDate! >= now)
    }
    
    init(
        //id: Tagged<Self, UUID> = Tagged<Self, UUID>(UUID()),
        id: UUID = UUID(),
        name: String,
        startDate: Date = Date(),
        endDate: Date? = nil,
        location: String? = nil,
        yachtName: String? = nil,
        charterCompany: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.yachtName = yachtName
        self.charterCompany = charterCompany
        self.notes = notes
        self.createdAt = createdAt
    }
}

extension Charter {
    static let mock = Self(
        name: "Croatia Charter",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
        location: "Split, Croatia",
        yachtName: "Sunset Dream",
        charterCompany: "SunSail"
    )
}

