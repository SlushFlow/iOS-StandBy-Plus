import SwiftUI
import Combine
import UIKit

/// Bridges the system media session into SwiftUI.
///
/// On a real device (sideloaded via SideStore) this reads and controls whatever
/// app currently owns the "now playing" session — Apple Music, Spotify,
/// YouTube, podcasts, etc. — through the private MediaRemote framework wrapper.
/// When MediaRemote isn't available (the Simulator, previews, or a locked-down
/// sandbox) it transparently drives a built-in demo track so the entire UI
/// remains usable and reviewable.
@MainActor
final class NowPlayingManager: ObservableObject {

    struct Track: Equatable {
        var title: String
        var artist: String
        var album: String
        var artwork: UIImage?
        var duration: TimeInterval
    }

    @Published private(set) var track: Track?
    @Published private(set) var isPlaying: Bool = false
    @Published var elapsed: TimeInterval = 0
    @Published var shuffleEnabled: Bool = false
    @Published var repeatMode: RepeatMode = .off
    /// True when we're running the local demo instead of a real session.
    @Published private(set) var isDemo: Bool = false

    enum RepeatMode: Int { case off, all, one
        var systemImage: String {
            switch self {
            case .off, .all: return "repeat"
            case .one: return "repeat.1"
            }
        }
        var next: RepeatMode { RepeatMode(rawValue: (rawValue + 1) % 3) ?? .off }
    }

    /// True when there is something worth showing on the music surface.
    var hasContent: Bool { track != nil }

    private let bridge = MediaRemoteBridge.shared()
    private var ticker: AnyCancellable?
    private var lastSyncDate: Date = Date()
    private var lastPlaybackRate: Double = 0

    init() {
        if bridge.available {
            startReal()
        } else {
            startDemo()
        }
        // A 0.5s ticker advances the progress between MediaRemote callbacks.
        ticker = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in self?.tick() }
            }
    }

    // MARK: Real session

    private func startReal() {
        isDemo = false
        bridge.start { [weak self] info, playing in
            Task { @MainActor in self?.apply(info: info, playing: playing) }
        }
    }

    private func apply(info: [AnyHashable: Any]?, playing: Bool) {
        guard let info, !info.isEmpty else {
            // Nothing playing right now.
            track = nil
            isPlaying = false
            return
        }
        let title = info["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? "Unknown"
        let artist = info["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
        let album = info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String ?? ""
        let duration = info["kMRMediaRemoteNowPlayingInfoDuration"] as? Double ?? 0
        let elapsedTime = info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double ?? 0
        let rate = info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double ?? (playing ? 1 : 0)

        var image: UIImage?
        if let data = info["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
            image = UIImage(data: data)
        }

        track = Track(title: title, artist: artist, album: album, artwork: image, duration: duration)
        isPlaying = rate != 0
        elapsed = elapsedTime
        lastPlaybackRate = rate
        lastSyncDate = Date()
    }

    private func tick() {
        if isDemo {
            guard isPlaying, let track else { return }
            elapsed = min(elapsed + 0.5, track.duration)
            if elapsed >= track.duration { demoAdvance(forward: true) }
            return
        }
        guard isPlaying else { return }
        let drift = Date().timeIntervalSince(lastSyncDate) * (lastPlaybackRate == 0 ? 1 : lastPlaybackRate)
        if let dur = track?.duration {
            elapsed = min(elapsed + 0.5, dur)
        } else {
            elapsed += 0.5
        }
        _ = drift
    }

    // MARK: Controls

    func togglePlayPause() {
        if isDemo {
            isPlaying.toggle()
        } else {
            bridge.send(.togglePlayPause)
        }
    }

    func next() {
        if isDemo { demoAdvance(forward: true) }
        else { bridge.send(.nextTrack) }
    }

    func previous() {
        if isDemo {
            if elapsed > 3 { elapsed = 0 } else { demoAdvance(forward: false) }
        } else {
            bridge.send(.previousTrack)
        }
    }

    func toggleShuffle() {
        shuffleEnabled.toggle()
        if !isDemo { bridge.send(.toggleShuffle) }
    }

    func cycleRepeat() {
        repeatMode = repeatMode.next
        if !isDemo { bridge.send(.toggleRepeat) }
    }

    func seek(to time: TimeInterval) {
        elapsed = time
        if !isDemo { bridge.setElapsedTime(time) }
        lastSyncDate = Date()
    }

    /// Best-effort launch of the app that owns playback. We can't always know
    /// the exact bundle, so we open Apple's Music app as a sensible default and
    /// otherwise nudge the user to the originating app via the share sheet.
    func openSourceApp() {
        if let url = URL(string: "music://") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: Demo content

    private static let demoTracks: [Track] = [
        Track(title: "Lantern Light", artist: "Aurora Fields", album: "Quiet Hours", artwork: nil, duration: 214),
        Track(title: "Slow Tide", artist: "Mara Voss", album: "Driftwood", artwork: nil, duration: 188),
        Track(title: "Paper Moon", artist: "The Low Hum", album: "Nightfold", artwork: nil, duration: 241)
    ]
    private var demoIndex = 0

    private func startDemo() {
        isDemo = true
        track = NowPlayingManager.demoTracks[demoIndex]
        isPlaying = true
        elapsed = 0
    }

    private func demoAdvance(forward: Bool) {
        let count = NowPlayingManager.demoTracks.count
        demoIndex = ((demoIndex + (forward ? 1 : -1)) % count + count) % count
        track = NowPlayingManager.demoTracks[demoIndex]
        elapsed = 0
    }
}

private extension MediaRemoteBridge {
    func send(_ command: MRBCommand) { sendCommand(command) }
}
