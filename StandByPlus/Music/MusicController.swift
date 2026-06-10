import SwiftUI
import MediaPlayer
import Combine

enum RepeatSetting: String, CaseIterable {
    case off
    case all
    case one

    var next: RepeatSetting {
        switch self {
        case .off: return .all
        case .all: return .one
        case .one: return .off
        }
    }

    var symbol: String {
        switch self {
        case .off, .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    var mpMode: MPMusicRepeatMode {
        switch self {
        case .off: return .none
        case .all: return .all
        case .one: return .one
        }
    }
}

enum MusicApp: String, CaseIterable, Identifiable {
    case appleMusic
    case spotify
    case youtubeMusic
    case soundcloud

    var id: String { rawValue }

    var name: String {
        switch self {
        case .appleMusic: return "Apple Music"
        case .spotify: return "Spotify"
        case .youtubeMusic: return "YouTube Music"
        case .soundcloud: return "SoundCloud"
        }
    }

    var urlScheme: String {
        switch self {
        case .appleMusic: return "music://"
        case .spotify: return "spotify://"
        case .youtubeMusic: return "youtubemusic://"
        case .soundcloud: return "soundcloud://"
        }
    }
}

final class MusicController: ObservableObject {
    private let player = MPMusicPlayerController.systemMusicPlayer

    @Published private(set) var authorized: Bool
    @Published private(set) var title: String = "Nothing Playing"
    @Published private(set) var artist: String = ""
    @Published private(set) var albumTitle: String = ""
    @Published private(set) var artwork: UIImage?
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var duration: TimeInterval = 0
    @Published var currentTime: TimeInterval = 0
    @Published private(set) var shuffleOn: Bool = false
    @Published private(set) var repeatSetting: RepeatSetting = .off
    @Published private(set) var hasItem: Bool = false

    @Published var preferredApp: MusicApp.RawValue = UserDefaults.standard.string(forKey: "standbyplus.preferredMusicApp") ?? MusicApp.appleMusic.rawValue {
        didSet {
            UserDefaults.standard.set(preferredApp, forKey: "standbyplus.preferredMusicApp")
        }
    }

    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []

    init() {
        authorized = MPMediaLibrary.authorizationStatus() == .authorized
        player.beginGeneratingPlaybackNotifications()

        let center = NotificationCenter.default
        observers.append(center.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: player, queue: .main
        ) { [weak self] _ in self?.refresh() })
        observers.append(center.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: player, queue: .main
        ) { [weak self] _ in self?.refresh() })

        if authorized {
            refresh()
        }
        startTimer()
    }

    deinit {
        timer?.invalidate()
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        player.endGeneratingPlaybackNotifications()
    }

    func requestAuthorization() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorized = status == .authorized
                if status == .authorized {
                    self?.refresh()
                }
            }
        }
    }

    func refresh() {
        guard authorized else { return }
        let item = player.nowPlayingItem
        hasItem = item != nil
        title = item?.title ?? "Nothing Playing"
        artist = item?.artist ?? ""
        albumTitle = item?.albumTitle ?? ""
        duration = item?.playbackDuration ?? 0
        artwork = item?.artwork?.image(at: CGSize(width: 600, height: 600))
        isPlaying = player.playbackState == .playing
        currentTime = player.currentPlaybackTime.isFinite ? player.currentPlaybackTime : 0
        shuffleOn = player.shuffleMode == .songs || player.shuffleMode == .albums
        switch player.repeatMode {
        case .one: repeatSetting = .one
        case .all: repeatSetting = .all
        default: repeatSetting = .off
        }
    }

    // MARK: - Transport

    func togglePlayPause() {
        guard authorized else { requestAuthorization(); return }
        if player.playbackState == .playing {
            player.pause()
        } else {
            player.play()
        }
        Haptics.tap()
    }

    func next() {
        guard authorized else { requestAuthorization(); return }
        player.skipToNextItem()
        Haptics.tap()
    }

    func previous() {
        guard authorized else { requestAuthorization(); return }
        if player.currentPlaybackTime > 4 {
            player.skipToBeginning()
        } else {
            player.skipToPreviousItem()
        }
        Haptics.tap()
    }

    func seek(to time: TimeInterval) {
        guard authorized else { return }
        player.currentPlaybackTime = max(0, min(time, duration))
        currentTime = player.currentPlaybackTime
    }

    func toggleShuffle() {
        guard authorized else { requestAuthorization(); return }
        player.shuffleMode = shuffleOn ? .off : .songs
        shuffleOn.toggle()
        Haptics.tap()
    }

    func cycleRepeat() {
        guard authorized else { requestAuthorization(); return }
        repeatSetting = repeatSetting.next
        player.repeatMode = repeatSetting.mpMode
        Haptics.tap()
    }

    func openPreferredApp() {
        let app = MusicApp(rawValue: preferredApp) ?? .appleMusic
        if !AppLauncher.open(app.urlScheme) {
            AppLauncher.open(MusicApp.appleMusic.urlScheme)
        }
    }

    func openApp(_ app: MusicApp) {
        AppLauncher.open(app.urlScheme)
    }

    // MARK: - Private

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self, self.authorized, self.isPlaying else { return }
            let time = self.player.currentPlaybackTime
            if time.isFinite {
                self.currentTime = time
            }
        }
    }
}
