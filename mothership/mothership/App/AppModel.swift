import SwiftUI

@Observable
final class AppModel {
    var path: [AppPath] = []

    // Note: Stores and services are passed via environment, not stored here
    // to avoid nested @Observable objects which cause memory issues

    init() {
        // All dependencies are created at app level and passed via environment
    }

}