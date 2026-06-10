import SwiftUI
import CallKit
import AVFAudio
import Combine

struct ObservedCall: Identifiable, Equatable {
    let id: UUID
    var isOutgoing: Bool
    var hasConnected: Bool
    var isOnHold: Bool
    var connectedAt: Date?

    var isRinging: Bool { !isOutgoing && !hasConnected }

    var stateLabel: String {
        if isOnHold { return "On Hold" }
        if hasConnected { return "Ongoing Call" }
        return isOutgoing ? "Calling…" : "Incoming Call"
    }
}

/// Quick-launch entries shown in the call HUD so you can jump into the app
/// the call is coming from (iOS does not tell third-party apps which app owns a call).
struct CallApp: Identifiable, Equatable {
    let id: String
    let name: String
    let symbol: String
    let scheme: String

    static let all: [CallApp] = [
        CallApp(id: "phone", name: "Phone", symbol: "phone.fill", scheme: "tel://"),
        CallApp(id: "facetime", name: "FaceTime", symbol: "video.fill", scheme: "facetime://"),
        CallApp(id: "whatsapp", name: "WhatsApp", symbol: "phone.bubble.fill", scheme: "whatsapp://"),
        CallApp(id: "discord", name: "Discord", symbol: "gamecontroller.fill", scheme: "discord://"),
        CallApp(id: "telegram", name: "Telegram", symbol: "paperplane.fill", scheme: "tg://"),
        CallApp(id: "messenger", name: "Messenger", symbol: "message.fill", scheme: "fb-messenger://")
    ]
}

final class CallMonitor: NSObject, ObservableObject, CXCallObserverDelegate {
    @Published private(set) var calls: [ObservedCall] = []
    @Published var statusMessage: String?
    @Published private(set) var isMuted = false
    @Published private(set) var speakerOn = false

    private let observer = CXCallObserver()
    private let controller = CXCallController()
    private var messageDismissTask: DispatchWorkItem?

    override init() {
        super.init()
        observer.setDelegate(self, queue: .main)
        // Pick up calls that were already active when the app launched.
        for call in observer.calls {
            callObserver(observer, callChanged: call)
        }
    }

    var primaryCall: ObservedCall? {
        calls.first { $0.isRinging } ?? calls.first
    }

    var hasActivity: Bool { !calls.isEmpty }

    // MARK: - CXCallObserverDelegate

    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded {
            calls.removeAll { $0.id == call.uuid }
            if calls.isEmpty {
                isMuted = false
                speakerOn = false
            }
            return
        }

        if let index = calls.firstIndex(where: { $0.id == call.uuid }) {
            calls[index].hasConnected = call.hasConnected
            calls[index].isOnHold = call.isOnHold
            calls[index].isOutgoing = call.isOutgoing
            if call.hasConnected && calls[index].connectedAt == nil {
                calls[index].connectedAt = Date()
            }
        } else {
            calls.append(ObservedCall(
                id: call.uuid,
                isOutgoing: call.isOutgoing,
                hasConnected: call.hasConnected,
                isOnHold: call.isOnHold,
                connectedAt: call.hasConnected ? Date() : nil
            ))
        }
    }

    // MARK: - Actions

    func answer(_ call: ObservedCall) {
        request(CXAnswerCallAction(call: call.id),
                failure: "iOS only lets the source app answer this call — tap its icon below.")
    }

    func decline(_ call: ObservedCall) {
        request(CXEndCallAction(call: call.id),
                failure: "iOS only lets the source app decline this call — tap its icon below.")
    }

    func hangUp(_ call: ObservedCall) {
        request(CXEndCallAction(call: call.id),
                failure: "iOS only lets the source app hang up — tap its icon below.")
    }

    func toggleMute(_ call: ObservedCall) {
        let target = !isMuted
        let action = CXSetMutedCallAction(call: call.id, muted: target)
        controller.request(CXTransaction(action: action)) { [weak self] error in
            DispatchQueue.main.async {
                if error == nil {
                    self?.isMuted = target
                    Haptics.tap()
                } else {
                    self?.show("Mute is controlled by the call's own app on iOS.")
                }
            }
        }
    }

    func toggleSpeaker() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: [.allowBluetooth])
            try session.overrideOutputAudioPort(speakerOn ? .none : .speaker)
            speakerOn.toggle()
            Haptics.tap()
        } catch {
            show("Speaker is controlled by the call's own app on iOS.")
        }
    }

    func openApp(_ app: CallApp) {
        if !AppLauncher.open(app.scheme) {
            show("\(app.name) is not installed.")
        }
    }

    // MARK: - Private

    private func request(_ action: CXCallAction, failure: String) {
        controller.request(CXTransaction(action: action)) { [weak self] error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.show(failure)
                } else {
                    Haptics.success()
                }
            }
        }
    }

    private func show(_ message: String) {
        Haptics.warning()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            statusMessage = message
        }
        messageDismissTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) {
                self?.statusMessage = nil
            }
        }
        messageDismissTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: task)
    }
}
