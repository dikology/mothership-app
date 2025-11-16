import SwiftUI

@Observable
final class AppModel {
    var path: [AppPath] = []
    var localization = LocalizationService()

    // Core stores
    var charterStore: CharterStore
    var checklistStore: ChecklistStore

    init(
        charterStore: CharterStore = CharterStore(),
        checklistStore: ChecklistStore = ChecklistStore()
    ) {
        self.charterStore = charterStore
        self.checklistStore = checklistStore
    }

}