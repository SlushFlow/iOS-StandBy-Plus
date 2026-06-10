import AVFoundation
import CallKit
import UIKit

@MainActor
final class CallService: NSObject, ObservableObject {
    @Published private(set) var activeCall: ActiveCall?
    @Published private(set) var isSpeakerOn = false
    @Published private(set) var isMuted = false

    private let callObserver = CXCallObserver()
    private var trackedCalls: [UUID: ActiveCall] = [:]

    func startObserving() {
        callObserver.setDelegate(self, queue: nil)
        refreshFromObserver()
    }

    func openCallingApp() {
        guard let call = activeCall else { return }
        openApp(for: call.source, handle: call.handle)
    }

    func acceptCall() {
        guard let call = activeCall, call.canAcceptOrDecline else { return }
        openApp(for: call.source, handle: call.handle)
        HapticManager.success()
    }

    func declineCall() {
        guard let call = activeCall, call.canAcceptOrDecline else { return }
        openApp(for: call.source, handle: call.handle)
        HapticManager.warning()
    }

    func hangUp() {
        guard activeCall != nil else { return }
        if let source = activeCall?.source {
            openApp(for: source, handle: activeCall?.handle)
        }
        HapticManager.warning()
    }

    func toggleMute() {
        isMuted.toggle()
        HapticManager.light()
    }

    func toggleSpeaker() {
        isSpeakerOn.toggle()
        configureAudioRoute(speaker: isSpeakerOn)
        HapticManager.light()
    }

    private func refreshFromObserver() {
        let calls = callObserver.calls
        trackedCalls.removeAll()

        for call in calls {
            let source = CallSource.detect(from: call.uuid.uuidString)
            let handle = call.uuid.uuidString
            let detectedSource = CallSource.detect(from: handle)

            var phase: CallPhase = .connecting
            if !call.hasConnected && !call.isOutgoing {
                phase = .incoming
            } else if call.hasConnected {
                phase = call.isOnHold ? .held : .active
            } else if call.isOutgoing {
                phase = .connecting
            }

            let active = ActiveCall(
                id: call.uuid,
                callerName: displayName(for: detectedSource, handle: handle),
                handle: handle,
                source: detectedSource,
                phase: phase,
                isOutgoing: call.isOutgoing,
                isOnHold: call.isOnHold,
                hasConnected: call.hasConnected,
                isMuted: isMuted,
                isSpeakerOn: isSpeakerOn,
                startedAt: call.hasConnected ? Date() : nil
            )
            trackedCalls[call.uuid] = active
        }

        activeCall = trackedCalls.values.first { $0.isActiveSession }
    }

    private func displayName(for source: CallSource, handle: String) -> String {
        switch source {
        case .phone:
            return handle.isEmpty ? "Phone Call" : handle
        default:
            return source.displayName
        }
    }

    private func openApp(for source: CallSource, handle: String?) {
        var urlString: String?

        switch source {
        case .phone:
            if let handle, !handle.isEmpty {
                urlString = "tel://\(handle.filter { $0.isNumber || $0 == "+" })"
            } else {
                urlString = "tel://"
            }
        case .facetime:
            urlString = "facetime://"
        case .whatsapp:
            urlString = "whatsapp://"
        case .discord:
            urlString = "discord://"
        case .telegram:
            urlString = "tg://"
        case .signal:
            urlString = "sgnl://"
        case .skype:
            urlString = "skype://"
        case .zoom:
            urlString = "zoomus://"
        case .unknown:
            urlString = nil
        }

        guard let urlString, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func configureAudioRoute(speaker: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
            try session.overrideOutputAudioPort(speaker ? .speaker : .none)
        } catch {
            // Audio route changes are best-effort for companion HUD controls.
        }
    }
}

extension CallService: CXCallObserverDelegate {
    nonisolated func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        Task { @MainActor in
            refreshFromObserver()
        }
    }
}
