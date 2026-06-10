import SwiftUI
import MediaPlayer
import Combine

enum LoopMode: String {
    case none
    case all
    case one
}

class MusicPlayerManager: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var songTitle: String = "Not Playing"
    @Published var artistName: String = ""
    @Published var albumArtwork: UIImage? = nil
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.5
    @Published var loopMode: LoopMode = .none
    @Published var isShuffled: Bool = false
    @Published var sourceAppName: String = "Music"
    @Published var showMusicPanel: Bool = false

    private let player = MPMusicPlayerController.systemMusicPlayer
    private var timer: Timer?
    private var volumeView: MPVolumeView?

    init() {
        setupNowPlayingObserver()
        updateNowPlaying()
        startPolling()
    }

    private func setupNowPlayingObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingChanged),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackStateChanged),
            name: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: nil
        )
        player.beginGeneratingPlaybackNotifications()
    }

    @objc private func nowPlayingChanged() {
        DispatchQueue.main.async { self.updateNowPlaying() }
    }

    @objc private func playbackStateChanged() {
        DispatchQueue.main.async {
            self.isPlaying = self.player.playbackState == .playing
        }
    }

    func updateNowPlaying() {
        guard let item = player.nowPlayingItem else {
            songTitle = "Not Playing"
            artistName = ""
            albumArtwork = nil
            duration = 0
            currentTime = 0
            return
        }

        songTitle = item.title ?? "Unknown"
        artistName = item.artist ?? "Unknown Artist"
        duration = item.playbackDuration
        currentTime = player.currentPlaybackTime
        isPlaying = player.playbackState == .playing

        if let artwork = item.artwork {
            albumArtwork = artwork.image(at: CGSize(width: 300, height: 300))
        } else {
            albumArtwork = nil
        }
    }

    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.isPlaying {
                    self.currentTime = self.player.currentPlaybackTime
                }
            }
        }
    }

    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    func nextTrack() {
        player.skipToNextItem()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateNowPlaying()
        }
    }

    func previousTrack() {
        if currentTime > 3 {
            player.skipToBeginning()
        } else {
            player.skipToPreviousItem()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateNowPlaying()
        }
    }

    func seekTo(_ time: TimeInterval) {
        player.currentPlaybackTime = time
        currentTime = time
    }

    func setVolume(_ newVolume: Float) {
        volume = newVolume
        MPVolumeView.setVolume(newVolume)
    }

    func cycleLoopMode() {
        switch loopMode {
        case .none:
            loopMode = .all
            player.repeatMode = .all
        case .all:
            loopMode = .one
            player.repeatMode = .one
        case .one:
            loopMode = .none
            player.repeatMode = .none
        }
    }

    func toggleShuffle() {
        isShuffled.toggle()
        player.shuffleMode = isShuffled ? .songs : .off
    }

    func openSourceApp() {
        if let url = URL(string: "music://") {
            UIApplication.shared.open(url)
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            slider?.value = volume
        }
    }
}
