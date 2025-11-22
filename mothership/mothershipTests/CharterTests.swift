//
//  CharterTests.swift
//  mothershipTests
//
//  Tests for Charter model - Swift Testing version
//

import Testing
@testable import mothership

struct CharterTests {
    
    // MARK: - isActive Tests
    
    @Test("Charter is active when current date is between start and end")
    func isActive_CurrentDateBetweenStartAndEnd() async throws {
        // Given: A charter that started yesterday and ends tomorrow
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let charter = Charter(
            name: "Test Charter",
            startDate: yesterday,
            endDate: tomorrow
        )
        
        // Then: Charter should be active
        #expect(charter.isActive, "Charter should be active when current date is between start and end dates")
    }
    
    @Test("Charter is active with no end date after start date")
    func isActive_NoEndDateAfterStartDate() async throws {
        // Given: A charter that started yesterday with no end date
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let charter = Charter(
            name: "Test Charter",
            startDate: yesterday,
            endDate: nil
        )
        
        // Then: Charter should be active
        #expect(charter.isActive, "Charter should be active when it has no end date and has already started")
    }
    
    @Test("Charter is active when start date is today")
    func isActive_StartDateIsToday() async throws {
        // Given: A charter that starts today
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let charter = Charter(
            name: "Test Charter",
            startDate: today,
            endDate: tomorrow
        )
        
        // Then: Charter should be active (boundary condition)
        #expect(charter.isActive, "Charter should be active when start date is today")
    }
    
    @Test("Charter is inactive before start date")
    func isInactive_BeforeStartDate() async throws {
        // Given: A charter that starts tomorrow
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let charter = Charter(
            name: "Test Charter",
            startDate: tomorrow,
            endDate: nextWeek
        )
        
        // Then: Charter should not be active
        #expect(!charter.isActive, "Charter should not be active when current date is before start date")
    }
    
    @Test("Charter is inactive after end date")
    func isInactive_AfterEndDate() async throws {
        // Given: A charter that ended yesterday
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let charter = Charter(
            name: "Test Charter",
            startDate: lastWeek,
            endDate: yesterday
        )
        
        // Then: Charter should not be active
        #expect(!charter.isActive, "Charter should not be active when current date is after end date")
    }
    
    @Test("Charter is active when end date is today")
    func isActive_EndDateIsToday() async throws {
        // Given: A charter that ends today
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let today = Date()
        let charter = Charter(
            name: "Test Charter",
            startDate: yesterday,
            endDate: today
        )
        
        // Then: Charter should be active (boundary condition)
        #expect(charter.isActive, "Charter should be active when end date is today")
    }
    
    // MARK: - Initialization Tests
    
    @Test("Charter initialization with all fields")
    func initialization_WithAllFields() async throws {
        // Given: All charter fields
        let name = "Croatia Charter"
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)
        let location = "Split, Croatia"
        let yachtName = "Sunset Dream"
        let charterCompany = "SunSail"
        let notes = "Test notes"
        
        // When: Creating a charter
        let charter = Charter(
            name: name,
            startDate: startDate,
            endDate: endDate,
            location: location,
            yachtName: yachtName,
            charterCompany: charterCompany,
            notes: notes
        )
        
        // Then: All fields should be set correctly
        #expect(charter.name == name)
        #expect(charter.startDate == startDate)
        #expect(charter.endDate == endDate)
        #expect(charter.location == location)
        #expect(charter.yachtName == yachtName)
        #expect(charter.charterCompany == charterCompany)
        #expect(charter.notes == notes)
    }
    
    @Test("Charter initialization with required fields only")
    func initialization_WithRequiredFieldsOnly() async throws {
        // Given: Only required fields
        let name = "Test Charter"
        let startDate = Date()
        
        // When: Creating a charter
        let charter = Charter(
            name: name,
            startDate: startDate
        )
        
        // Then: Required fields should be set, optional fields should be nil
        #expect(charter.name == name)
        #expect(charter.startDate == startDate)
        #expect(charter.endDate == nil)
        #expect(charter.location == nil)
        #expect(charter.yachtName == nil)
        #expect(charter.charterCompany == nil)
        #expect(charter.notes == nil)
    }
    
    @Test("Charter initialization has unique ID")
    func initialization_HasUniqueID() async throws {
        // Given: Two charters with same data
        let charter1 = Charter(name: "Test", startDate: Date())
        let charter2 = Charter(name: "Test", startDate: Date())
        
        // Then: They should have different IDs
        #expect(charter1.id != charter2.id)
    }
    
    // MARK: - Codable Tests
    
    @Test("Charter encoding and decoding")
    func codable_EncodingAndDecoding() async throws {
        // Given: A charter with all fields
        let originalCharter = Charter(
            name: "Test Charter",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            location: "Test Location",
            yachtName: "Test Yacht",
            charterCompany: "Test Company",
            notes: "Test notes"
        )
        
        // When: Encoding and then decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCharter)
        let decoder = JSONDecoder()
        let decodedCharter = try decoder.decode(Charter.self, from: data)
        
        // Then: Decoded charter should match original
        #expect(decodedCharter.id == originalCharter.id)
        #expect(decodedCharter.name == originalCharter.name)
        #expect(decodedCharter.location == originalCharter.location)
        #expect(decodedCharter.yachtName == originalCharter.yachtName)
        #expect(decodedCharter.charterCompany == originalCharter.charterCompany)
        #expect(decodedCharter.notes == originalCharter.notes)
    }
}
