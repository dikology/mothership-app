//
//  ChecklistStore.swift
//  mothership
//
//  Store for managing checklists
//

import Foundation
import SwiftUI

@Observable
final class ChecklistStore {
    private(set) var checklists: [Checklist] = []
    var checklistState: ViewState<[Checklist]> = .idle
    var charterChecklistStates: [UUID: CharterChecklistStates] = [:]
    
    private let userDefaultsKey = "ChecklistStore.v1"
    private let charterStatesKey = "CharterChecklistStates.v1"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        markChecklistsLoading()
        load()
        // Ensure default check-in checklist exists
        ensureDefaultCheckInChecklist()
    }
    
    // MARK: - Checklist Management
    
    func ensureDefaultCheckInChecklist() {
        // Check if check-in checklist already exists
        let checkInExists = checklists.contains { checklist in
            checklist.type == .charterScoped && checklist.charterType == .checkIn
        }
        
        if !checkInExists {
            let defaultCheckIn = Checklist.defaultCheckInChecklist()
            checklists.append(defaultCheckIn)
            save()
            markChecklistsLoaded()
        }
    }
    
    func getCheckInChecklist() -> Checklist? {
        return checklists.first { checklist in
            checklist.type == .charterScoped && checklist.charterType == .checkIn
        }
    }
    
    func getCheckInChecklist(for charterId: UUID) -> Checklist? {
        guard let baseChecklist = getCheckInChecklist() else { return nil }
        
        // Return a copy with charter-specific state applied
        var checklist = baseChecklist
        if let state = getChecklistState(for: charterId, checklistId: baseChecklist.id) {
            // Apply saved state to items in subsections
            for sectionIndex in checklist.sections.indices {
                for subsectionIndex in checklist.sections[sectionIndex].subsections.indices {
                    for itemIndex in checklist.sections[sectionIndex].subsections[subsectionIndex].items.indices {
                        let itemId = checklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].id
                        if let itemState = state.itemStates[itemId] {
                            checklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].isChecked = itemState.isChecked
                            checklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].checkedAt = itemState.checkedAt
                            checklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].userNote = itemState.userNote
                        }
                    }
                }
            }
        }
        return checklist
    }
    
    // MARK: - State Management
    
    func getChecklistState(for charterId: UUID, checklistId: UUID) -> ChecklistState? {
        return charterChecklistStates[charterId]?.checklistStates[checklistId]
    }
    
    func updateChecklistState(for charterId: UUID, checklistId: UUID, state: ChecklistState) {
        if charterChecklistStates[charterId] == nil {
            charterChecklistStates[charterId] = CharterChecklistStates(charterId: charterId)
        }
        charterChecklistStates[charterId]?.checklistStates[checklistId] = state
        save()
    }
    
    func toggleItem(for charterId: UUID?, checklistId: UUID, itemId: UUID) {
        guard let checklist = checklists.first(where: { $0.id == checklistId }) else { return }
        
        // Find the item in subsections
        for sectionIndex in checklist.sections.indices {
            for subsectionIndex in checklist.sections[sectionIndex].subsections.indices {
                if let itemIndex = checklist.sections[sectionIndex].subsections[subsectionIndex].items.firstIndex(where: { $0.id == itemId }) {
                    let item = checklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex]
                    
                    if let charterId = charterId {
                        // Charter-scoped: only update the charter-specific state
                        var state = getChecklistState(for: charterId, checklistId: checklistId) ?? ChecklistState(checklistId: checklistId)
                        let currentIsChecked = state.itemStates[itemId]?.isChecked ?? item.isChecked
                        let newIsChecked = !currentIsChecked
                        state.itemStates[itemId] = ChecklistItemState(
                            isChecked: newIsChecked,
                            checkedAt: newIsChecked ? Date() : nil,
                            userNote: state.itemStates[itemId]?.userNote ?? item.userNote
                        )
                        updateChecklistState(for: charterId, checklistId: checklistId, state: state)
                    } else {
                        // Reference checklist: update the base checklist
                        var mutableChecklist = checklist
                        mutableChecklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].isChecked.toggle()
                        let isChecked = mutableChecklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].isChecked
                        mutableChecklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].checkedAt = isChecked ? Date() : nil
                        
                        if let index = checklists.firstIndex(where: { $0.id == checklistId }) {
                            checklists[index] = mutableChecklist
                        }
                        save()
                        markChecklistsLoaded()
                    }
                    return
                }
            }
        }
    }
    
    func updateItemNote(for charterId: UUID?, checklistId: UUID, itemId: UUID, note: String?) {
        guard let checklist = checklists.first(where: { $0.id == checklistId }) else { return }
        
        for sectionIndex in checklist.sections.indices {
            for subsectionIndex in checklist.sections[sectionIndex].subsections.indices {
                if let itemIndex = checklist.sections[sectionIndex].subsections[subsectionIndex].items.firstIndex(where: { $0.id == itemId }) {
                    let item = checklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex]
                    
                    if let charterId = charterId {
                        // Charter-scoped: only update the charter-specific state
                        var state = getChecklistState(for: charterId, checklistId: checklistId) ?? ChecklistState(checklistId: checklistId)
                        let existingState = state.itemStates[itemId]
                        state.itemStates[itemId] = ChecklistItemState(
                            isChecked: existingState?.isChecked ?? item.isChecked,
                            checkedAt: existingState?.checkedAt ?? item.checkedAt,
                            userNote: note
                        )
                        updateChecklistState(for: charterId, checklistId: checklistId, state: state)
                    } else {
                        // Reference checklist: update the base checklist
                        var mutableChecklist = checklist
                        mutableChecklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].userNote = note
                        
                        if let index = checklists.firstIndex(where: { $0.id == checklistId }) {
                            checklists[index] = mutableChecklist
                        }
                        save()
                        markChecklistsLoaded()
                    }
                    return
                }
            }
        }
    }
    
    func resetChecklist(for charterId: UUID, checklistId: UUID) {
        guard var checklist = checklists.first(where: { $0.id == checklistId }) else { return }
        
        for sectionIndex in checklist.sections.indices {
            for subsectionIndex in checklist.sections[sectionIndex].subsections.indices {
                for itemIndex in checklist.sections[sectionIndex].subsections[subsectionIndex].items.indices {
                    checklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].isChecked = false
                    checklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].checkedAt = nil
                    checklist.sections[sectionIndex].subsections[subsectionIndex].items[itemIndex].userNote = nil
                }
            }
        }
        
        if let index = checklists.firstIndex(where: { $0.id == checklistId }) {
            checklists[index] = checklist
        }
        
        if charterChecklistStates[charterId] == nil {
            charterChecklistStates[charterId] = CharterChecklistStates(charterId: charterId)
        }
        charterChecklistStates[charterId]?.checklistStates[checklistId] = ChecklistState(
            checklistId: checklistId,
            lastReset: Date()
        )
        save()
        markChecklistsLoaded()
    }
    
    // MARK: - Progress Calculation
    
    func calculateProgress(for checklist: Checklist) -> Double {
        let totalItems = checklist.sections.reduce(0) { $0 + $1.items.count }
        guard totalItems > 0 else { return 0.0 }
        let checkedItems = checklist.sections.reduce(0) { total, section in
            total + section.items.filter { $0.isChecked }.count
        }
        return Double(checkedItems) / Double(totalItems)
    }
    
    // MARK: - Persistence
    
    func reload() {
        markChecklistsLoading()
        load()
    }
    
    /// Clears in-memory state to allow a fresh reload from persistence.
    /// Primarily used by tests to simulate an application restart.
    func clearInMemoryStateForTesting() {
        checklists = []
        charterChecklistStates = [:]
        markChecklistsLoading()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(checklists) {
            userDefaults.set(data, forKey: userDefaultsKey)
        }
        
        // Save charter states
        if let statesData = try? JSONEncoder().encode(charterChecklistStates) {
            userDefaults.set(statesData, forKey: charterStatesKey)
        }
    }
    
    private func load() {
        if let data = userDefaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Checklist].self, from: data) {
            checklists = decoded
            markChecklistsLoaded()
        } else {
            checklists = []
            markChecklistsLoaded()
        }
        
        if let statesData = userDefaults.data(forKey: charterStatesKey),
           let decoded = try? JSONDecoder().decode([UUID: CharterChecklistStates].self, from: statesData) {
            charterChecklistStates = decoded
        }
    }
    
    // MARK: - View State Helpers
    
    func markChecklistsLoading() {
        checklistState = .loading
    }
    
    func markChecklistsLoaded() {
        if checklists.isEmpty {
            checklistState = .empty
        } else {
            checklistState = .loaded(checklists)
        }
    }
    
    func markChecklistsError(_ error: AppError) {
        checklistState = .error(error)
    }
}

// MARK: - Environment Key

private struct ChecklistStoreKey: EnvironmentKey {
    static var defaultValue: ChecklistStore {
        ChecklistStore()
    }
}

extension EnvironmentValues {
    var checklistStore: ChecklistStore {
        get { self[ChecklistStoreKey.self] }
        set { self[ChecklistStoreKey.self] = newValue }
    }
}

