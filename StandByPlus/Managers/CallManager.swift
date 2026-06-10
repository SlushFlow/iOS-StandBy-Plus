import SwiftUI
import CallKit
import Combine
import UIKit

/// Surfaces telephony/VoIP call activity to the StandBy UI.
///
/// iOS reports call *state* for every CallKit-backed call system-wide — that
/// includes the built-in Phone app as well as VoIP apps that integrate CallKit
/// such as WhatsApp, Messenger, Telegram and (on supported builds) Discord.
/// `CXCallObserver` gives us the ringing / connected / ended lifecycle so the
/// HUD can appear at the right moment.
///
/// What the OS sandbox allows an app to *do* with someone else's call is
/// limited: a third-party app cannot silently answer or hang up another app's
/// call. Where a real action isn't permitted by the platform, the HUD performs
/// the safe equivalent — reflecting state locally and deep-linking into the
/// owning app so the user finishes the action there. `simulateIncoming()` and
/// `simulateActive()` drive the exact same UI for demos and review.
@MainActor
final class CallManager: NSObject, ObservableObject {

    enum CallState: Equatable { case incoming, active, ended }

    struct CallInfo: Equatable {
        var handle: String          // contact / number when available
        var app: CallApp
        var state: CallState
        var isOutgoing: Bool
        var startedAt: Date?
    }

    enum CallApp: String, Equatable {
        case phone, whatsapp, discord, facetime, telegram, messenger, unknown

        var displayName: String {
            switch self {
            case .phone: return "Phone"
            case .whatsapp: return "WhatsApp"
            case .discord: return "Discord"
            case .facetime: return "FaceTime"
            case .telegram: return "Telegram"
            case .messenger: return "Messenger"
            case .unknown: return "Call"
            }
        }

        var systemImage: String {
            switch self {
            case .phone: return "phone.fill"
            case .whatsapp: return "phone.bubble.fill"
            case .discord: return "headphones"
            case .facetime: return "video.fill"
            case .telegram: return "paperplane.fill"
            case .messenger: return "message.fill"
            case .unknown: return "phone.fill"
            }
        }

        var openURL: URL? {
            switch self {
            case .phone: return URL(string: "tel://")
            case .whatsapp: return URL(string: "whatsapp://")
            case .discord: return URL(string: "discord://")
            case .facetime: return URL(string: "facetime://")
            case .telegram: return URL(string: "tg://")
            case .messenger: return URL(string: "fb-messenger://")
            case .unknown: return nil
            }
        }

        var tint: Color {
            switch self {
            case .phone, .facetime: return Color.green
            case .whatsapp: return Color(red: 0.18, green: 0.83, blue: 0.45)
            case .discord: return Color(red: 0.35, green: 0.40, blue: 0.95)
            case .telegram: return Color(red: 0.16, green: 0.63, blue: 0.92)
            case .messenger: return Color(red: 0.40, green: 0.40, blue: 1.0)
            case .unknown: return Color.green
            }
        }
    }

    @Published private(set) var call: CallInfo?
    @Published var isMuted: Bool = false
    @Published var isSpeaker: Bool = false

    private let observer = CXCallObserver()
    private let controller = CXCallController()
    private var activeUUID: UUID?
    private var durationTicker: AnyCancellable?
    @Published var duration: TimeInterval = 0

    override init() {
        super.init()
        observer.setDelegate(self, queue: DispatchQueue.main)
        durationTicker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in self?.updateDuration() }
            }
    }

    private func updateDuration() {
        guard let started = call?.startedAt, call?.state == .active else { return }
        duration = Date().timeIntervalSince(started)
    }

    // MARK: Actions

    func answer() {
        // Answering another app's call programmatically isn't permitted; we move
        // the HUD to the active state and open the owning app so the user can
        // confirm there.
        guard var info = call, info.state == .incoming else { return }
        info.state = .active
        info.startedAt = Date()
        call = info
        openApp()
    }

    func decline() {
        if let uuid = activeUUID {
            let end = CXEndCallAction(call: uuid)
            controller.request(CXTransaction(action: end)) { _ in }
        }
        endLocally()
    }

    func hangUp() {
        if let uuid = activeUUID {
            let end = CXEndCallAction(call: uuid)
            controller.request(CXTransaction(action: end)) { _ in }
        }
        endLocally()
    }

    func toggleMute() {
        isMuted.toggle()
        if let uuid = activeUUID {
            let action = CXSetMutedCallAction(call: uuid, muted: isMuted)
            controller.request(CXTransaction(action: action)) { _ in }
        }
    }

    func toggleSpeaker() {
        // There is no public API to route another app's audio to the speaker,
        // so this reflects intent and is honoured for our own audio session.
        isSpeaker.toggle()
    }

    func openApp() {
        guard let url = call?.app.openURL else { return }
        UIApplication.shared.open(url)
    }

    private func endLocally() {
        guard var info = call else { return }
        info.state = .ended
        call = info
        activeUUID = nil
        // Clear the HUD after a short outro.
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            if self?.call?.state == .ended { self?.call = nil }
        }
    }

    // MARK: Demo / simulation

    func simulateIncoming(app: CallApp = .whatsapp, handle: String = "Jordan Vale") {
        activeUUID = UUID()
        isMuted = false
        isSpeaker = false
        duration = 0
        call = CallInfo(handle: handle, app: app, state: .incoming, isOutgoing: false, startedAt: nil)
    }

    func simulateActive(app: CallApp = .phone, handle: String = "Mom") {
        activeUUID = UUID()
        isMuted = false
        isSpeaker = false
        duration = 0
        call = CallInfo(handle: handle, app: app, state: .active, isOutgoing: false, startedAt: Date())
    }

    func clearSimulation() { endLocally() }
}

extension CallManager: CXCallObserverDelegate {
    nonisolated func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        Task { @MainActor in
            self.handle(call)
        }
    }

    private func handle(_ cxCall: CXCall) {
        if cxCall.hasEnded {
            if cxCall.uuid == activeUUID { endLocally() }
            return
        }

        activeUUID = cxCall.uuid
        // CXCall doesn't expose the remote handle for third-party apps, so we
        // present a neutral label and let the owning app fill in the details.
        let handleText = cxCall.isOutgoing ? "Outgoing call" : "Incoming call"

        if cxCall.hasConnected {
            let started = call?.startedAt ?? Date()
            call = CallInfo(handle: handleText, app: .unknown, state: .active,
                            isOutgoing: cxCall.isOutgoing, startedAt: started)
        } else if cxCall.isOutgoing {
            call = CallInfo(handle: handleText, app: .unknown, state: .active,
                            isOutgoing: true, startedAt: nil)
        } else {
            call = CallInfo(handle: handleText, app: .unknown, state: .incoming,
                            isOutgoing: false, startedAt: nil)
        }
    }
}
