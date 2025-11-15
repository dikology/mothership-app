import SwiftUI

@Observable
final class AppModel {
    var path: [AppPath] = []
    var localization = LocalizationService()
}