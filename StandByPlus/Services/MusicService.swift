import AVFoundation
import MediaPlayer
import UIKit

@MainActor
final class MusicService: ObservableObject {
    @Published private(set) var track = NowPlayingTrack.empty
    @Published private(set) var volume: Float = 0.5

    private let systemPlayer = MPMusicPlayerController.systemMusicPlayer
    private var refreshTimer: Timer?
    private var nowPlayingObserver: NSObjectProtocol?

    func startObserving() {
        setupAudioSession()
        systemPlayer.beginGeneratingPlaybackNotifications()

        NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: systemPlayer,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshNowPlaying()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: systemPlayer,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshNowPlaying()
            }
        }

        nowPlayingObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("MPNowPlayingInfoDidChangeNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshNowPlaying()
            }
        }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshNowPlaying()
            }
        }

        volume = AVAudioSession.sharedInstance().outputVolume
        refreshNowPlaying()
    }

    func openMusicApp() {
        let source = track.source
        var urlString: String?

        switch source {
        case .appleMusic:
            urlString = "music://"
        case .spotify:
            urlString = "spotify://"
        case .unknown:
            if let bundle = track.bundleIdentifier?.lowercased() {
                if bundle.contains("spotify") {
                    urlString = "spotify://"
                } else if bundle.contains("music") {
                    urlString = "music://"
                }
            }
        }

        guard let urlString, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    func togglePlayPause() {
        if systemPlayer.playbackState == .playing {
            systemPlayer.pause()
        } else {
            systemPlayer.play()
        }
        sendMediaCommand(.togglePlayPause)
        refreshNowPlaying()
        HapticManager.light()
    }

    func nextTrack() {
        systemPlayer.skipToNextItem()
        sendMediaCommand(.nextTrack)
        refreshNowPlaying()
        HapticManager.light()
    }

    func previousTrack() {
        if track.elapsed > 3 {
            systemPlayer.skipToBeginning()
        } else {
            systemPlayer.skipToPreviousItem()
        }
        sendMediaCommand(.previousTrack)
        refreshNowPlaying()
        HapticManager.light()
    }

    func toggleShuffle() {
        let newMode: MPMusicShuffleMode = systemPlayer.shuffleMode == .off ? .songs : .off
        systemPlayer.shuffleMode = newMode
        refreshNowPlaying()
        HapticManager.light()
    }

    func cycleRepeatMode() {
        switch systemPlayer.repeatMode {
        case .default, .none:
            systemPlayer.repeatMode = .all
        case .all:
            systemPlayer.repeatMode = .one
        case .one:
            systemPlayer.repeatMode = .none
        @unknown default:
            systemPlayer.repeatMode = .none
        }
        refreshNowPlaying()
        HapticManager.light()
    }

    func seek(to progress: Double) {
        let clamped = min(max(progress, 0), 1)
        let target = track.duration * clamped
        systemPlayer.currentPlaybackTime = target
        refreshNowPlaying()
    }

    func setVolume(_ value: Float) {
        volume = min(max(value, 0), 1)
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Non-fatal for read-only now playing display.
        }
    }

    private func refreshNowPlaying() {
        let info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        let item = systemPlayer.nowPlayingItem

        let title = (info?[MPMediaItemPropertyTitle] as? String)
            ?? item?.title
            ?? (systemPlayer.playbackState == .playing ? "Now Playing" : NowPlayingTrack.empty.title)

        let artist = (info?[MPMediaItemPropertyArtist] as? String)
            ?? item?.artist
            ?? NowPlayingTrack.empty.artist

        let album = (info?[MPMediaItemPropertyAlbumTitle] as? String)
            ?? item?.albumTitle
            ?? ""

        let duration = (info?[MPMediaItemPropertyPlaybackDuration] as? NSNumber)?.doubleValue
            ?? item?.playbackDuration
            ?? 0

        let elapsed = (info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? NSNumber)?.doubleValue
            ?? systemPlayer.currentPlaybackTime

        let playbackRate = (info?[MPNowPlayingInfoPropertyPlaybackRate] as? NSNumber)?.doubleValue ?? 0
        let isPlaying = systemPlayer.playbackState == .playing || playbackRate > 0

        var artworkData: Data?
        if let artwork = (info?[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork)
            ?? item?.artwork {
            artworkData = artwork.image(at: CGSize(width: 300, height: 300))?.pngData()
        }

        let bundleID = info?["kMRMediaRemoteNowPlayingApplicationPID"] as? String
            ?? info?["kMRMediaRemoteNowPlayingApplicationDisplayName"] as? String

        let repeatMode: RepeatMode = {
            switch systemPlayer.repeatMode {
            case .one: return .one
            case .all: return .all
            default: return .off
            }
        }()

        track = NowPlayingTrack(
            title: title,
            artist: artist,
            album: album,
            artworkData: artworkData,
            duration: duration,
            elapsed: elapsed,
            isPlaying: isPlaying,
            shuffleEnabled: systemPlayer.shuffleMode != .off,
            repeatMode: repeatMode,
            source: MusicSource.detect(from: bundleID),
            bundleIdentifier: bundleID
        )

        volume = AVAudioSession.sharedInstance().outputVolume
    }

    private enum MediaCommand {
        case togglePlayPause
        case nextTrack
        case previousTrack
    }

    private func sendMediaCommand(_ command: MediaCommand) {
        let center = MPRemoteCommandCenter.shared()
        switch command {
        case .togglePlayPause:
            _ = center.togglePlayPauseCommand
        case .nextTrack:
            _ = center.nextTrackCommand
        case .previousTrack:
            _ = center.previousTrackCommand
        }
    }
}
