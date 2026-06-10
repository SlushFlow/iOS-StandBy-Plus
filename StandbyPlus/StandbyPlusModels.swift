import Foundation
import SwiftUI

enum InterfaceStyle: String, CaseIterable, Identifiable {
    case automatic = "Automatic"
    case dark = "Dark"
    case light = "Light"

    var id: String { rawValue }

    var preferredScheme: ColorScheme? {
        switch self {
        case .automatic:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
}

enum WidgetSize: String, CaseIterable, Identifiable {
    case medium = "Medium"
    case huge = "Huge"

    var id: String { rawValue }
}

enum ClockStyle: String, CaseIterable, Identifiable {
    case digital = "Digital"
    case monospaced = "Monospaced"
    case rounded = "Rounded"

    var id: String { rawValue }
}

enum LoopMode: String, CaseIterable, Identifiable {
    case off = "Off"
    case all = "Loop All"
    case one = "Loop 1"

    var id: String { rawValue }
}

enum CallState: String {
    case active
    case outgoing
    case incoming
}

struct CallSession: Identifiable {
    let id = UUID()
    let callerName: String
    let appName: String
    let appURL: URL?
    var state: CallState
    var isMuted: Bool
    var isSpeakerEnabled: Bool

    var canAcceptOrDecline: Bool {
        state == .incoming
    }
}

struct NowPlayingTrack {
    var title: String
    var artist: String
    var sourceAppName: String
    var sourceAppURL: URL?
    var duration: Double
    var progress: Double
    var volume: Double
    var isPlaying: Bool
    var isShuffleEnabled: Bool
    var loopMode: LoopMode
}

struct WidgetSlot: Identifiable {
    let id = UUID()
    var title: String
    var size: WidgetSize
    var alignment: Alignment
}
