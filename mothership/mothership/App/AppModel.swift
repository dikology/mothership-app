import SwiftUI

@Observable
final class AppModel {
    var path: [AppPath] = []
    var localization = LocalizationService()

    // Core stores
    var charterStore: CharterStore

    init(
        charterStore: CharterStore = CharterStore()
    ) {
        self.charterStore = charterStore
    }

}