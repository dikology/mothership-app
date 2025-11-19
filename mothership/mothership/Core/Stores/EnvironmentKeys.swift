//
//  EnvironmentKeys.swift
//  mothership
//
//  Environment keys for stores
//

import SwiftUI

private struct CharterStoreKey: EnvironmentKey {
    static var defaultValue: CharterStore {
        CharterStore()
    }
}

extension EnvironmentValues {
    var charterStore: CharterStore {
        get { self[CharterStoreKey.self] }
        set { self[CharterStoreKey.self] = newValue }
    }
    
}

