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

    var body: some Scene {
        WindowGroup {
            AppView(model: model)
        }
    }
}
