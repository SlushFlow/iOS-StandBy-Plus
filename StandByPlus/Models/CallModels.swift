import Foundation

enum CallSource: String, CaseIterable, Identifiable {
    case phone
    case facetime
    case whatsapp
    case discord
    case telegram
    case signal
    case skype
    case zoom
    case unknown

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .phone: return "Phone"
        case .facetime: return "FaceTime"
        case .whatsapp: return "WhatsApp"
        case .discord: return "Discord"
        case .telegram: return "Telegram"
        case .signal: return "Signal"
        case .skype: return "Skype"
        case .zoom: return "Zoom"
        case .unknown: return "Call"
        }
    }

    var systemImage: String {
        switch self {
        case .phone: return "phone.fill"
        case .facetime: return "video.fill"
        case .whatsapp: return "message.fill"
        case .discord: return "bubble.left.and.bubble.right.fill"
        case .telegram: return "paperplane.fill"
        case .signal: return "lock.shield.fill"
        case .skype: return "phone.connection.fill"
        case .zoom: return "video.badge.waveform.fill"
        case .unknown: return "phone.and.waveform.fill"
        }
    }

    var urlScheme: String? {
        switch self {
        case .phone: return "tel"
        case .facetime: return "facetime"
        case .whatsapp: return "whatsapp"
        case .discord: return "discord"
        case .telegram: return "tg"
        case .signal: return "sgnl"
        case .skype: return "skype"
        case .zoom: return "zoomus"
        case .unknown: return nil
        }
    }

    static func detect(from handle: String?) -> CallSource {
        guard let handle = handle?.lowercased() else { return .unknown }

        if handle.contains("whatsapp") { return .whatsapp }
        if handle.contains("discord") { return .discord }
        if handle.contains("facetime") || handle.contains("ft-") { return .facetime }
        if handle.contains("telegram") || handle.contains("tg") { return .telegram }
        if handle.contains("signal") { return .signal }
        if handle.contains("skype") { return .skype }
        if handle.contains("zoom") { return .zoom }

        let phonePattern = #"^[\d\s\+\-\(\)]+$"#
        if handle.range(of: phonePattern, options: .regularExpression) != nil {
            return .phone
        }

        return .unknown
    }
}

enum CallPhase: Equatable {
    case idle
    case incoming
    case connecting
    case active
    case held
    case ended
}

struct ActiveCall: Identifiable, Equatable {
    let id: UUID
    var callerName: String
    var handle: String?
    var source: CallSource
    var phase: CallPhase
    var isOutgoing: Bool
    var isOnHold: Bool
    var hasConnected: Bool
    var isMuted: Bool
    var isSpeakerOn: Bool
    var startedAt: Date?

    var statusText: String {
        switch phase {
        case .idle: return "No active call"
        case .incoming: return "Incoming call"
        case .connecting: return isOutgoing ? "Calling…" : "Connecting…"
        case .active: return isOnHold ? "On hold" : "In call"
        case .held: return "On hold"
        case .ended: return "Call ended"
        }
    }

    var canAcceptOrDecline: Bool {
        phase == .incoming && !isOutgoing
    }

    var isActiveSession: Bool {
        switch phase {
        case .incoming, .connecting, .active, .held:
            return true
        case .idle, .ended:
            return false
        }
    }
}
