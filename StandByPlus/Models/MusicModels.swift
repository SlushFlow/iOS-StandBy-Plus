import Foundation

enum RepeatMode: String, CaseIterable, Identifiable {
    case off
    case all
    case one

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .off: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    var label: String {
        switch self {
        case .off: return "Off"
        case .all: return "Loop All"
        case .one: return "Loop One"
        }
    }
}

enum MusicSource: String, CaseIterable, Identifiable {
    case appleMusic
    case spotify
    case unknown

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .appleMusic: return "Apple Music"
        case .spotify: return "Spotify"
        case .unknown: return "Now Playing"
        }
    }

    var systemImage: String {
        switch self {
        case .appleMusic: return "music.note"
        case .spotify: return "music.quarternote.3"
        case .unknown: return "play.circle.fill"
        }
    }

    var urlScheme: String? {
        switch self {
        case .appleMusic: return "music"
        case .spotify: return "spotify"
        case .unknown: return nil
        }
    }

    static func detect(from bundleID: String?) -> MusicSource {
        guard let bundleID = bundleID?.lowercased() else { return .unknown }
        if bundleID.contains("spotify") { return .spotify }
        if bundleID.contains("music") || bundleID.contains("apple") { return .appleMusic }
        return .unknown
    }
}

struct NowPlayingTrack: Equatable {
    var title: String
    var artist: String
    var album: String
    var artworkData: Data?
    var duration: TimeInterval
    var elapsed: TimeInterval
    var isPlaying: Bool
    var shuffleEnabled: Bool
    var repeatMode: RepeatMode
    var source: MusicSource
    var bundleIdentifier: String?

    static let empty = NowPlayingTrack(
        title: "Nothing playing",
        artist: "Open a music app to begin",
        album: "",
        artworkData: nil,
        duration: 0,
        elapsed: 0,
        isPlaying: false,
        shuffleEnabled: false,
        repeatMode: .off,
        source: .unknown,
        bundleIdentifier: nil
    )

    var hasContent: Bool {
        title != Self.empty.title && duration > 0 || isPlaying
    }
}
