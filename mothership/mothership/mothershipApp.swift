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

    var body: some Scene {
        WindowGroup {
            AppView(model: model)
                .environment(\.localization, localization)
                .environment(\.charterStore, charterStore)
                .environment(\.checklistStore, checklistStore)
        }
    }
}
