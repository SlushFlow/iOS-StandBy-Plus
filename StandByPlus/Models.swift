import SwiftUI
import UIKit

enum StandByMode: String, CaseIterable, Codable, Identifiable {
    case day
    case night

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var symbol: String { self == .day ? "sun.max.fill" : "moon.stars.fill" }
}

enum ClockStyle: String, CaseIterable, Codable, Identifiable {
    case digital
    case split
    case minimal

    var id: String { rawValue }
    var title: String {
        switch self {
        case .digital: return "Digital"
        case .split: return "Split"
        case .minimal: return "Minimal"
        }
    }
}

enum WidgetSize: String, CaseIterable, Codable, Identifiable {
    case medium
    case huge

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var columns: Int { self == .huge ? 2 : 1 }
}

enum WidgetKind: String, CaseIterable, Codable, Identifiable {
    case weather
    case calendar
    case calls
    case focus
    case notes
    case connectivity
    case reminders
    case music

    var id: String { rawValue }
    var title: String {
        switch self {
        case .weather: return "Weather"
        case .calendar: return "Calendar"
        case .calls: return "Calls"
        case .focus: return "Focus"
        case .notes: return "Notes"
        case .connectivity: return "Connectivity"
        case .reminders: return "Reminders"
        case .music: return "Now Playing"
        }
    }

    var symbol: String {
        switch self {
        case .weather: return "cloud.moon.rain.fill"
        case .calendar: return "calendar"
        case .calls: return "phone.connection.fill"
        case .focus: return "moon.zzz.fill"
        case .notes: return "note.text"
        case .connectivity: return "wifi"
        case .reminders: return "checklist"
        case .music: return "music.note.house.fill"
        }
    }
}

struct WidgetWindow: Identifiable, Codable, Equatable {
    let id: UUID
    var kind: WidgetKind
    var size: WidgetSize

    init(id: UUID = UUID(), kind: WidgetKind, size: WidgetSize) {
        self.id = id
        self.kind = kind
        self.size = size
    }
}

enum CallProvider: String, CaseIterable, Codable, Identifiable {
    case phone
    case whatsapp
    case discord

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .phone: return "Phone"
        case .whatsapp: return "WhatsApp"
        case .discord: return "Discord"
        }
    }

    var symbol: String {
        switch self {
        case .phone: return "phone.fill"
        case .whatsapp: return "message.fill"
        case .discord: return "gamecontroller.fill"
        }
    }

    var accentHex: String {
        switch self {
        case .phone: return "6AA2FF"
        case .whatsapp: return "2AD37F"
        case .discord: return "7289DA"
        }
    }

    var appURL: URL? {
        switch self {
        case .phone: return URL(string: "tel://")
        case .whatsapp: return URL(string: "whatsapp://")
        case .discord: return URL(string: "discord://")
        }
    }
}

enum CallState: String, Codable {
    case incoming
    case connecting
    case active
    case ended

    var title: String {
        switch self {
        case .incoming: return "Incoming"
        case .connecting: return "Connecting"
        case .active: return "Active"
        case .ended: return "Ended"
        }
    }
}

struct CallSession: Identifiable, Codable, Equatable {
    let id: UUID
    var provider: CallProvider
    var contactName: String
    var state: CallState
    var muted: Bool
    var speakerOn: Bool
    var detail: String

    init(
        id: UUID = UUID(),
        provider: CallProvider,
        contactName: String,
        state: CallState,
        muted: Bool = false,
        speakerOn: Bool = false,
        detail: String
    ) {
        self.id = id
        self.provider = provider
        self.contactName = contactName
        self.state = state
        self.muted = muted
        self.speakerOn = speakerOn
        self.detail = detail
    }

    static let samples: [CallSession] = [
        CallSession(provider: .whatsapp, contactName: "Avery Chen", state: .incoming, detail: "Project sync call"),
        CallSession(provider: .phone, contactName: "Jamie Rivera", state: .active, muted: true, speakerOn: false, detail: "18m 24s"),
        CallSession(provider: .discord, contactName: "Design Huddle", state: .connecting, detail: "Joining voice room")
    ]
}

enum RepeatMode: String, CaseIterable, Codable, Identifiable {
    case off
    case all
    case one

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .off: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    var title: String {
        switch self {
        case .off: return "Repeat Off"
        case .all: return "Repeat All"
        case .one: return "Repeat One"
        }
    }
}

struct PlayerState: Codable, Equatable {
    var appName: String
    var appURLString: String
    var trackTitle: String
    var artistName: String
    var albumTitle: String
    var duration: Double
    var progress: Double
    var volume: Double
    var isPlaying: Bool
    var shuffleEnabled: Bool
    var repeatMode: RepeatMode

    var appURL: URL? {
        URL(string: appURLString)
    }

    static let sample = PlayerState(
        appName: "Spotify",
        appURLString: "spotify://",
        trackTitle: "Midnight Signals",
        artistName: "Atlas Avenue",
        albumTitle: "Neon Quiet",
        duration: 248,
        progress: 91,
        volume: 0.72,
        isPlaying: true,
        shuffleEnabled: true,
        repeatMode: .all
    )
}

struct StandByPreferences: Codable, Equatable {
    var activeMode: StandByMode
    var clockStyle: ClockStyle
    var uses24HourTime: Bool
    var showsSeconds: Bool
    var dayBackgroundHex: String
    var daySurfaceHex: String
    var dayAccentHex: String
    var dayTextHex: String
    var nightBackgroundHex: String
    var nightSurfaceHex: String
    var nightAccentHex: String
    var nightTextHex: String
    var widgets: [WidgetWindow]

    static let `default` = StandByPreferences(
        activeMode: .night,
        clockStyle: .split,
        uses24HourTime: false,
        showsSeconds: true,
        dayBackgroundHex: "F4F1EA",
        daySurfaceHex: "FFF9F0",
        dayAccentHex: "7B8CFF",
        dayTextHex: "1D2433",
        nightBackgroundHex: "0D1119",
        nightSurfaceHex: "141B26",
        nightAccentHex: "8AB4FF",
        nightTextHex: "F5F7FB",
        widgets: [
            WidgetWindow(kind: .weather, size: .huge),
            WidgetWindow(kind: .calls, size: .medium),
            WidgetWindow(kind: .calendar, size: .huge),
            WidgetWindow(kind: .focus, size: .medium),
            WidgetWindow(kind: .notes, size: .medium),
            WidgetWindow(kind: .connectivity, size: .medium),
            WidgetWindow(kind: .reminders, size: .huge),
            WidgetWindow(kind: .music, size: .medium)
        ]
    )

    func backgroundColor(for mode: StandByMode) -> Color {
        Color(hex: mode == .day ? dayBackgroundHex : nightBackgroundHex)
    }

    func surfaceColor(for mode: StandByMode) -> Color {
        Color(hex: mode == .day ? daySurfaceHex : nightSurfaceHex)
    }

    func accentColor(for mode: StandByMode) -> Color {
        Color(hex: mode == .day ? dayAccentHex : nightAccentHex)
    }

    func textColor(for mode: StandByMode) -> Color {
        Color(hex: mode == .day ? dayTextHex : nightTextHex)
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let red, green, blue: UInt64
        switch cleaned.count {
        case 3:
            (red, green, blue) = (((int >> 8) & 0xF) * 17, ((int >> 4) & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (red, green, blue) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (red, green, blue) = (17, 17, 17)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1
        )
    }

    func toHexString() -> String {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components else {
            return "000000"
        }

        let resolved: (CGFloat, CGFloat, CGFloat)
        switch components.count {
        case 1:
            resolved = (components[0], components[0], components[0])
        case 2:
            resolved = (components[0], components[0], components[0])
        case 3, 4:
            resolved = (components[0], components[1], components[2])
        default:
            resolved = (0, 0, 0)
        }

        return String(
            format: "%02X%02X%02X",
            Int(resolved.0 * 255),
            Int(resolved.1 * 255),
            Int(resolved.2 * 255)
        )
    }
}
