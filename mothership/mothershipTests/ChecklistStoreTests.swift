//
//  ChecklistStoreTests.swift
//  mothershipTests
//
//  Unit tests for ChecklistStore
//

import XCTest
@testable import mothership

final class ChecklistStoreTests: XCTestCase {
    var sut: ChecklistStore!
    var testUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Create a test-specific UserDefaults suite
        testUserDefaults = UserDefaults(suiteName: "ChecklistStoreTests")!
        testUserDefaults.removePersistentDomain(forName: "ChecklistStoreTests")
        
        // Create a fresh store for each test
        sut = ChecklistStore(userDefaults: testUserDefaults)
    }
    
    override func tearDown() {
        // Clean up test UserDefaults
        testUserDefaults.removePersistentDomain(forName: "ChecklistStoreTests")
        testUserDefaults = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testChecklistStoreInitializesWithDefaultCheckInChecklist() {
        // Given & When
        // Store is initialized in setUp
        
        // Then
        let checkInChecklist = sut.getCheckInChecklist()
        XCTAssertNotNil(checkInChecklist, "Check-in checklist should be created on init")
        XCTAssertEqual(checkInChecklist?.type, .charterScoped)
        XCTAssertEqual(checkInChecklist?.charterType, .checkIn)
        XCTAssertFalse(checkInChecklist?.sections.isEmpty ?? true, "Check-in checklist should have sections")
    }
    
    // MARK: - Checklist Retrieval Tests
    
    func testGetCheckInChecklistReturnsCorrectChecklist() {
        // Given & When
        let checklist = sut.getCheckInChecklist()
        
        // Then
        XCTAssertNotNil(checklist)
        XCTAssertTrue(checklist?.title.contains("Check-in") ?? false)
    }
    
    func testGetCheckInChecklistForCharterReturnsChecklistWithCharterId() {
        // Given
        let charterId = UUID()
        
        // When
        let checklist = sut.getCheckInChecklist(for: charterId)
        
        // Then
        XCTAssertNotNil(checklist)
        XCTAssertEqual(checklist?.type, .charterScoped)
    }
    
    // MARK: - Item Toggle Tests
    
    func testToggleItemMarksItemAsChecked() {
        // Given
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstItem = firstSection.items.first else {
            XCTFail("Checklist setup failed")
            return
        }
        
        XCTAssertFalse(firstItem.isChecked, "Item should start unchecked")
        
        // When
        sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: firstItem.id)
        
        // Then
        let updatedChecklist = sut.getCheckInChecklist(for: charterId)
        let updatedItem = updatedChecklist?.sections.first?.items.first
        XCTAssertTrue(updatedItem?.isChecked ?? false, "Item should be checked after toggle")
        XCTAssertNotNil(updatedItem?.checkedAt, "checkedAt should be set")
    }
    
    func testToggleItemTwiceUnchecksItem() {
        // Given
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstItem = firstSection.items.first else {
            XCTFail("Checklist setup failed")
            return
        }
        
        // When
        sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: firstItem.id)
        sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: firstItem.id)
        
        // Then
        let updatedChecklist = sut.getCheckInChecklist(for: charterId)
        let updatedItem = updatedChecklist?.sections.first?.items.first
        XCTAssertFalse(updatedItem?.isChecked ?? true, "Item should be unchecked after second toggle")
        XCTAssertNil(updatedItem?.checkedAt, "checkedAt should be nil when unchecked")
    }
    
    // MARK: - User Note Tests
    
    func testUpdateItemNoteAddsNoteToItem() {
        // Given
        let charterId = UUID()
        let testNote = "Test note for this item"
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstItem = firstSection.items.first else {
            XCTFail("Checklist setup failed")
            return
        }
        
        // When
        sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: firstItem.id, note: testNote)
        
        // Then
        let updatedChecklist = sut.getCheckInChecklist(for: charterId)
        let updatedItem = updatedChecklist?.sections.first?.items.first
        XCTAssertEqual(updatedItem?.userNote, testNote)
    }
    
    func testUpdateItemNoteWithNilClearsNote() {
        // Given
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstItem = firstSection.items.first else {
            XCTFail("Checklist setup failed")
            return
        }
        
        // Add note first
        sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: firstItem.id, note: "Initial note")
        
        // When
        sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: firstItem.id, note: nil)
        
        // Then
        let updatedChecklist = sut.getCheckInChecklist(for: charterId)
        let updatedItem = updatedChecklist?.sections.first?.items.first
        XCTAssertNil(updatedItem?.userNote)
    }
    
    // MARK: - Charter-Specific State Tests
    
    func testDifferentChartersHaveSeparateChecklistStates() {
        // Given
        let charter1Id = UUID()
        let charter2Id = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstItem = firstSection.items.first else {
            XCTFail("Checklist setup failed")
            return
        }
        
        // When
        sut.toggleItem(for: charter1Id, checklistId: checklist.id, itemId: firstItem.id)
        
        // Then
        let charter1Checklist = sut.getCheckInChecklist(for: charter1Id)
        let charter2Checklist = sut.getCheckInChecklist(for: charter2Id)
        
        let charter1Item = charter1Checklist?.sections.first?.items.first
        let charter2Item = charter2Checklist?.sections.first?.items.first
        
        XCTAssertTrue(charter1Item?.isChecked ?? false, "Charter 1 item should be checked")
        XCTAssertFalse(charter2Item?.isChecked ?? true, "Charter 2 item should not be checked")
    }
    
    // MARK: - Reset Tests
    
    func testResetChecklistClearsAllItems() {
        // Given
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist() else {
            XCTFail("Checklist setup failed")
            return
        }
        
        // Check a few items first
        for section in checklist.sections.prefix(2) {
            for item in section.items.prefix(3) {
                sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: item.id)
                sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: item.id, note: "Test note")
            }
        }
        
        // When
        sut.resetChecklist(for: charterId, checklistId: checklist.id)
        
        // Then
        let resetChecklist = sut.getCheckInChecklist(for: charterId)
        let allItemsUnchecked = resetChecklist?.sections.allSatisfy { section in
            section.items.allSatisfy { !$0.isChecked && $0.userNote == nil }
        }
        XCTAssertTrue(allItemsUnchecked ?? false, "All items should be unchecked and notes cleared")
    }
    
    // MARK: - Progress Calculation Tests
    
    func testCalculateProgressWithNoItemsCheckedReturnsZero() {
        // Given
        guard let checklist = sut.getCheckInChecklist() else {
            XCTFail("Checklist setup failed")
            return
        }
        
        // When
        let progress = sut.calculateProgress(for: checklist)
        
        // Then
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }
    
    func testCalculateProgressWithSomeItemsCheckedReturnsCorrectValue() {
        // Given
        let charterId = UUID()
        guard let baseChecklist = sut.getCheckInChecklist() else {
            XCTFail("Checklist setup failed")
            return
        }
        
        // Check first 5 items
        var itemsChecked = 0
        var totalItems = 0
        for section in baseChecklist.sections {
            for item in section.items {
                totalItems += 1
                if itemsChecked < 5 {
                    sut.toggleItem(for: charterId, checklistId: baseChecklist.id, itemId: item.id)
                    itemsChecked += 1
                }
            }
        }
        
        // When
        guard let checklist = sut.getCheckInChecklist(for: charterId) else {
            XCTFail("Could not get checklist")
            return
        }
        let progress = sut.calculateProgress(for: checklist)
        
        // Then
        let expectedProgress = Double(itemsChecked) / Double(totalItems)
        XCTAssertEqual(progress, expectedProgress, accuracy: 0.001)
    }
    
    func testCalculateProgressWithAllItemsCheckedReturnsOne() {
        // Given
        let charterId = UUID()
        guard let baseChecklist = sut.getCheckInChecklist() else {
            XCTFail("Checklist setup failed")
            return
        }
        
        // Check all items
        for section in baseChecklist.sections {
            for item in section.items {
                sut.toggleItem(for: charterId, checklistId: baseChecklist.id, itemId: item.id)
            }
        }
        
        // When
        guard let checklist = sut.getCheckInChecklist(for: charterId) else {
            XCTFail("Could not get checklist")
            return
        }
        let progress = sut.calculateProgress(for: checklist)
        
        // Then
        XCTAssertEqual(progress, 1.0, accuracy: 0.001)
    }
    
    // MARK: - Persistence Tests
    
    func testChecklistStatePersistsAcrossStoreInstances() {
        // Given
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstItem = firstSection.items.first else {
            XCTFail("Checklist setup failed")
            return
        }
        
        sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: firstItem.id)
        sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: firstItem.id, note: "Persisted note")
        
        // When
        // Clear in-memory state and reload from UserDefaults (simulates app restart)
        sut.checklists = []
        sut.charterChecklistStates = [:]
        XCTAssertTrue(sut.checklists.isEmpty, "Checklists should be cleared")
        XCTAssertTrue(sut.charterChecklistStates.isEmpty, "States should be cleared")
        
        sut.reload()
        
        // Then
        let persistedChecklist = sut.getCheckInChecklist(for: charterId)
        let persistedItem = persistedChecklist?.sections.first?.items.first
        XCTAssertTrue(persistedItem?.isChecked ?? false, "Checked state should persist")
        XCTAssertEqual(persistedItem?.userNote, "Persisted note", "Note should persist")
    }
}

