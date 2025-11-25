//
//  CharterStoreTests.swift
//  mothershipTests
//
//  Tests for CharterStore - Swift Testing version
//

import Testing
@testable import mothership
import Foundation

@MainActor
struct CharterStoreTests {
    
    // MARK: - Test Fixtures
    
    func makeTestStore() -> CharterStore {
        let testUserDefaults = UserDefaults(suiteName: "CharterStoreTests")!
        testUserDefaults.removePersistentDomain(forName: "CharterStoreTests")
        return CharterStore(userDefaults: testUserDefaults)
    }
    
    // MARK: - Add Charter Tests
    
    @Test("Add charter adds charter to store")
    func addCharter_AddsToStore() async throws {
        // Given: An empty store
        let sut = makeTestStore()
        #expect(sut.charters.isEmpty)
        
        // When: Adding a charter
        let charter = Charter(name: "Test Charter", startDate: Date())
        sut.addCharter(charter)
        
        // Then: Charter should be in the store
        #expect(sut.charters.count == 1)
        #expect(sut.charters.first?.id == charter.id)
    }
    
    @Test("Add charter sorts charters by start date")
    func addCharter_SortsByStartDate() async throws {
        // Given: Three charters with different start dates
        let sut = makeTestStore()
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
        #expect(sut.charters.count == 3)
        #expect(sut.charters[0].name == "Tomorrow")
        #expect(sut.charters[1].name == "Today")
        #expect(sut.charters[2].name == "Yesterday")
    }
    
    // MARK: - Update Charter Tests
    
    @Test("Update charter updates existing charter")
    func updateCharter_UpdatesExisting() async throws {
        // Given: A charter in the store
        let sut = makeTestStore()
        let charter = Charter(name: "Original Name", startDate: Date())
        sut.addCharter(charter)
        
        // When: Updating the charter
        var updatedCharter = charter
        updatedCharter.name = "Updated Name"
        updatedCharter.location = "New Location"
        sut.updateCharter(updatedCharter)
        
        // Then: Charter should be updated
        #expect(sut.charters.count == 1)
        #expect(sut.charters.first?.name == "Updated Name")
        #expect(sut.charters.first?.location == "New Location")
    }
    
    @Test("Update charter resorts list")
    func updateCharter_ResortsList() async throws {
        // Given: Multiple charters
        let sut = makeTestStore()
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
        #expect(sut.charters[0].name == "Charter 1") // Now first because it has the latest date
        #expect(sut.charters[1].name == "Charter 2")
    }
    
    // MARK: - Delete Charter Tests
    
    @Test("Delete charter removes charter from store")
    func deleteCharter_RemovesFromStore() async throws {
        // Given: A charter in the store
        let sut = makeTestStore()
        let charter = Charter(name: "Test Charter", startDate: Date())
        sut.addCharter(charter)
        #expect(sut.charters.count == 1)
        
        // When: Deleting the charter
        sut.deleteCharter(charter)
        
        // Then: Charter should be removed
        #expect(sut.charters.isEmpty)
    }
    
    @Test("Delete charter only deletes specified charter")
    func deleteCharter_OnlyDeletesSpecified() async throws {
        // Given: Multiple charters in the store
        let sut = makeTestStore()
        let charter1 = Charter(name: "Charter 1", startDate: Date())
        let charter2 = Charter(name: "Charter 2", startDate: Date())
        sut.addCharter(charter1)
        sut.addCharter(charter2)
        
        // When: Deleting one charter
        sut.deleteCharter(charter1)
        
        // Then: Only the specified charter should be removed
        #expect(sut.charters.count == 1)
        #expect(sut.charters.first?.id == charter2.id)
    }
    
    // MARK: - Active Charter Tests
    
    @Test("Active charter returns charter with current date")
    func activeCharter_ReturnsCharterWithCurrentDate() async throws {
        // Given: Multiple charters, one with current date between start and end
        let sut = makeTestStore()
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
        #expect(result != nil)
        #expect(result?.name == "Active")
    }
    
    @Test("Active charter returns nil when no active charter")
    func activeCharter_ReturnsNilWhenNoActive() async throws {
        // Given: Only past charters
        let sut = makeTestStore()
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let pastCharter = Charter(name: "Past", startDate: lastWeek, endDate: yesterday)
        sut.addCharter(pastCharter)
        
        // When: Getting active charter
        let result = sut.activeCharter
        
        // Then: Should return nil
        #expect(result == nil)
    }
    
    @Test("Active charter works with no end date")
    func activeCharter_WorksWithNoEndDate() async throws {
        // Given: A charter that started but has no end date
        let sut = makeTestStore()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let charter = Charter(name: "Ongoing", startDate: yesterday, endDate: nil)
        sut.addCharter(charter)
        
        // When: Getting active charter
        let result = sut.activeCharter
        
        // Then: Should return the charter
        #expect(result != nil)
        #expect(result?.name == "Ongoing")
    }
    
    @Test("Active charter returns first when multiple active")
    func activeCharter_ReturnsFirstWhenMultiple() async throws {
        // Given: Two overlapping active charters
        let sut = makeTestStore()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        let charter1 = Charter(name: "Active 1", startDate: yesterday, endDate: tomorrow)
        let charter2 = Charter(name: "Active 2", startDate: yesterday, endDate: tomorrow)
        
        sut.addCharter(charter1)
        sut.addCharter(charter2)
        
        // When: Getting active charter
        let result = sut.activeCharter
        
        // Then: Should return the first one (most recent by start date)
        #expect(result != nil)
        // Both have the same start date, so the first added will be returned
        #expect([charter1.id, charter2.id].contains(result!.id))
    }
    
    // MARK: - Persistence Tests
    
    @Test("Persistence saves and loads charters")
    func persistence_SavesAndLoads() async throws {
        // Given: A charter added to the store
        let sut = makeTestStore()
        let charter = Charter(
            name: "Test Charter",
            startDate: Date(),
            location: "Test Location"
        )
        sut.addCharter(charter)
        #expect(sut.charters.count == 1)
        
        // When: Clearing the in-memory state and reloading from UserDefaults
        sut.clearInMemoryStateForTesting()
        #expect(sut.charters.isEmpty, "Charters should be cleared")
        
        sut.reload()
        
        // Then: The charter should be loaded from persistence
        #expect(sut.charters.count == 1)
        #expect(sut.charters.first?.id == charter.id)
        #expect(sut.charters.first?.name == charter.name)
        #expect(sut.charters.first?.location == charter.location)
    }
}
