import SwiftUI

struct ClockPanel: View {
    @EnvironmentObject private var store: StandByStore
    let mode: StandByMode

    var body: some View {
        GlassCard(mode: mode) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(context.date.formatted(.dateTime.weekday(.wide)))
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            Text(context.date.formatted(.dateTime.day().month(.wide).year()))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(foreground.opacity(0.72))
                        }

                        Spacer()

                        Label(store.currentMode.title, systemImage: store.currentMode.symbol)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(accent.opacity(0.18)))
                            .foregroundStyle(accent)
                    }

                    Group {
                        switch store.preferences.clockStyle {
                        case .digital:
                            VStack(alignment: .leading, spacing: 10) {
                                Text(primaryTime(from: context.date))
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .monospacedDigit()
                                    .minimumScaleFactor(0.65)
                                Text(store.preferences.uses24HourTime ? "24-hour clock" : "12-hour clock")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(foreground.opacity(0.72))
                            }
                        case .split:
                            SplitClockView(timeString: primaryTime(from: context.date), foreground: foreground, accent: accent)
                        case .minimal:
                            VStack(alignment: .leading, spacing: 18) {
                                Circle()
                                    .fill(accent.opacity(0.18))
                                    .frame(width: 74, height: 74)
                                    .overlay {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 28, weight: .semibold))
                                            .foregroundStyle(accent)
                                    }
                                Text(primaryTime(from: context.date))
                                    .font(.system(size: 60, weight: .semibold, design: .rounded))
                                    .monospacedDigit()
                                Text("Soft minimal mode with comfortable spacing for a desk across the room.")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(foreground.opacity(0.74))
                            }
                        }
                    }
                    .foregroundStyle(foreground)

                    HStack(spacing: 16) {
                        StatPill(title: store.preferences.showsSeconds ? "Seconds on" : "Seconds off", symbol: "timer", tint: accent)
                        StatPill(title: store.preferences.uses24HourTime ? "24H" : "12H", symbol: "globe", tint: accent)
                    }
                }
            }
        }
    }

    private var foreground: Color {
        store.preferences.textColor(for: mode)
    }

    private var accent: Color {
        store.preferences.accentColor(for: mode)
    }

    private func primaryTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = store.preferences.uses24HourTime
            ? (store.preferences.showsSeconds ? "HH:mm:ss" : "HH:mm")
            : (store.preferences.showsSeconds ? "h:mm:ss a" : "h:mm a")
        return formatter.string(from: date)
    }
}

struct SplitClockView: View {
    let timeString: String
    let foreground: Color
    let accent: Color

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(timeString.enumerated()), id: \.offset) { item in
                let character = item.element

                Text(String(character))
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .frame(minWidth: 34, minHeight: 92)
                    .padding(.horizontal, character == " " ? 0 : 4)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(character == " " ? .clear : foreground.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(character == " " ? .clear : accent.opacity(0.18), lineWidth: 1)
                    )
                    .foregroundStyle(foreground)
            }
        }
    }
}

struct WidgetGrid: View {
    @EnvironmentObject private var store: StandByStore
    let mode: StandByMode

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 18), GridItem(.flexible(), spacing: 18)], spacing: 18) {
            ForEach(store.preferences.widgets) { widget in
                WidgetWindowView(widget: widget, mode: mode)
                    .environmentObject(store)
                    .gridCellColumns(widget.size.columns)
            }
        }
    }
}

struct WidgetWindowView: View {
    @EnvironmentObject private var store: StandByStore
    let widget: WidgetWindow
    let mode: StandByMode

    var body: some View {
        GlassCard(mode: mode) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Circle().fill(.red.opacity(0.75)).frame(width: 8, height: 8)
                        Circle().fill(.yellow.opacity(0.75)).frame(width: 8, height: 8)
                        Circle().fill(.green.opacity(0.75)).frame(width: 8, height: 8)
                    }

                    Label(widget.kind.title, systemImage: widget.kind.symbol)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(store.preferences.textColor(for: mode))

                    Spacer()

                    Text(widget.size.title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(store.preferences.accentColor(for: mode).opacity(0.16)))
                        .foregroundStyle(store.preferences.accentColor(for: mode))
                }

                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        let text = store.preferences.textColor(for: mode)
        let accent = store.preferences.accentColor(for: mode)

        switch widget.kind {
        case .weather:
            VStack(alignment: .leading, spacing: 10) {
                Text("68°")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("Drizzle outside, warm light inside")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(text.opacity(0.72))
                HStack(spacing: 16) {
                    WidgetMetric(title: "Feels", value: "72°")
                    WidgetMetric(title: "Humidity", value: "64%")
                    WidgetMetric(title: "Wind", value: "7 mph")
                }
            }
            .foregroundStyle(text)
        case .calendar:
            VStack(alignment: .leading, spacing: 12) {
                ScheduleRow(time: "09:00", title: "Design crit", subtitle: "Studio A")
                ScheduleRow(time: "11:30", title: "Client review", subtitle: "WhatsApp call")
                ScheduleRow(time: "15:00", title: "Night mode polish", subtitle: "Ship list")
            }
        case .calls:
            VStack(alignment: .leading, spacing: 12) {
                ForEach(store.prioritizedCalls.prefix(3)) { call in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: call.provider.accentHex).opacity(0.22))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: call.provider.symbol)
                                    .foregroundStyle(Color(hex: call.provider.accentHex))
                            }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(call.contactName)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(text)
                            Text("\(call.provider.displayName) • \(call.state.title)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(text.opacity(0.68))
                        }
                        Spacer()
                    }
                }
            }
        case .focus:
            VStack(alignment: .leading, spacing: 14) {
                Text("Deep Focus")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(text)
                Text("Notifications softened, warmth up, distractions down.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(text.opacity(0.72))
                ProgressView(value: 0.68)
                    .tint(accent)
                Text("68 minutes into this session")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(accent)
            }
        case .notes:
            VStack(alignment: .leading, spacing: 10) {
                Text("Pinned Note")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)
                Text("Keep the warm palette muted at night, let incoming calls float above content, and avoid harsh reds unless the user explicitly wants them.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(text)
            }
        case .connectivity:
            HStack(spacing: 14) {
                ConnectivityBubble(symbol: "wifi", title: "Wi-Fi", value: "6E • Strong", tint: accent, text: text)
                ConnectivityBubble(symbol: "battery.75", title: "Battery", value: "74%", tint: accent, text: text)
                ConnectivityBubble(symbol: "airpodspro", title: "Audio", value: "Connected", tint: accent, text: text)
            }
        case .reminders:
            VStack(alignment: .leading, spacing: 12) {
                ReminderRow(title: "Finalize the cozy night palette", done: true, text: text, accent: accent)
                ReminderRow(title: "Check the Discord call overlay", done: false, text: text, accent: accent)
                ReminderRow(title: "Tune the duration slider touch target", done: false, text: text, accent: accent)
            }
        case .music:
            VStack(alignment: .leading, spacing: 8) {
                Text(store.player.trackTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(text)
                Text(store.player.artistName)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(text.opacity(0.72))
                HStack {
                    Label(store.player.appName, systemImage: "waveform")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(accent)
                    Spacer()
                    Image(systemName: store.player.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundStyle(text)
                }
            }
        }
    }
}

struct MusicPanel: View {
    @EnvironmentObject private var store: StandByStore
    @Environment(\.openURL) private var openURL
    let mode: StandByMode

    var body: some View {
        GlassCard(mode: mode) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.95), accent.opacity(0.26), foreground.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 114, height: 114)
                        .overlay {
                            Image(systemName: "music.quarternote.3")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.white.opacity(0.92))
                        }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(store.player.trackTitle)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(foreground)
                            .minimumScaleFactor(0.75)
                        Text("\(store.player.artistName) • \(store.player.albumTitle)")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(foreground.opacity(0.72))
                        Button {
                            if let url = store.player.appURL {
                                openURL(url)
                            }
                        } label: {
                            Label("Open \(store.player.appName)", systemImage: "arrow.up.forward.app.fill")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(accent.opacity(0.18)))
                                .foregroundStyle(accent)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer(minLength: 0)
                }

                VStack(spacing: 10) {
                    Slider(
                        value: Binding(
                            get: { store.player.progress },
                            set: { store.setProgress($0) }
                        ),
                        in: 0...max(store.player.duration, 1)
                    )
                    .tint(accent)

                    HStack {
                        Text(formatTime(store.player.progress))
                        Spacer()
                        Text(formatTime(store.player.duration))
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(foreground.opacity(0.66))
                }

                HStack(spacing: 14) {
                    PlayerButton(symbol: "backward.fill", tint: foreground.opacity(0.95)) { store.previousTrack() }
                    PlayerButton(symbol: store.player.isPlaying ? "pause.fill" : "play.fill", tint: accent, filled: true) { store.togglePlayPause() }
                    PlayerButton(symbol: "forward.fill", tint: foreground.opacity(0.95)) { store.nextTrack() }
                    PlayerButton(symbol: "shuffle", tint: store.player.shuffleEnabled ? accent : foreground.opacity(0.75)) { store.toggleShuffle() }
                    PlayerButton(symbol: store.player.repeatMode.symbol, tint: store.player.repeatMode == .off ? foreground.opacity(0.75) : accent) { store.cycleRepeatMode() }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Volume", systemImage: "speaker.wave.2.fill")
                        Spacer()
                        Text("\(Int(store.player.volume * 100))%")
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(foreground.opacity(0.8))

                    Slider(
                        value: Binding(
                            get: { store.player.volume },
                            set: { store.setVolume($0) }
                        ),
                        in: 0...1
                    )
                    .tint(accent)
                }
            }
        }
    }

    private var foreground: Color {
        store.preferences.textColor(for: mode)
    }

    private var accent: Color {
        store.preferences.accentColor(for: mode)
    }

    private func formatTime(_ seconds: Double) -> String {
        let total = max(Int(seconds.rounded()), 0)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

struct CallHUDView: View {
    @EnvironmentObject private var store: StandByStore
    @Environment(\.openURL) private var openURL
    let session: CallSession
    let mode: StandByMode

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color(hex: session.provider.accentHex).opacity(0.18))
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: session.provider.symbol)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(hex: session.provider.accentHex))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(session.contactName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(store.preferences.textColor(for: mode))
                Text("\(session.provider.displayName) • \(session.state.title) • \(session.detail)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(store.preferences.textColor(for: mode).opacity(0.72))
            }

            Spacer(minLength: 10)

            Group {
                if session.state == .incoming {
                    CallActionButton(symbol: "phone.down.fill", tint: .red) { store.decline(session) }
                    CallActionButton(symbol: "phone.fill", tint: .green) { store.accept(session) }
                } else {
                    CallActionButton(symbol: session.muted ? "mic.slash.fill" : "mic.fill", tint: session.muted ? accent : foreground) { store.toggleMute(session) }
                    CallActionButton(symbol: session.speakerOn ? "speaker.wave.3.fill" : "speaker.slash.fill", tint: session.speakerOn ? accent : foreground) { store.toggleSpeaker(session) }
                    CallActionButton(symbol: "phone.down.fill", tint: .red) { store.hangUp(session) }
                }
            }

            Button {
                if let url = session.provider.appURL {
                    openURL(url)
                }
            } label: {
                Label("Open App", systemImage: "arrow.up.forward.app")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(accent.opacity(0.18)))
                    .foregroundStyle(accent)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: 760)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(store.preferences.surfaceColor(for: mode).opacity(mode == .night ? 0.78 : 0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(accent.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: .black.opacity(mode == .night ? 0.25 : 0.08), radius: 28, y: 18)
    }

    private var foreground: Color {
        store.preferences.textColor(for: mode)
    }

    private var accent: Color {
        store.preferences.accentColor(for: mode)
    }
}

struct CustomizationSheet: View {
    @EnvironmentObject private var store: StandByStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Palette") {
                    ThemeColorRow(title: "Day background", hex: binding(for: \.dayBackgroundHex))
                    ThemeColorRow(title: "Day surface", hex: binding(for: \.daySurfaceHex))
                    ThemeColorRow(title: "Day accent", hex: binding(for: \.dayAccentHex))
                    ThemeColorRow(title: "Day text", hex: binding(for: \.dayTextHex))
                    ThemeColorRow(title: "Night background", hex: binding(for: \.nightBackgroundHex))
                    ThemeColorRow(title: "Night surface", hex: binding(for: \.nightSurfaceHex))
                    ThemeColorRow(title: "Night accent", hex: binding(for: \.nightAccentHex))
                    ThemeColorRow(title: "Night text", hex: binding(for: \.nightTextHex))
                }

                Section("Clock") {
                    Picker("Style", selection: binding(for: \.clockStyle)) {
                        ForEach(ClockStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                    Toggle("Show seconds", isOn: binding(for: \.showsSeconds))
                    Toggle("Use 24-hour time", isOn: binding(for: \.uses24HourTime))
                }

                Section("Widget windows") {
                    ForEach(store.preferences.widgets) { widget in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label(widget.kind.title, systemImage: widget.kind.symbol)
                                Spacer()
                                Text(widget.size.title)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 10) {
                                Button("Up") { store.moveWidget(widget, offset: -1) }
                                Button("Down") { store.moveWidget(widget, offset: 1) }
                                Button(widget.size == .medium ? "Make Huge" : "Make Medium") {
                                    store.toggleWidgetSize(widget)
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Customize")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        store.showingCustomization = false
                    }
                }
            }
        }
    }

    private func binding<Value>(for keyPath: WritableKeyPath<StandByPreferences, Value>) -> Binding<Value> {
        Binding(
            get: { store.preferences[keyPath: keyPath] },
            set: { store.preferences[keyPath: keyPath] = $0 }
        )
    }
}

struct ThemeColorRow: View {
    let title: String
    @Binding var hex: String

    var body: some View {
        HStack {
            ColorPicker(title, selection: Binding(
                get: { Color(hex: hex) },
                set: { hex = $0.toHexString() }
            ), supportsOpacity: false)
            Spacer()
            Text(hex)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

struct GlassCard<Content: View>: View {
    @EnvironmentObject private var store: StandByStore
    let mode: StandByMode
    let content: Content

    init(mode: StandByMode, @ViewBuilder content: () -> Content) {
        self.mode = mode
        self.content = content()
    }

    var body: some View {
        content
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(store.preferences.surfaceColor(for: mode).opacity(mode == .night ? 0.82 : 0.90))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(store.preferences.accentColor(for: mode).opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(mode == .night ? 0.18 : 0.06), radius: 24, y: 12)
    }
}

struct PlayerButton: View {
    let symbol: String
    let tint: Color
    var filled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(filled ? tint.opacity(0.18) : tint.opacity(0.10))
                )
                .overlay(
                    Circle().stroke(tint.opacity(0.18), lineWidth: 1)
                )
                .foregroundStyle(tint)
        }
        .buttonStyle(.plain)
    }
}

struct CallActionButton: View {
    let symbol: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .bold))
                .frame(width: 38, height: 38)
                .background(Circle().fill(tint.opacity(0.18)))
                .foregroundStyle(tint)
        }
        .buttonStyle(.plain)
    }
}

struct StatPill: View {
    let title: String
    let symbol: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Capsule().fill(tint.opacity(0.14)))
            .foregroundStyle(tint)
    }
}

struct WidgetMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
    }
}

struct ScheduleRow: View {
    let time: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(time)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 54, alignment: .leading)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct ConnectivityBubble: View {
    let symbol: String
    let title: String
    let value: String
    let tint: Color
    let text: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(tint)
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(text.opacity(0.7))
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(text)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(tint.opacity(0.10))
        )
    }
}

struct ReminderRow: View {
    let title: String
    let done: Bool
    let text: Color
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? accent : text.opacity(0.45))
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(text)
            Spacer()
        }
    }
}
