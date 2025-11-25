//
//  mothershipApp.swift
//  mothership
//
//  Created by Денис on 11/15/25.
//

import SwiftUI

@main
struct mothershipApp: App {
    @State private var model = AppModel()
    @State private var localization = LocalizationService()
    @State private var charterStore = CharterStore()
    @State private var checklistStore = ChecklistStore()
    @State private var flashcardStore = FlashcardStore()
    @State private var userStore = UserStore()
    @State private var contentFetcherStore = ContentFetcherStore()

    var body: some Scene {
        WindowGroup {
            AppView(model: model)
                .environment(\.localization, localization)
                .environment(\.charterStore, charterStore)
                .environment(\.checklistStore, checklistStore)
                .environment(\.flashcardStore, flashcardStore)
                .environment(\.userStore, userStore)
                .environment(\.contentFetcherStore, contentFetcherStore)
        }
    }
}
