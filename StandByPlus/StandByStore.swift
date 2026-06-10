import Foundation
import SwiftUI

final class StandByStore: ObservableObject {
    @Published var preferences: StandByPreferences {
        didSet { savePreferences() }
    }
    @Published var calls: [CallSession]
    @Published var player: PlayerState
    @Published var showingCustomization = false

    private let defaultsKey = "standby-plus.preferences"

    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode(StandByPreferences.self, from: data) {
            preferences = decoded
        } else {
            preferences = .default
        }

        calls = CallSession.samples
        player = .sample
    }

    var currentMode: StandByMode {
        preferences.activeMode
    }

    var prioritizedCalls: [CallSession] {
        calls.filter { $0.state != .ended }
    }

    var primaryCall: CallSession? {
        prioritizedCalls.first
    }

    func setMode(_ mode: StandByMode) {
        preferences.activeMode = mode
    }

    func toggleClockFormat() {
        preferences.uses24HourTime.toggle()
    }

    func tick() {
        guard player.isPlaying else { return }
        player.progress += 1

        if player.progress >= player.duration {
            switch player.repeatMode {
            case .off:
                player.progress = player.duration
                player.isPlaying = false
            case .all, .one:
                player.progress = 0
            }
        }
    }

    func togglePlayPause() {
        player.isPlaying.toggle()
    }

    func nextTrack() {
        player.trackTitle = "Blue Hour Circuit"
        player.artistName = "Northline"
        player.albumTitle = "Quiet Shapes"
        player.duration = 221
        player.progress = 0
        player.isPlaying = true
    }

    func previousTrack() {
        player.trackTitle = "Static and Satin"
        player.artistName = "Luna Harbor"
        player.albumTitle = "Afterglow Desk"
        player.duration = 202
        player.progress = 0
        player.isPlaying = true
    }

    func cycleRepeatMode() {
        switch player.repeatMode {
        case .off: player.repeatMode = .all
        case .all: player.repeatMode = .one
        case .one: player.repeatMode = .off
        }
    }

    func toggleShuffle() {
        player.shuffleEnabled.toggle()
    }

    func setVolume(_ value: Double) {
        player.volume = min(max(value, 0), 1)
    }

    func setProgress(_ value: Double) {
        player.progress = min(max(value, 0), player.duration)
    }

    func accept(_ session: CallSession) {
        updateCall(session.id) { call in
            call.state = .active
            call.detail = "00:00"
        }
    }

    func decline(_ session: CallSession) {
        updateCall(session.id) { call in
            call.state = .ended
            call.detail = "Declined"
        }
    }

    func hangUp(_ session: CallSession) {
        updateCall(session.id) { call in
            call.state = .ended
            call.detail = "Ended"
        }
    }

    func toggleMute(_ session: CallSession) {
        updateCall(session.id) { call in
            call.muted.toggle()
        }
    }

    func toggleSpeaker(_ session: CallSession) {
        updateCall(session.id) { call in
            call.speakerOn.toggle()
        }
    }

    func toggleWidgetSize(_ widget: WidgetWindow) {
        guard let index = preferences.widgets.firstIndex(of: widget) else { return }
        preferences.widgets[index].size = preferences.widgets[index].size == .medium ? .huge : .medium
    }

    func moveWidget(_ widget: WidgetWindow, offset: Int) {
        guard let index = preferences.widgets.firstIndex(of: widget) else { return }
        let destination = max(0, min(index + offset, preferences.widgets.count - 1))
        guard destination != index else { return }
        let moved = preferences.widgets.remove(at: index)
        preferences.widgets.insert(moved, at: destination)
    }

    private func updateCall(_ id: UUID, mutate: (inout CallSession) -> Void) {
        guard let index = calls.firstIndex(where: { $0.id == id }) else { return }
        mutate(&calls[index])
    }

    private func savePreferences() {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}
