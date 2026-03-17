import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @AppStorage("selectedTranslation") var selectedTranslation: String = BibleTranslation.kjv.rawValue
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    @AppStorage("fontSize") var fontSize: String = "medium"

    var translation: BibleTranslation {
        get { BibleTranslation(rawValue: selectedTranslation) ?? .kjv }
        set { selectedTranslation = newValue.rawValue }
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
