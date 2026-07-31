import UIKit
import TikTokOpenSDKCore

final class TikTokAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        TikTokURLHandler.handleOpenURL(url)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        TikTokURLHandler.handleOpenURL(userActivity.webpageURL)
    }
}
