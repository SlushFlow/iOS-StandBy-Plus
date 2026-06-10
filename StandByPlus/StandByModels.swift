import SwiftUI

enum ClockStyle: String, CaseIterable, Identifiable {
    case digital = "Digital"
    case analog = "Analog"
    case minimal = "Minimal"

    var id: String { rawValue }
}

enum WidgetKind: String, CaseIterable, Identifiable {
    case clock = "Clock"
    case music = "Music"
    case weather = "Weather"
    case focus = "Focus"
    case calendar = "Calendar"
    case notes = "Notes"
    case battery = "Battery"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .clock: return "clock"
        case .music: return "music.note"
        case .weather: return "cloud.moon.fill"
        case .focus: return "moon.stars.fill"
        case .calendar: return "calendar"
        case .notes: return "note.text"
        case .battery: return "battery.75"
        }
    }
}

enum WidgetSize: String, CaseIterable, Identifiable {
    case medium = "Medium"
    case huge = "Huge"

    var id: String { rawValue }

    var dimensions: CGSize {
        switch self {
        case .medium:
            return CGSize(width: 260, height: 160)
        case .huge:
            return CGSize(width: 400, height: 300)
        }
    }
}

enum CallProvider: String, CaseIterable, Identifiable {
    case phone = "Phone"
    case whatsapp = "WhatsApp"
    case discord = "Discord"
    case facetime = "FaceTime"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .phone: return "phone.fill"
        case .whatsapp: return "bubble.left.and.bubble.right.fill"
        case .discord: return "gamecontroller.fill"
        case .facetime: return "video.fill"
        }
    }

    var launchURL: URL? {
        switch self {
        case .phone: return URL(string: "tel://")
        case .whatsapp: return URL(string: "whatsapp://")
        case .discord: return URL(string: "discord://")
        case .facetime: return URL(string: "facetime://")
        }
    }
}

enum CallState: String {
    case incoming
    case active
}

enum RepeatMode: String, CaseIterable, Identifiable {
    case off = "Off"
    case all = "All"
    case one = "One"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .off, .all: return "repeat"
        case .one: return "repeat.1"
        }
    }
}

struct StandByWidget: Identifiable, Equatable {
    let id: UUID
    var kind: WidgetKind
    var size: WidgetSize
    var position: CGPoint

    init(id: UUID = UUID(), kind: WidgetKind, size: WidgetSize, position: CGPoint) {
        self.id = id
        self.kind = kind
        self.size = size
        self.position = position
    }
}

struct CallSession {
    var provider: CallProvider
    var contactName: String
    var state: CallState
    var isMuted: Bool
    var isSpeakerEnabled: Bool

    static let preview = CallSession(
        provider: .discord,
        contactName: "Alex",
        state: .incoming,
        isMuted: false,
        isSpeakerEnabled: false
    )
}

struct MusicSession {
    var appName: String
    var title: String
    var artist: String
    var progress: Double
    var duration: Double
    var volume: Double
    var isPlaying: Bool
    var isShuffled: Bool
    var repeatMode: RepeatMode

    static let preview = MusicSession(
        appName: "Music",
        title: "Night Drive",
        artist: "StandBy Plus",
        progress: 88,
        duration: 214,
        volume: 0.42,
        isPlaying: true,
        isShuffled: false,
        repeatMode: .all
    )
}

final class StandByViewModel: ObservableObject {
    @Published var dayPrimary = Color(red: 0.35, green: 0.62, blue: 1.0)
    @Published var daySecondary = Color(red: 0.98, green: 0.84, blue: 0.44)
    @Published var nightPrimary = Color(red: 0.40, green: 0.23, blue: 0.95)
    @Published var nightSecondary = Color(red: 0.02, green: 0.66, blue: 0.77)
    @Published var isNightMode = true
    @Published var clockStyle: ClockStyle = .digital
    @Published var showSeconds = true
    @Published var widgets: [StandByWidget] = [
        StandByWidget(kind: .clock, size: .huge, position: CGPoint(x: 260, y: 230)),
        StandByWidget(kind: .weather, size: .medium, position: CGPoint(x: 600, y: 170)),
        StandByWidget(kind: .focus, size: .medium, position: CGPoint(x: 610, y: 380)),
        StandByWidget(kind: .music, size: .huge, position: CGPoint(x: 330, y: 520))
    ]
    @Published var callSession: CallSession? = .preview
    @Published var musicSession = MusicSession.preview
    @Published var showCustomization = false

    var activeGradient: LinearGradient {
        let colors = isNightMode
            ? [nightPrimary, Color.black, nightSecondary.opacity(0.65)]
            : [dayPrimary, Color.white.opacity(0.92), daySecondary.opacity(0.75)]

        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func moveWidget(_ widget: StandByWidget, to position: CGPoint, in bounds: CGSize) {
        guard let index = widgets.firstIndex(where: { $0.id == widget.id }) else { return }

        let dimensions = widget.size.dimensions
        let clampedX = min(max(position.x, dimensions.width / 2), max(dimensions.width / 2, bounds.width - dimensions.width / 2))
        let clampedY = min(max(position.y, dimensions.height / 2), max(dimensions.height / 2, bounds.height - dimensions.height / 2))

        widgets[index].position = CGPoint(x: clampedX, y: clampedY)
    }

    func toggleSize(for widget: StandByWidget) {
        guard let index = widgets.firstIndex(where: { $0.id == widget.id }) else { return }
        widgets[index].size = widgets[index].size == .medium ? .huge : .medium
    }

    func addWidget(_ kind: WidgetKind) {
        let offset = CGFloat(widgets.count * 24)
        widgets.append(
            StandByWidget(
                kind: kind,
                size: .medium,
                position: CGPoint(x: 240 + offset, y: 220 + offset)
            )
        )
    }

    func acceptCall() {
        guard var session = callSession else { return }
        session.state = .active
        callSession = session
    }

    func declineOrHangUpCall() {
        callSession = nil
    }

    func startDemoCall(provider: CallProvider) {
        callSession = CallSession(
            provider: provider,
            contactName: provider == .phone ? "Mom" : "Jordan",
            state: .incoming,
            isMuted: false,
            isSpeakerEnabled: false
        )
    }

    func toggleMute() {
        guard var session = callSession else { return }
        session.isMuted.toggle()
        callSession = session
    }

    func toggleSpeaker() {
        guard var session = callSession else { return }
        session.isSpeakerEnabled.toggle()
        callSession = session
    }

    func togglePlayPause() {
        musicSession.isPlaying.toggle()
    }

    func cycleRepeatMode() {
        switch musicSession.repeatMode {
        case .off:
            musicSession.repeatMode = .all
        case .all:
            musicSession.repeatMode = .one
        case .one:
            musicSession.repeatMode = .off
        }
    }
}
