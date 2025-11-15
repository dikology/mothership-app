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
    var charters: [Charter] = []
    
    private let userDefaultsKey = "CharterStore.v1"
    
    init() {
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
    }
    
    func updateCharter(_ charter: Charter) {
        if let index = charters.firstIndex(where: { $0.id == charter.id }) {
            charters[index] = charter
            charters.sort { $0.startDate > $1.startDate }
            save()
        }
    }
    
    func deleteCharter(_ charter: Charter) {
        charters.removeAll { $0.id == charter.id }
        save()
    }
    
    private func save() {
        // Save charters
        if let data = try? JSONEncoder().encode(charters) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func load() {
        // Load charters
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Charter].self, from: data) {
            charters = decoded.sorted { $0.startDate > $1.startDate }
        }
    }
}

