import Foundation
import Photos
import TikTokOpenShareSDK
import UIKit

@MainActor
@Observable
final class TikTokVerseShareService {
    static let redirectURI = "https://mybiblecopilot.com/tiktok/share"

    var isSharing = false
    var alertTitle = ""
    var alertMessage = ""
    var showsAlert = false

    private var request: TikTokShareRequest?

    func share(images: [UIImage]) async {
        guard images.count >= 2 else {
            showError("Bible Copilot needs two verse cards to create a TikTok photo post.")
            return
        }

        isSharing = true
        AnalyticsService.shared.track(AnalyticsEvent.tiktokShareStarted)

        do {
            let identifiers = try await saveToPhotoLibrary(images)
            let request = TikTokShareRequest(
                localIdentifiers: identifiers,
                mediaType: .image,
                redirectURI: Self.redirectURI
            )
            request.shareFormat = .normal
            request.state = UUID().uuidString
            self.request = request

            let didOpenTikTok = request.send { [weak self] response in
                guard let shareResponse = response as? TikTokShareResponse else { return }
                Task { @MainActor in
                    self?.handle(shareResponse)
                }
            }

            if !didOpenTikTok {
                self.request = nil
                isSharing = false
                showError("TikTok could not be opened. Install or update TikTok, then try again.")
            }
        } catch {
            isSharing = false
            showError(error.localizedDescription)
        }
    }

    private func saveToPhotoLibrary(_ images: [UIImage]) async throws -> [String] {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized || status == .limited else {
            throw TikTokVerseShareError.photoAccessDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            var identifiers: [String] = []
            PHPhotoLibrary.shared().performChanges {
                for image in images {
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    if let identifier = request.placeholderForCreatedAsset?.localIdentifier {
                        identifiers.append(identifier)
                    }
                }
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success, identifiers.count == images.count {
                    continuation.resume(returning: identifiers)
                } else {
                    continuation.resume(throwing: TikTokVerseShareError.photoSaveFailed)
                }
            }
        }
    }

    private func handle(_ response: TikTokShareResponse) {
        request = nil
        isSharing = false

        if response.errorCode == .noError {
            AnalyticsService.shared.track(AnalyticsEvent.tiktokShareSucceeded)
            alertTitle = "Sent to TikTok"
            alertMessage = "Your verse cards are ready to edit and post in TikTok."
            showsAlert = true
        } else if response.errorCode != .cancelled {
            AnalyticsService.shared.track(
                AnalyticsEvent.tiktokShareFailed,
                ["state": "\(response.shareState.rawValue)"]
            )
            showError(
                response.errorDescription ?? "TikTok could not share these verse cards.",
                trackFailure: false
            )
        }
    }

    private func showError(_ message: String, trackFailure: Bool = true) {
        if trackFailure {
            AnalyticsService.shared.track(AnalyticsEvent.tiktokShareFailed)
        }
        alertTitle = "Couldn’t share to TikTok"
        alertMessage = message
        showsAlert = true
    }
}

enum TikTokVerseShareError: LocalizedError {
    case photoAccessDenied
    case photoSaveFailed

    var errorDescription: String? {
        switch self {
        case .photoAccessDenied:
            return "Allow Bible Copilot to access Photos so it can create the verse cards TikTok needs."
        case .photoSaveFailed:
            return "The verse cards could not be saved to Photos. Please try again."
        }
    }
}
