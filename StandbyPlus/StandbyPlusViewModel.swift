import Foundation
import SwiftUI

final class StandbyPlusViewModel: ObservableObject {
    @Published var interfaceStyle: InterfaceStyle = .dark
    @Published var dayAccent: Color = Color(red: 0.24, green: 0.51, blue: 0.98)
    @Published var dayBackground: Color = Color(red: 0.92, green: 0.95, blue: 1.0)
    @Published var nightAccent: Color = Color(red: 0.50, green: 0.37, blue: 1.0)
    @Published var nightBackground: Color = Color(red: 0.08, green: 0.10, blue: 0.16)

    @Published var showSeconds: Bool = true
    @Published var use24HourClock: Bool = false
    @Published var clockStyle: ClockStyle = .rounded

    @Published var widgetSlots: [WidgetSlot] = [
        WidgetSlot(title: "Clock", size: .huge, alignment: .topLeading),
        WidgetSlot(title: "Now Playing", size: .medium, alignment: .center),
        WidgetSlot(title: "Quick Calls", size: .medium, alignment: .bottomTrailing)
    ]

    @Published var calls: [CallSession] = [
        CallSession(
            callerName: "Alex Kim",
            appName: "Phone",
            appURL: URL(string: "tel://"),
            state: .active,
            isMuted: false,
            isSpeakerEnabled: true
        ),
        CallSession(
            callerName: "Studio Team",
            appName: "Discord",
            appURL: URL(string: "discord://"),
            state: .incoming,
            isMuted: false,
            isSpeakerEnabled: false
        ),
        CallSession(
            callerName: "Jordan Chen",
            appName: "WhatsApp",
            appURL: URL(string: "whatsapp://"),
            state: .outgoing,
            isMuted: true,
            isSpeakerEnabled: false
        )
    ]

    @Published var nowPlaying = NowPlayingTrack(
        title: "Night Shift",
        artist: "Low Glow",
        sourceAppName: "Spotify",
        sourceAppURL: URL(string: "spotify://"),
        duration: 248,
        progress: 96,
        volume: 0.62,
        isPlaying: true,
        isShuffleEnabled: true,
        loopMode: .all
    )

    var activeAccent: Color {
        interfaceStyle == .light ? dayAccent : nightAccent
    }

    var activeBackground: Color {
        interfaceStyle == .light ? dayBackground : nightBackground
    }

    func updateCall(_ callID: UUID, _ mutate: (inout CallSession) -> Void) {
        guard let index = calls.firstIndex(where: { $0.id == callID }) else { return }
        mutate(&calls[index])
    }

    func endCall(callID: UUID) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.84)) {
            calls.removeAll { $0.id == callID }
        }
    }

    func acceptCall(callID: UUID) {
        updateCall(callID) { call in
            call.state = .active
        }
    }

    func declineCall(callID: UUID) {
        endCall(callID: callID)
    }

    func toggleMute(callID: UUID) {
        updateCall(callID) { call in
            call.isMuted.toggle()
        }
    }

    func toggleSpeaker(callID: UUID) {
        updateCall(callID) { call in
            call.isSpeakerEnabled.toggle()
        }
    }

    func togglePlayPause() {
        withAnimation(.easeInOut(duration: 0.2)) {
            nowPlaying.isPlaying.toggle()
        }
    }

    func skipForward() {
        withAnimation(.easeInOut(duration: 0.2)) {
            nowPlaying.progress = min(nowPlaying.duration, nowPlaying.progress + 12)
        }
    }

    func skipBack() {
        withAnimation(.easeInOut(duration: 0.2)) {
            nowPlaying.progress = max(0, nowPlaying.progress - 12)
        }
    }

    func cycleLoopMode() {
        switch nowPlaying.loopMode {
        case .off:
            nowPlaying.loopMode = .all
        case .all:
            nowPlaying.loopMode = .one
        case .one:
            nowPlaying.loopMode = .off
        }
    }
}
