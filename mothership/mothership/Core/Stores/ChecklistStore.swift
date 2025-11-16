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
    var checklists: [Checklist] = []
    var charterChecklistStates: [UUID: CharterChecklistStates] = [:]
    
    private let userDefaultsKey = "ChecklistStore.v1"
    private let charterStatesKey = "CharterChecklistStates.v1"
    
    init() {
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
            // Apply saved state to items
            for sectionIndex in checklist.sections.indices {
                for itemIndex in checklist.sections[sectionIndex].items.indices {
                    let itemId = checklist.sections[sectionIndex].items[itemIndex].id
                    if let itemState = state.itemStates[itemId] {
                        checklist.sections[sectionIndex].items[itemIndex].isChecked = itemState.isChecked
                        checklist.sections[sectionIndex].items[itemIndex].checkedAt = itemState.checkedAt
                        checklist.sections[sectionIndex].items[itemIndex].userNote = itemState.userNote
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
        guard var checklist = checklists.first(where: { $0.id == checklistId }) else { return }
        
        // Find and toggle the item
        for sectionIndex in checklist.sections.indices {
            if let itemIndex = checklist.sections[sectionIndex].items.firstIndex(where: { $0.id == itemId }) {
                checklist.sections[sectionIndex].items[itemIndex].isChecked.toggle()
                let isChecked = checklist.sections[sectionIndex].items[itemIndex].isChecked
                checklist.sections[sectionIndex].items[itemIndex].checkedAt = isChecked ? Date() : nil
                
                // Update checklist
                if let index = checklists.firstIndex(where: { $0.id == checklistId }) {
                    checklists[index] = checklist
                }
                
                // Save state if charter-scoped
                if let charterId = charterId {
                    var state = getChecklistState(for: charterId, checklistId: checklistId) ?? ChecklistState(checklistId: checklistId)
                    let userNote = checklist.sections[sectionIndex].items[itemIndex].userNote
                    state.itemStates[itemId] = ChecklistItemState(
                        isChecked: isChecked,
                        checkedAt: checklist.sections[sectionIndex].items[itemIndex].checkedAt,
                        userNote: userNote
                    )
                    updateChecklistState(for: charterId, checklistId: checklistId, state: state)
                }
                
                save()
                return
            }
        }
    }
    
    func updateItemNote(for charterId: UUID?, checklistId: UUID, itemId: UUID, note: String?) {
        guard var checklist = checklists.first(where: { $0.id == checklistId }) else { return }
        
        for sectionIndex in checklist.sections.indices {
            if let itemIndex = checklist.sections[sectionIndex].items.firstIndex(where: { $0.id == itemId }) {
                checklist.sections[sectionIndex].items[itemIndex].userNote = note
                
                if let index = checklists.firstIndex(where: { $0.id == checklistId }) {
                    checklists[index] = checklist
                }
                
                if let charterId = charterId {
                    var state = getChecklistState(for: charterId, checklistId: checklistId) ?? ChecklistState(checklistId: checklistId)
                    let isChecked = checklist.sections[sectionIndex].items[itemIndex].isChecked
                    let checkedAt = checklist.sections[sectionIndex].items[itemIndex].checkedAt
                    state.itemStates[itemId] = ChecklistItemState(
                        isChecked: isChecked,
                        checkedAt: checkedAt,
                        userNote: note
                    )
                    updateChecklistState(for: charterId, checklistId: checklistId, state: state)
                }
                
                save()
                return
            }
        }
    }
    
    func resetChecklist(for charterId: UUID, checklistId: UUID) {
        guard var checklist = checklists.first(where: { $0.id == checklistId }) else { return }
        
        for sectionIndex in checklist.sections.indices {
            for itemIndex in checklist.sections[sectionIndex].items.indices {
                checklist.sections[sectionIndex].items[itemIndex].isChecked = false
                checklist.sections[sectionIndex].items[itemIndex].checkedAt = nil
                checklist.sections[sectionIndex].items[itemIndex].userNote = nil
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
    
    private func save() {
        if let data = try? JSONEncoder().encode(checklists) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
        
        // Save charter states
        if let statesData = try? JSONEncoder().encode(charterChecklistStates) {
            UserDefaults.standard.set(statesData, forKey: charterStatesKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Checklist].self, from: data) {
            checklists = decoded
        }
        
        if let statesData = UserDefaults.standard.data(forKey: charterStatesKey),
           let decoded = try? JSONDecoder().decode([UUID: CharterChecklistStates].self, from: statesData) {
            charterChecklistStates = decoded
        }
    }
}

// MARK: - Environment Key

private struct ChecklistStoreKey: EnvironmentKey {
    static let defaultValue = ChecklistStore()
}

extension EnvironmentValues {
    var checklistStore: ChecklistStore {
        get { self[ChecklistStoreKey.self] }
        set { self[ChecklistStoreKey.self] = newValue }
    }
}

