import Foundation
import AVFoundation
import AVKit
import UIKit

@MainActor
final class PiPManager: NSObject, ObservableObject {
    @Published private(set) var isReady = false
    @Published private(set) var isPictureInPictureActive = false
    @Published private(set) var statusMessage = "Preparing native PiP…"

    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var pipController: AVPictureInPictureController?
    private var pendingProvider: NavigationProvider?

    override init() {
        super.init()
        configureAudioSession()
    }

    func attach(to playerLayer: AVPlayerLayer) {
        guard player == nil else {
            playerLayer.player = player
            return
        }

        guard let url = Bundle.main.url(forResource: "pip-dashboard", withExtension: "mp4") else {
            statusMessage = "PiP test video is missing."
            return
        }

        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer()
        queue.isMuted = true
        queue.actionAtItemEnd = .none
        player = queue
        looper = AVPlayerLooper(player: queue, templateItem: item)

        playerLayer.player = queue
        playerLayer.videoGravity = .resizeAspectFill

        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            statusMessage = "PiP is not supported on this device."
            return
        }

        let controller = AVPictureInPictureController(playerLayer: playerLayer)
        controller?.delegate = self
        controller?.canStartPictureInPictureAutomaticallyFromInline = false
        pipController = controller

        queue.play()
        isReady = true
        statusMessage = "Ready — choose navigation and start."
    }

    func startDrive(using provider: NavigationProvider) {
        guard let controller = pipController else {
            statusMessage = "Native PiP controller is not ready."
            return
        }
        guard controller.isPictureInPicturePossible else {
            statusMessage = "PiP is not possible yet. Wait a moment and retry."
            player?.play()
            return
        }

        pendingProvider = provider
        statusMessage = "Starting PiP…"
        controller.startPictureInPicture()
    }

    private func openPendingNavigation() {
        guard let provider = pendingProvider,
              let url = provider.launchURL else { return }

        pendingProvider = nil
        statusMessage = "PiP active — opening \(provider.rawValue)…"
        UIApplication.shared.open(url, options: [:]) { [weak self] success in
            Task { @MainActor in
                self?.statusMessage = success
                    ? "Navigation opened. Check whether DriveDash stays above it."
                    : "Could not open \(provider.rawValue)."
            }
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            statusMessage = "Audio session warning: \(error.localizedDescription)"
        }
    }
}

extension PiPManager: AVPictureInPictureControllerDelegate {
    nonisolated func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        Task { @MainActor in
            isPictureInPictureActive = true
            openPendingNavigation()
        }
    }

    nonisolated func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        Task { @MainActor in
            pendingProvider = nil
            isPictureInPictureActive = false
            statusMessage = "PiP failed: \(error.localizedDescription)"
        }
    }

    nonisolated func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        Task { @MainActor in
            isPictureInPictureActive = false
            statusMessage = "PiP stopped."
        }
    }
}
