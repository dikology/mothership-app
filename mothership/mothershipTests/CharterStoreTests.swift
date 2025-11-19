//
//  CharterStoreTests.swift
//  mothershipTests
//
//  Tests for CharterStore
//

import XCTest
@testable import mothership

final class CharterStoreTests: XCTestCase {
    
    var sut: CharterStore!
    var testUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Create a test-specific UserDefaults suite
        testUserDefaults = UserDefaults(suiteName: "CharterStoreTests")!
        testUserDefaults.removePersistentDomain(forName: "CharterStoreTests")
        
        // Create a fresh store for each test
        sut = CharterStore(userDefaults: testUserDefaults)
    }
    
    override func tearDown() {
        // Clean up test UserDefaults
        testUserDefaults.removePersistentDomain(forName: "CharterStoreTests")
        testUserDefaults = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Add Charter Tests
    
    func testAddCharter_AddsCharterToStore() {
        // Given: An empty store
        XCTAssertTrue(sut.charters.isEmpty)
        
        // When: Adding a charter
        let charter = Charter(name: "Test Charter", startDate: Date())
        sut.addCharter(charter)
        
        // Then: Charter should be in the store
        XCTAssertEqual(sut.charters.count, 1)
        XCTAssertEqual(sut.charters.first?.id, charter.id)
    }
    
    func testAddCharter_SortsChartersByStartDate() {
        // Given: Three charters with different start dates
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let charter1 = Charter(name: "Today", startDate: today)
        let charter2 = Charter(name: "Tomorrow", startDate: tomorrow)
        let charter3 = Charter(name: "Yesterday", startDate: yesterday)
        
        // When: Adding charters in random order
        sut.addCharter(charter1)
        sut.addCharter(charter2)
        sut.addCharter(charter3)
        
        // Then: Charters should be sorted by start date (most recent first)
        XCTAssertEqual(sut.charters.count, 3)
        XCTAssertEqual(sut.charters[0].name, "Tomorrow")
        XCTAssertEqual(sut.charters[1].name, "Today")
        XCTAssertEqual(sut.charters[2].name, "Yesterday")
    }
    
    // MARK: - Update Charter Tests
    
    func testUpdateCharter_UpdatesExistingCharter() {
        // Given: A charter in the store
        let charter = Charter(name: "Original Name", startDate: Date())
        sut.addCharter(charter)
        
        // When: Updating the charter
        var updatedCharter = charter
        updatedCharter.name = "Updated Name"
        updatedCharter.location = "New Location"
        sut.updateCharter(updatedCharter)
        
        // Then: Charter should be updated
        XCTAssertEqual(sut.charters.count, 1)
        XCTAssertEqual(sut.charters.first?.name, "Updated Name")
        XCTAssertEqual(sut.charters.first?.location, "New Location")
    }
    
    func testUpdateCharter_ResortsList() {
        // Given: Multiple charters
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let charter1 = Charter(name: "Charter 1", startDate: yesterday)
        let charter2 = Charter(name: "Charter 2", startDate: tomorrow)
        sut.addCharter(charter1)
        sut.addCharter(charter2)
        
        // When: Updating charter1's start date to be later than charter2
        var updatedCharter = charter1
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        updatedCharter.startDate = nextWeek
        sut.updateCharter(updatedCharter)
        
        // Then: List should be resorted
        XCTAssertEqual(sut.charters[0].name, "Charter 1") // Now first because it has the latest date
        XCTAssertEqual(sut.charters[1].name, "Charter 2")
    }
    
    // MARK: - Delete Charter Tests
    
    func testDeleteCharter_RemovesCharterFromStore() {
        // Given: A charter in the store
        let charter = Charter(name: "Test Charter", startDate: Date())
        sut.addCharter(charter)
        XCTAssertEqual(sut.charters.count, 1)
        
        // When: Deleting the charter
        sut.deleteCharter(charter)
        
        // Then: Charter should be removed
        XCTAssertTrue(sut.charters.isEmpty)
    }
    
    func testDeleteCharter_OnlyDeletesSpecifiedCharter() {
        // Given: Multiple charters in the store
        let charter1 = Charter(name: "Charter 1", startDate: Date())
        let charter2 = Charter(name: "Charter 2", startDate: Date())
        sut.addCharter(charter1)
        sut.addCharter(charter2)
        
        // When: Deleting one charter
        sut.deleteCharter(charter1)
        
        // Then: Only the specified charter should be removed
        XCTAssertEqual(sut.charters.count, 1)
        XCTAssertEqual(sut.charters.first?.id, charter2.id)
    }
    
    // MARK: - Active Charter Tests
    
    func testActiveCharter_ReturnsCharterWithCurrentDate() {
        // Given: Multiple charters, one with current date between start and end
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        
        let pastCharter = Charter(name: "Past", startDate: lastWeek, endDate: yesterday)
        let activeCharter = Charter(name: "Active", startDate: yesterday, endDate: tomorrow)
        let futureCharter = Charter(name: "Future", startDate: tomorrow, endDate: nextWeek)
        
        sut.addCharter(pastCharter)
        sut.addCharter(activeCharter)
        sut.addCharter(futureCharter)
        
        // When: Getting active charter
        let result = sut.activeCharter
        
        // Then: Should return the active charter
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Active")
    }
    
    func testActiveCharter_ReturnsNilWhenNoActiveCharter() {
        // Given: Only past charters
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let pastCharter = Charter(name: "Past", startDate: lastWeek, endDate: yesterday)
        sut.addCharter(pastCharter)
        
        // When: Getting active charter
        let result = sut.activeCharter
        
        // Then: Should return nil
        XCTAssertNil(result)
    }
    
    func testActiveCharter_WorksWithNoEndDate() {
        // Given: A charter that started but has no end date
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let charter = Charter(name: "Ongoing", startDate: yesterday, endDate: nil)
        sut.addCharter(charter)
        
        // When: Getting active charter
        let result = sut.activeCharter
        
        // Then: Should return the charter
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Ongoing")
    }
    
    func testActiveCharter_ReturnsFirstWhenMultipleActive() {
        // Given: Two overlapping active charters
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        let charter1 = Charter(name: "Active 1", startDate: yesterday, endDate: tomorrow)
        let charter2 = Charter(name: "Active 2", startDate: yesterday, endDate: tomorrow)
        
        sut.addCharter(charter1)
        sut.addCharter(charter2)
        
        // When: Getting active charter
        let result = sut.activeCharter
        
        // Then: Should return the first one (most recent by start date)
        XCTAssertNotNil(result)
        // Both have the same start date, so the first added will be returned
        XCTAssertTrue([charter1.id, charter2.id].contains(result!.id))
    }
    
    // MARK: - Persistence Tests
    
    func testPersistence_SavesAndLoadsCharters() {
        // Given: A charter added to the store
        let charter = Charter(
            name: "Test Charter",
            startDate: Date(),
            location: "Test Location"
        )
        sut.addCharter(charter)
        XCTAssertEqual(sut.charters.count, 1)
        
        // When: Clearing the in-memory state and reloading from UserDefaults
        sut.charters = []
        XCTAssertTrue(sut.charters.isEmpty, "Charters should be cleared")
        
        sut.reload()
        
        // Then: The charter should be loaded from persistence
        XCTAssertEqual(sut.charters.count, 1)
        XCTAssertEqual(sut.charters.first?.id, charter.id)
        XCTAssertEqual(sut.charters.first?.name, charter.name)
        XCTAssertEqual(sut.charters.first?.location, charter.location)
    }
}

