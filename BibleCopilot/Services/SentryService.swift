import Foundation
import Sentry

enum SentryService {
    static func start() {
        #if DEBUG
        let runtimeVerification =
            ProcessInfo.processInfo.environment["SENTRY_VERIFY_RUNTIME"] == "1"
        #else
        let runtimeVerification = false
        #endif

        guard
            let dsn = Bundle.main.object(forInfoDictionaryKey: "SentryDSN") as? String,
            dsn.hasPrefix("https://")
        else {
            return
        }

        SentrySDK.start { options in
            options.dsn = dsn
            options.sendDefaultPii = false
            options.attachStacktrace = true
            options.enableAutoSessionTracking = true
            options.enableAppHangTracking = true
            options.tracesSampleRate = 0.05
            options.debug = runtimeVerification

            #if DEBUG
            options.environment = "development"
            #else
            options.environment = "production"
            #endif
        }

        #if DEBUG
        if runtimeVerification {
            let eventId = SentrySDK.capture(message: "Bible Copilot runtime verification")
            SentrySDK.flush(timeout: 5)
            print("SENTRY_RUNTIME_VERIFICATION_EVENT_ID=\(eventId.sentryIdString)")
        }
        #endif
    }
}
