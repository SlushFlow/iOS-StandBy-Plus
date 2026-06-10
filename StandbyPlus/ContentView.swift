import SwiftUI

struct ContentView: View {
    enum Panel: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case customize = "Customize"
        case calls = "Calls"
        case music = "Music"

        var id: String { rawValue }
    }

    @EnvironmentObject private var viewModel: StandbyPlusViewModel
    @Environment(\.openURL) private var openURL
    @State private var selectedPanel: Panel = .dashboard

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    viewModel.activeBackground,
                    viewModel.activeBackground.opacity(0.85),
                    viewModel.activeAccent.opacity(0.52)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                headerCard
                panelPicker

                Group {
                    switch selectedPanel {
                    case .dashboard:
                        dashboardPanel
                    case .customize:
                        customizationPanel
                    case .calls:
                        callsPanel
                    case .music:
                        musicPanel
                    }
                }
                .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .trailing)), removal: .opacity))
                .id(selectedPanel)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
    }

    private var headerCard: some View {
        FrostedCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("StandBy Plus")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline) {
                    clockView
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Workspace Mode")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Picker("Style", selection: $viewModel.interfaceStyle) {
                            ForEach(InterfaceStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 245)
                    }
                }
            }
        }
    }

    private var clockView: some View {
        TimelineView(.periodic(from: .now, by: viewModel.showSeconds ? 1 : 60)) { context in
            let date = context.date
            let formatter = DateFormatter()
            formatter.locale = .current
            formatter.dateFormat = viewModel.use24HourClock ? (viewModel.showSeconds ? "HH:mm:ss" : "HH:mm") : (viewModel.showSeconds ? "h:mm:ss a" : "h:mm a")

            Text(formatter.string(from: date))
                .font(clockFont)
                .foregroundStyle(viewModel.activeAccent)
                .contentTransition(.numericText())
        }
    }

    private var clockFont: Font {
        switch viewModel.clockStyle {
        case .digital:
            return .system(size: 46, weight: .medium, design: .serif)
        case .monospaced:
            return .system(size: 46, weight: .semibold, design: .monospaced)
        case .rounded:
            return .system(size: 46, weight: .semibold, design: .rounded)
        }
    }

    private var panelPicker: some View {
        HStack(spacing: 10) {
            ForEach(Panel.allCases) { panel in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                        selectedPanel = panel
                    }
                } label: {
                    Text(panel.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selectedPanel == panel ? Color.white : Color.primary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedPanel == panel ? viewModel.activeAccent : Color.primary.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var dashboardPanel: some View {
        ScrollView {
            VStack(spacing: 14) {
                FrostedCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Widget Windows")
                            .font(.headline)
                        Text("Drag-and-drop behavior can be added with persistence; this preview captures medium/huge layouts and window-like placement.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        widgetWindowPreview
                    }
                }

                FrostedCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Incoming & Active Calls")
                            .font(.headline)
                        ForEach(viewModel.calls.prefix(2)) { call in
                            callRow(call)
                        }
                    }
                }

                FrostedCard {
                    compactNowPlaying
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var widgetWindowPreview: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.widgetSlots) { slot in
                HStack {
                    Text(slot.title)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(slot.size.rawValue)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(viewModel.activeAccent.opacity(0.18)))
                }
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: slot.size == .huge ? 98 : 68, alignment: slot.alignment)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.primary.opacity(0.07))
                )
            }
        }
    }

    private var customizationPanel: some View {
        ScrollView {
            VStack(spacing: 14) {
                FrostedCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Day Colors")
                            .font(.headline)
                        ColorPicker("Day Accent", selection: $viewModel.dayAccent, supportsOpacity: true)
                        ColorPicker("Day Background", selection: $viewModel.dayBackground, supportsOpacity: true)
                    }
                }

                FrostedCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Night Colors")
                            .font(.headline)
                        ColorPicker("Night Accent", selection: $viewModel.nightAccent, supportsOpacity: true)
                        ColorPicker("Night Background", selection: $viewModel.nightBackground, supportsOpacity: true)
                    }
                }

                FrostedCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Clock Options")
                            .font(.headline)
                        Picker("Clock Style", selection: $viewModel.clockStyle) {
                            ForEach(ClockStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)

                        Toggle("Show Seconds", isOn: $viewModel.showSeconds)
                        Toggle("24-Hour Clock", isOn: $viewModel.use24HourClock)
                    }
                }

                FrostedCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Widget Windows")
                            .font(.headline)
                        ForEach(Array(viewModel.widgetSlots.enumerated()), id: \.element.id) { index, slot in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(slot.title)
                                    .font(.subheadline.weight(.medium))
                                Picker("Size", selection: Binding(
                                    get: { viewModel.widgetSlots[index].size },
                                    set: { viewModel.widgetSlots[index].size = $0 }
                                )) {
                                    ForEach(WidgetSize.allCases) { size in
                                        Text(size.rawValue).tag(size)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var callsPanel: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.calls) { call in
                    FrostedCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(viewModel.activeAccent.opacity(0.24))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Text(String(call.appName.prefix(1)))
                                            .font(.headline)
                                    )
                                VStack(alignment: .leading) {
                                    Text(call.callerName)
                                        .font(.headline)
                                    Text("\(call.appName) • \(call.state.rawValue.capitalized)")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button("Open App") {
                                    if let appURL = call.appURL {
                                        openURL(appURL)
                                    }
                                }
                            }

                            HStack(spacing: 10) {
                                ActionButton(title: call.isMuted ? "Unmute" : "Mute", icon: "mic.fill") {
                                    viewModel.toggleMute(callID: call.id)
                                }
                                ActionButton(title: call.isSpeakerEnabled ? "Speaker Off" : "Speaker", icon: "speaker.wave.2.fill") {
                                    viewModel.toggleSpeaker(callID: call.id)
                                }
                                ActionButton(title: "Hang Up", icon: "phone.down.fill", role: .destructive) {
                                    viewModel.endCall(callID: call.id)
                                }
                            }

                            if call.canAcceptOrDecline {
                                HStack(spacing: 10) {
                                    ActionButton(title: "Accept", icon: "phone.fill", role: .confirm) {
                                        viewModel.acceptCall(callID: call.id)
                                    }
                                    ActionButton(title: "Decline", icon: "phone.down.fill", role: .destructive) {
                                        viewModel.declineCall(callID: call.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var musicPanel: some View {
        FrostedCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Now Playing")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.nowPlaying.title)
                        .font(.title3.weight(.semibold))
                    Text("\(viewModel.nowPlaying.artist) • \(viewModel.nowPlaying.sourceAppName)")
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    ActionButton(title: "Open App", icon: "arrow.up.forward.app.fill") {
                        if let appURL = viewModel.nowPlaying.sourceAppURL {
                            openURL(appURL)
                        }
                    }
                    ActionButton(title: viewModel.nowPlaying.loopMode.rawValue, icon: "repeat") {
                        viewModel.cycleLoopMode()
                    }
                    ActionButton(title: viewModel.nowPlaying.isShuffleEnabled ? "Shuffle On" : "Shuffle", icon: "shuffle") {
                        viewModel.nowPlaying.isShuffleEnabled.toggle()
                    }
                }

                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { viewModel.nowPlaying.progress },
                            set: { viewModel.nowPlaying.progress = $0 }
                        ),
                        in: 0...max(viewModel.nowPlaying.duration, 1)
                    )

                    HStack {
                        Text(timeString(viewModel.nowPlaying.progress))
                        Spacer()
                        Text(timeString(viewModel.nowPlaying.duration))
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Volume")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Slider(
                        value: Binding(
                            get: { viewModel.nowPlaying.volume },
                            set: { viewModel.nowPlaying.volume = $0 }
                        ),
                        in: 0...1
                    )
                }

                HStack(spacing: 10) {
                    ActionButton(title: "Previous", icon: "backward.fill") {
                        viewModel.skipBack()
                    }
                    ActionButton(title: viewModel.nowPlaying.isPlaying ? "Pause" : "Play", icon: viewModel.nowPlaying.isPlaying ? "pause.fill" : "play.fill") {
                        viewModel.togglePlayPause()
                    }
                    ActionButton(title: "Next", icon: "forward.fill") {
                        viewModel.skipForward()
                    }
                }
            }
        }
    }

    private var compactNowPlaying: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Music")
                .font(.headline)
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.nowPlaying.title)
                        .font(.subheadline.weight(.semibold))
                    Text(viewModel.nowPlaying.artist)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: viewModel.nowPlaying.isPlaying ? "pause.fill" : "play.fill")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.07))
            )
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let time = Int(seconds)
        let minutes = time / 60
        let remainder = time % 60
        return String(format: "%d:%02d", minutes, remainder)
    }

    private func callRow(_ call: CallSession) -> some View {
        HStack {
            Text(call.callerName)
                .font(.subheadline.weight(.medium))
            Spacer()
            Text(call.state.rawValue.capitalized)
                .font(.caption.weight(.semibold))
                .foregroundStyle(viewModel.activeAccent)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
    }
}

private struct FrostedCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct ActionButton: View {
    enum Role {
        case normal
        case destructive
        case confirm
    }

    var title: String
    var icon: String
    var role: Role = .normal
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(tintColor)
    }

    private var tintColor: Color {
        switch role {
        case .normal:
            return .accentColor
        case .destructive:
            return .red
        case .confirm:
            return .green
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StandbyPlusViewModel())
}
