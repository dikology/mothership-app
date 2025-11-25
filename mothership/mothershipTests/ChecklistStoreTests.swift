//
//  ChecklistStoreTests.swift
//  mothershipTests
//
//  Unit tests for ChecklistStore - Swift Testing version
//

import Testing
@testable import mothership
import Foundation

@MainActor
struct ChecklistStoreTests {
    
    // MARK: - Test Fixtures
    
    func makeTestStore() -> ChecklistStore {
        let testUserDefaults = UserDefaults(suiteName: "ChecklistStoreTests")!
        testUserDefaults.removePersistentDomain(forName: "ChecklistStoreTests")
        return ChecklistStore(userDefaults: testUserDefaults)
    }
    
    func cleanupStore(_ store: ChecklistStore) {
        // Cleanup is handled by creating a new UserDefaults suite for each test
        // The suite is cleaned up in makeTestStore()
    }
    
    // MARK: - Initialization Tests
    
    @Test("ChecklistStore initializes with default check-in checklist")
    func initialization_DefaultCheckInChecklist() async throws {
        // Given & When
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        
        // Then
        let checkInChecklist = sut.getCheckInChecklist()
        #expect(checkInChecklist != nil, "Check-in checklist should be created on init")
        #expect(checkInChecklist?.type == .charterScoped)
        #expect(checkInChecklist?.charterType == .checkIn)
        #expect(!(checkInChecklist?.sections.isEmpty ?? true), "Check-in checklist should have sections")
    }
    
    // MARK: - Checklist Retrieval Tests
    
    @Test("Get check-in checklist returns correct checklist")
    func retrieval_CheckInChecklist() async throws {
        // Given & When
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let checklist = sut.getCheckInChecklist()
        
        // Then
        #expect(checklist != nil)
        #expect(checklist?.title.contains("Check-in") ?? false)
    }
    
    @Test("Get check-in checklist for charter returns checklist with charter ID")
    func retrieval_CheckInChecklistForCharter() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charterId = UUID()
        
        // When
        let checklist = sut.getCheckInChecklist(for: charterId)
        
        // Then
        #expect(checklist != nil)
        #expect(checklist?.type == .charterScoped)
    }
    
    // MARK: - Item Toggle Tests
    
    @Test("Toggle item marks item as checked")
    func toggleItem_MarksAsChecked() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstSubsection = firstSection.subsections.first,
              let firstItem = firstSubsection.items.first else {
            Issue.record("Checklist setup failed")
            return
        }
        
        #expect(!firstItem.isChecked, "Item should start unchecked")
        
        // When
        sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: firstItem.id)
        
        // Then
        let updatedChecklist = sut.getCheckInChecklist(for: charterId)
        // Items are in subsections
        let updatedItem = updatedChecklist?.sections.first?.subsections.first?.items.first
        #expect(updatedItem?.isChecked == true, "Item should be checked after toggle")
        #expect(updatedItem?.checkedAt != nil, "checkedAt should be set")
    }
    
    @Test("Toggle item twice unchecks item")
    func toggleItem_TwiceUnchecks() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstSubsection = firstSection.subsections.first,
              let firstItem = firstSubsection.items.first else {
            Issue.record("Checklist setup failed")
            return
        }
        
        // When
        sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: firstItem.id)
        sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: firstItem.id)
        
        // Then
        let updatedChecklist = sut.getCheckInChecklist(for: charterId)
        let updatedItem = updatedChecklist?.sections.first?.subsections.first?.items.first
        #expect(updatedItem?.isChecked == false, "Item should be unchecked after second toggle")
        #expect(updatedItem?.checkedAt == nil, "checkedAt should be nil when unchecked")
    }
    
    // MARK: - User Note Tests
    
    @Test("Update item note adds note to item")
    func updateNote_AddsNote() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charterId = UUID()
        let testNote = "Test note for this item"
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstSubsection = firstSection.subsections.first,
              let firstItem = firstSubsection.items.first else {
            Issue.record("Checklist setup failed")
            return
        }
        
        // When
        sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: firstItem.id, note: testNote)
        
        // Then
        let updatedChecklist = sut.getCheckInChecklist(for: charterId)
        let updatedItem = updatedChecklist?.sections.first?.subsections.first?.items.first
        #expect(updatedItem?.userNote == testNote)
    }
    
    @Test("Update item note with nil clears note")
    func updateNote_NilClearsNote() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstSubsection = firstSection.subsections.first,
              let firstItem = firstSubsection.items.first else {
            Issue.record("Checklist setup failed")
            return
        }
        
        // Add note first
        sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: firstItem.id, note: "Initial note")
        
        // When
        sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: firstItem.id, note: nil)
        
        // Then
        let updatedChecklist = sut.getCheckInChecklist(for: charterId)
        let updatedItem = updatedChecklist?.sections.first?.subsections.first?.items.first
        #expect(updatedItem?.userNote == nil)
    }
    
    // MARK: - Charter-Specific State Tests
    
    @Test("Different charters have separate checklist states")
    func charterState_SeparateStates() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charter1Id = UUID()
        let charter2Id = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstSubsection = firstSection.subsections.first,
              let firstItem = firstSubsection.items.first else {
            Issue.record("Checklist setup failed")
            return
        }
        
        // When
        sut.toggleItem(for: charter1Id, checklistId: checklist.id, itemId: firstItem.id)
        
        // Then
        let charter1Checklist = sut.getCheckInChecklist(for: charter1Id)
        let charter2Checklist = sut.getCheckInChecklist(for: charter2Id)
        
        let charter1Item = charter1Checklist?.sections.first?.subsections.first?.items.first
        let charter2Item = charter2Checklist?.sections.first?.subsections.first?.items.first
        
        #expect(charter1Item?.isChecked == true, "Charter 1 item should be checked")
        #expect(charter2Item?.isChecked == false, "Charter 2 item should not be checked")
    }
    
    // MARK: - Reset Tests
    
    @Test("Reset checklist clears all items")
    func reset_ClearsAllItems() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist() else {
            Issue.record("Checklist setup failed")
            return
        }
        
        // Check a few items first
        for section in checklist.sections.prefix(2) {
            for subsection in section.subsections.prefix(2) {
                for item in subsection.items.prefix(3) {
                    sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: item.id)
                    sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: item.id, note: "Test note")
                }
            }
        }
        
        // When
        sut.resetChecklist(for: charterId, checklistId: checklist.id)
        
        // Then
        let resetChecklist = sut.getCheckInChecklist(for: charterId)
        let allItemsUnchecked = resetChecklist?.sections.allSatisfy { section in
            section.subsections.allSatisfy { subsection in
                subsection.items.allSatisfy { !$0.isChecked && $0.userNote == nil }
            }
        }
        #expect(allItemsUnchecked == true, "All items should be unchecked and notes cleared")
    }
    
    // MARK: - Progress Calculation Tests
    
    @Test("Calculate progress with no items checked returns zero")
    func progress_NoItemsChecked() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        guard let checklist = sut.getCheckInChecklist() else {
            Issue.record("Checklist setup failed")
            return
        }
        
        // When
        let progress = sut.calculateProgress(for: checklist)
        
        // Then
        #expect(abs(progress - 0.0) < 0.001)
    }
    
    @Test("Calculate progress with some items checked returns correct value")
    func progress_SomeItemsChecked() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charterId = UUID()
        guard let baseChecklist = sut.getCheckInChecklist() else {
            Issue.record("Checklist setup failed")
            return
        }
        
        // Check first 5 items
        var itemsChecked = 0
        var totalItems = 0
        for section in baseChecklist.sections {
            for subsection in section.subsections {
                for item in subsection.items {
                    totalItems += 1
                    if itemsChecked < 5 {
                        sut.toggleItem(for: charterId, checklistId: baseChecklist.id, itemId: item.id)
                        itemsChecked += 1
                    }
                }
            }
        }
        
        // When
        guard let checklist = sut.getCheckInChecklist(for: charterId) else {
            Issue.record("Could not get checklist")
            return
        }
        let progress = sut.calculateProgress(for: checklist)
        
        // Then
        let expectedProgress = Double(itemsChecked) / Double(totalItems)
        #expect(abs(progress - expectedProgress) < 0.001)
    }
    
    @Test("Calculate progress with all items checked returns one")
    func progress_AllItemsChecked() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charterId = UUID()
        guard let baseChecklist = sut.getCheckInChecklist() else {
            Issue.record("Checklist setup failed")
            return
        }
        
        // Check all items
        for section in baseChecklist.sections {
            for subsection in section.subsections {
                for item in subsection.items {
                    sut.toggleItem(for: charterId, checklistId: baseChecklist.id, itemId: item.id)
                }
            }
        }
        
        // When
        guard let checklist = sut.getCheckInChecklist(for: charterId) else {
            Issue.record("Could not get checklist")
            return
        }
        let progress = sut.calculateProgress(for: checklist)
        
        // Then
        #expect(abs(progress - 1.0) < 0.001)
    }
    
    // MARK: - Persistence Tests
    
    @Test("Checklist state persists across store instances")
    func persistence_StatePersists() async throws {
        // Given
        let sut = makeTestStore()
        defer { cleanupStore(sut) }
        let charterId = UUID()
        guard let checklist = sut.getCheckInChecklist(),
              let firstSection = checklist.sections.first,
              let firstSubsection = firstSection.subsections.first,
              let firstItem = firstSubsection.items.first else {
            Issue.record("Checklist setup failed")
            return
        }
        
        sut.toggleItem(for: charterId, checklistId: checklist.id, itemId: firstItem.id)
        sut.updateItemNote(for: charterId, checklistId: checklist.id, itemId: firstItem.id, note: "Persisted note")
        
        // When
        // Clear in-memory state and reload from UserDefaults (simulates app restart)
        sut.clearInMemoryStateForTesting()
        #expect(sut.getCheckInChecklist() == nil, "Checklists should be cleared")
        #expect(sut.charterChecklistStates.isEmpty, "States should be cleared")
        
        sut.reload()
        
        // Then
        let persistedChecklist = sut.getCheckInChecklist(for: charterId)
        let persistedItem = persistedChecklist?.sections.first?.subsections.first?.items.first
        #expect(persistedItem?.isChecked == true, "Checked state should persist")
        #expect(persistedItem?.userNote == "Persisted note", "Note should persist")
    }
}
