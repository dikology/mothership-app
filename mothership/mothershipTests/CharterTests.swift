//
//  CharterTests.swift
//  mothershipTests
//
//  Tests for Charter model
//

import XCTest
@testable import mothership

final class CharterTests: XCTestCase {
    
    // MARK: - isActive Tests
    
    func testCharterIsActive_CurrentDateBetweenStartAndEnd() {
        // Given: A charter that started yesterday and ends tomorrow
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let charter = Charter(
            name: "Test Charter",
            startDate: yesterday,
            endDate: tomorrow
        )
        
        // Then: Charter should be active
        XCTAssertTrue(charter.isActive, "Charter should be active when current date is between start and end dates")
    }
    
    func testCharterIsActive_NoEndDate_AfterStartDate() {
        // Given: A charter that started yesterday with no end date
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let charter = Charter(
            name: "Test Charter",
            startDate: yesterday,
            endDate: nil
        )
        
        // Then: Charter should be active
        XCTAssertTrue(charter.isActive, "Charter should be active when it has no end date and has already started")
    }
    
    func testCharterIsActive_StartDateIsToday() {
        // Given: A charter that starts today
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let charter = Charter(
            name: "Test Charter",
            startDate: today,
            endDate: tomorrow
        )
        
        // Then: Charter should be active (boundary condition)
        XCTAssertTrue(charter.isActive, "Charter should be active when start date is today")
    }
    
    func testCharterIsInactive_BeforeStartDate() {
        // Given: A charter that starts tomorrow
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let charter = Charter(
            name: "Test Charter",
            startDate: tomorrow,
            endDate: nextWeek
        )
        
        // Then: Charter should not be active
        XCTAssertFalse(charter.isActive, "Charter should not be active when current date is before start date")
    }
    
    func testCharterIsInactive_AfterEndDate() {
        // Given: A charter that ended yesterday
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let charter = Charter(
            name: "Test Charter",
            startDate: lastWeek,
            endDate: yesterday
        )
        
        // Then: Charter should not be active
        XCTAssertFalse(charter.isActive, "Charter should not be active when current date is after end date")
    }
    
    func testCharterIsActive_EndDateIsToday() {
        // Given: A charter that ends today
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let today = Date()
        let charter = Charter(
            name: "Test Charter",
            startDate: yesterday,
            endDate: today
        )
        
        // Then: Charter should be active (boundary condition)
        XCTAssertTrue(charter.isActive, "Charter should be active when end date is today")
    }
    
    // MARK: - Initialization Tests
    
    func testCharterInitialization_WithAllFields() {
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
        XCTAssertEqual(charter.name, name)
        XCTAssertEqual(charter.startDate, startDate)
        XCTAssertEqual(charter.endDate, endDate)
        XCTAssertEqual(charter.location, location)
        XCTAssertEqual(charter.yachtName, yachtName)
        XCTAssertEqual(charter.charterCompany, charterCompany)
        XCTAssertEqual(charter.notes, notes)
    }
    
    func testCharterInitialization_WithRequiredFieldsOnly() {
        // Given: Only required fields
        let name = "Test Charter"
        let startDate = Date()
        
        // When: Creating a charter
        let charter = Charter(
            name: name,
            startDate: startDate
        )
        
        // Then: Required fields should be set, optional fields should be nil
        XCTAssertEqual(charter.name, name)
        XCTAssertEqual(charter.startDate, startDate)
        XCTAssertNil(charter.endDate)
        XCTAssertNil(charter.location)
        XCTAssertNil(charter.yachtName)
        XCTAssertNil(charter.charterCompany)
        XCTAssertNil(charter.notes)
    }
    
    func testCharterInitialization_HasUniqueID() {
        // Given: Two charters with same data
        let charter1 = Charter(name: "Test", startDate: Date())
        let charter2 = Charter(name: "Test", startDate: Date())
        
        // Then: They should have different IDs
        XCTAssertNotEqual(charter1.id, charter2.id)
    }
    
    // MARK: - Codable Tests
    
    func testCharterEncodingAndDecoding() throws {
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
        XCTAssertEqual(decodedCharter.id, originalCharter.id)
        XCTAssertEqual(decodedCharter.name, originalCharter.name)
        XCTAssertEqual(decodedCharter.location, originalCharter.location)
        XCTAssertEqual(decodedCharter.yachtName, originalCharter.yachtName)
        XCTAssertEqual(decodedCharter.charterCompany, originalCharter.charterCompany)
        XCTAssertEqual(decodedCharter.notes, originalCharter.notes)
    }
}

