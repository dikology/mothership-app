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
        let calendar = Calendar.current
        let now = Date()
        
        // Normalize dates to start of day for comparison
        let todayStart = calendar.startOfDay(for: now)
        let charterStart = calendar.startOfDay(for: startDate)
        
        // Check if today is on or after the charter start date
        guard todayStart >= charterStart else {
            return false
        }
        
        // If there's no end date, charter is active indefinitely
        guard let endDate = endDate else {
            return true
        }
        
        // Normalize end date and check if today is on or before it
        let charterEnd = calendar.startOfDay(for: endDate)
        
        return todayStart <= charterEnd
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

