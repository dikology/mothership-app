//
//  Date+Extensions.swift
//  mothership
//
//  Date formatting extensions for consistent date display
//

import Foundation

extension Date {
    /// Formats date in a consistent medium style (e.g., "Jan 15, 2024")
    /// Uses the user's current locale
    func formattedMedium() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Formats date in a consistent short style (e.g., "1/15/24")
    /// Uses the user's current locale
    func formattedShort() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Formats date in a consistent long style (e.g., "January 15, 2024")
    /// Uses the user's current locale
    func formattedLong() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Returns a formatted date range string (e.g., "Jan 15 - Jan 22, 2024")
    static func formattedRange(from startDate: Date, to endDate: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        guard let endDate = endDate else {
            return formatter.string(from: startDate)
        }
        
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        return "\(start) – \(end)"
    }
}

extension DateFormatter {
    /// Returns a shared date formatter configured for consistent date display
    /// This helps avoid creating multiple formatters and ensures consistency
    static let charterDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

