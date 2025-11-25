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

private struct UserStoreKey: EnvironmentKey {
    static var defaultValue: UserStore {
        UserStore()
    }
}

private struct ContentFetcherStoreKey: EnvironmentKey {
    static var defaultValue: ContentFetcherStore {
        ContentFetcherStore()
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
    
    var userStore: UserStore {
        get { self[UserStoreKey.self] }
        set { self[UserStoreKey.self] = newValue }
    }
    
    var contentFetcherStore: ContentFetcherStore {
        get { self[ContentFetcherStoreKey.self] }
        set { self[ContentFetcherStoreKey.self] = newValue }
    }
}

