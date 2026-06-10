import SwiftUI
import MediaPlayer
import AVFoundation
import Combine
import UIKit

/// Reads and writes the system output volume.
///
/// Reading is done through `AVAudioSession.outputVolume` (KVO observed). Writing
/// uses the classic trick of locating the hidden `UISlider` inside an offscreen
/// `MPVolumeView`, which lets us set the hardware volume without showing the
/// system HUD. On the Simulator there is no real volume hardware, so this simply
/// tracks an in-memory value.
@MainActor
final class VolumeController: ObservableObject {
    @Published var volume: Double = 0.5

    private let volumeView = MPVolumeView(frame: .zero)
    private var slider: UISlider?
    private var observation: NSKeyValueObservation?
    private var applyingExternally = false

    init() {
        volumeView.alpha = 0.0001
        volumeView.isUserInteractionEnabled = false
        // Defer until we can attach to a window so the slider materialises.
        Task { @MainActor in self.attach() }

        let session = AVAudioSession.sharedInstance()
        try? session.setActive(true)
        volume = Double(session.outputVolume)
        observation = session.observe(\.outputVolume, options: [.new]) { [weak self] _, change in
            guard let self, let new = change.newValue else { return }
            Task { @MainActor in
                self.applyingExternally = true
                self.volume = Double(new)
                self.applyingExternally = false
            }
        }
    }

    private func attach() {
        if let window = Self.activeWindow {
            window.addSubview(volumeView)
        }
        slider = volumeView.subviews.compactMap { $0 as? UISlider }.first
    }

    /// Push a user-chosen value (0...1) to the hardware.
    func setVolume(_ value: Double) {
        guard !applyingExternally else { return }
        volume = value
        if slider == nil { attach() }
        slider?.value = Float(value)
        // Sending touch events makes the change take effect immediately.
        slider?.sendActions(for: .touchUpInside)
    }

    private static var activeWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ??
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first
    }
}
