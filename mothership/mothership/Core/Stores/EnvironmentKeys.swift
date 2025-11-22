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

private struct FlashcardStoreKey: EnvironmentKey {
    static var defaultValue: FlashcardStore {
        FlashcardStore()
    }
}

extension EnvironmentValues {
    var charterStore: CharterStore {
        get { self[CharterStoreKey.self] }
        set { self[CharterStoreKey.self] = newValue }
    }
    
    var flashcardStore: FlashcardStore {
        get { self[FlashcardStoreKey.self] }
        set { self[FlashcardStoreKey.self] = newValue }
    }
}

