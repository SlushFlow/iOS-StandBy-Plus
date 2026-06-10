import SwiftUI
import Combine
import CallKit
import AVFoundation

enum CallSource: String, Codable {
    case phone = "Phone"
    case whatsapp = "WhatsApp"
    case discord = "Discord"
    case facetime = "FaceTime"
    case telegram = "Telegram"
    case unknown = "Unknown"

    var icon: String {
        switch self {
        case .phone: return "phone.fill"
        case .whatsapp: return "message.fill"
        case .discord: return "headphones"
        case .facetime: return "video.fill"
        case .telegram: return "paperplane.fill"
        case .unknown: return "phone.fill"
        }
    }

    var color: Color {
        switch self {
        case .phone: return .green
        case .whatsapp: return Color(hex: "#25D366")
        case .discord: return Color(hex: "#5865F2")
        case .facetime: return .green
        case .telegram: return Color(hex: "#0088CC")
        case .unknown: return .gray
        }
    }

    var appScheme: String? {
        switch self {
        case .whatsapp: return "whatsapp://"
        case .discord: return "discord://"
        case .facetime: return "facetime://"
        case .telegram: return "telegram://"
        default: return nil
        }
    }
}

enum CallState: Equatable {
    case none
    case incoming(caller: String, source: CallSource)
    case active(caller: String, source: CallSource, duration: TimeInterval)
    case onHold(caller: String, source: CallSource)
}

class CallManager: NSObject, ObservableObject {
    @Published var callState: CallState = .none
    @Published var isMuted: Bool = false
    @Published var isSpeakerOn: Bool = false

    private var callObserver: CXCallObserver?
    private var callTimer: Timer?
    private var callStartTime: Date?

    override init() {
        super.init()
        setupCallObserver()
    }

    private func setupCallObserver() {
        callObserver = CXCallObserver()
        callObserver?.setDelegate(self, queue: .main)
    }

    func acceptCall() {
        if case .incoming(let caller, let source) = callState {
            callStartTime = Date()
            callState = .active(caller: caller, source: source, duration: 0)
            startCallTimer()
        }
    }

    func declineCall() {
        endCall()
    }

    func endCall() {
        callTimer?.invalidate()
        callTimer = nil
        callStartTime = nil
        withAnimation(.easeInOut(duration: 0.3)) {
            callState = .none
        }
        isMuted = false
        isSpeakerOn = false
    }

    func toggleMute() {
        isMuted.toggle()
    }

    func toggleSpeaker() {
        isSpeakerOn.toggle()
        let session = AVAudioSession.sharedInstance()
        do {
            if isSpeakerOn {
                try session.overrideOutputAudioPort(.speaker)
            } else {
                try session.overrideOutputAudioPort(.none)
            }
        } catch {
            print("Speaker toggle failed: \(error)")
        }
    }

    func openSourceApp() {
        var source: CallSource?
        switch callState {
        case .incoming(_, let s), .active(_, let s, _), .onHold(_, let s):
            source = s
        case .none:
            break
        }
        guard let scheme = source?.appScheme, let url = URL(string: scheme) else { return }
        UIApplication.shared.open(url)
    }

    private func startCallTimer() {
        callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.callStartTime else { return }
            let duration = Date().timeIntervalSince(start)
            if case .active(let caller, let source, _) = self.callState {
                self.callState = .active(caller: caller, source: source, duration: duration)
            }
        }
    }

    private func identifyCallSource(for handle: String?) -> CallSource {
        guard let handle = handle?.lowercased() else { return .phone }
        if handle.contains("whatsapp") { return .whatsapp }
        if handle.contains("discord") { return .discord }
        if handle.contains("facetime") { return .facetime }
        if handle.contains("telegram") { return .telegram }
        return .phone
    }

    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension CallManager: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if call.hasEnded {
                self.endCall()
            } else if call.isOutgoing && !call.hasConnected {
                let source = self.identifyCallSource(for: nil)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.callState = .active(caller: "Outgoing Call", source: source, duration: 0)
                }
                self.callStartTime = Date()
                self.startCallTimer()
            } else if !call.isOutgoing && !call.hasConnected && !call.hasEnded {
                let source = self.identifyCallSource(for: nil)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.callState = .incoming(caller: "Incoming Call", source: source)
                }
            } else if call.hasConnected {
                if case .incoming(let caller, let source) = self.callState {
                    self.callState = .active(caller: caller, source: source, duration: 0)
                    self.callStartTime = Date()
                    self.startCallTimer()
                }
            } else if call.isOnHold {
                if case .active(let caller, let source, _) = self.callState {
                    self.callState = .onHold(caller: caller, source: source)
                    self.callTimer?.invalidate()
                }
            }
        }
    }
}
