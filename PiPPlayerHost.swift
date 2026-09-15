import SwiftUI
import AVFoundation
import UIKit

struct PiPPlayerHost: UIViewRepresentable {
    @EnvironmentObject private var pipManager: PiPManager

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.backgroundColor = UIColor(red: 0.04, green: 0.06, blue: 0.10, alpha: 1)
        pipManager.attach(to: view.playerLayer)
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}
}

final class PlayerContainerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}
