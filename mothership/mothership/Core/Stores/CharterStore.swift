//
//  CharterStore.swift
//  mothership
//
//  Store for managing charters
//

import Foundation
import SwiftUI
//import Tagged

@Observable
final class CharterStore {
    private(set) var charters: [Charter] = []
    var charterState: ViewState<[Charter]> = .idle
    
    private let userDefaultsKey = "CharterStore.v1"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        markChartersLoading()
        load()
    }
    
    /// Returns the currently active charter based on dates.
    /// A charter is active if the current date falls between its start and end dates.
    /// If multiple charters are active, returns the most recently created one.
    var activeCharter: Charter? {
        charters.first { $0.isActive }
    }
    
    func addCharter(_ charter: Charter) {
        charters.append(charter)
        charters.sort { $0.startDate > $1.startDate }
        save()
        markChartersLoaded()
    }
    
    func updateCharter(_ charter: Charter) {
        if let index = charters.firstIndex(where: { $0.id == charter.id }) {
            charters[index] = charter
            charters.sort { $0.startDate > $1.startDate }
            save()
            markChartersLoaded()
        }
    }
    
    func deleteCharter(_ charter: Charter) {
        charters.removeAll { $0.id == charter.id }
        save()
        markChartersLoaded()
    }
    
    func reload() {
        markChartersLoading()
        load()
    }
    
    private func save() {
        // Save charters
        if let data = try? JSONEncoder().encode(charters) {
            userDefaults.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func load() {
        // Load charters
        if let data = userDefaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Charter].self, from: data) {
            charters = decoded.sorted { $0.startDate > $1.startDate }
            markChartersLoaded()
        } else {
            charterState = .empty
        }
    }
    
    // MARK: - View State Helpers
    
    func markChartersLoading() {
        charterState = .loading
    }
    
    func markChartersLoaded() {
        if charters.isEmpty {
            charterState = .empty
        } else {
            charterState = .loaded(charters)
        }
    }
    
    func markChartersError(_ error: AppError) {
        charterState = .error(error)
    }
}

