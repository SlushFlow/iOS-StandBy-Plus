import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: StandByViewModel
    @Environment(\.openURL) private var openURL
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            viewModel.activeGradient
                .ignoresSafeArea()

            GeometryReader { proxy in
                ZStack {
                    ForEach(viewModel.widgets) { widget in
                        StandByWidgetCard(widget: widget, now: now)
                            .frame(
                                width: widget.size.dimensions.width,
                                height: widget.size.dimensions.height
                            )
                            .position(widget.position)
                            .gesture(
                                DragGesture(coordinateSpace: .named("standby-canvas"))
                                    .onChanged { value in
                                        viewModel.moveWidget(widget, to: value.location, in: proxy.size)
                                    }
                            )
                            .onTapGesture(count: 2) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                    viewModel.toggleSize(for: widget)
                                }
                            }
                    }
                }
                .coordinateSpace(name: "standby-canvas")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            VStack(spacing: 18) {
                HeaderBar()
                Spacer()
                if viewModel.callSession != nil {
                    CallHUD(openURL: openURL)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                MusicControlPanel(openURL: openURL)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
        }
        .preferredColorScheme(viewModel.isNightMode ? .dark : .light)
        .sheet(isPresented: $viewModel.showCustomization) {
            CustomizationView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onReceive(timer) { value in
            now = value
        }
    }
}

private struct HeaderBar: View {
    @EnvironmentObject private var viewModel: StandByViewModel

    var body: some View {
        HStack(spacing: 14) {
            Label("StandBy Plus", systemImage: "sparkles")
                .font(.headline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .glassCapsule()

            Spacer()

            Toggle(isOn: $viewModel.isNightMode) {
                Label(viewModel.isNightMode ? "Night" : "Day", systemImage: viewModel.isNightMode ? "moon.fill" : "sun.max.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .toggleStyle(.button)
            .tint(viewModel.isNightMode ? viewModel.nightSecondary : viewModel.dayPrimary)
            .glassCapsule()

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    viewModel.showCustomization = true
                }
            } label: {
                Label("Customize", systemImage: "slider.horizontal.3")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .glassCapsule()
        }
    }
}

private struct StandByWidgetCard: View {
    @EnvironmentObject private var viewModel: StandByViewModel

    let widget: StandByWidget
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(widget.kind.rawValue, systemImage: widget.kind.symbolName)
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: widget.size == .huge ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            switch widget.kind {
            case .clock:
                ClockWidget(now: now, isLarge: widget.size == .huge)
            case .music:
                MiniMusicWidget(isLarge: widget.size == .huge)
            case .weather:
                WeatherWidget(isLarge: widget.size == .huge)
            case .focus:
                FocusWidget(isLarge: widget.size == .huge)
            case .calendar:
                CalendarWidget(isLarge: widget.size == .huge)
            case .notes:
                NotesWidget(isLarge: widget.size == .huge)
            case .battery:
                BatteryWidget(isLarge: widget.size == .huge)
            }

            Spacer(minLength: 0)
        }
        .padding(widget.size == .huge ? 24 : 18)
        .glassCard(cornerRadius: 34)
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "hand.draw.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(14)
        }
        .accessibilityHint("Drag to move. Double tap to resize.")
    }
}

private struct ClockWidget: View {
    @EnvironmentObject private var viewModel: StandByViewModel

    let now: Date
    let isLarge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch viewModel.clockStyle {
            case .digital:
                Group {
                    if viewModel.showSeconds {
                        Text(now, format: .dateTime.hour().minute().second())
                    } else {
                        Text(now, format: .dateTime.hour().minute())
                    }
                }
                .font(.system(size: isLarge ? 82 : 42, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
            case .analog:
                AnalogClock(now: now)
                    .frame(width: isLarge ? 170 : 94, height: isLarge ? 170 : 94)
            case .minimal:
                Text(now, format: .dateTime.hour().minute())
                    .font(.system(size: isLarge ? 96 : 48, weight: .thin, design: .serif))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
            }

            Text(now, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(isLarge ? .title3.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

private struct AnalogClock: View {
    let now: Date

    private var components: DateComponents {
        Calendar.current.dateComponents([.hour, .minute, .second], from: now)
    }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.18), lineWidth: 2)
                .background(Circle().fill(.white.opacity(0.05)))

            ForEach(0..<12) { tick in
                Capsule()
                    .fill(.white.opacity(tick % 3 == 0 ? 0.8 : 0.35))
                    .frame(width: 3, height: tick % 3 == 0 ? 13 : 7)
                    .offset(y: -72)
                    .rotationEffect(.degrees(Double(tick) * 30))
            }

            hand(length: 48, width: 7, degrees: hourDegrees, opacity: 0.92)
            hand(length: 66, width: 5, degrees: minuteDegrees, opacity: 0.82)
            hand(length: 70, width: 2, degrees: secondDegrees, opacity: 0.72)

            Circle()
                .fill(.white)
                .frame(width: 10, height: 10)
        }
    }

    private var hourDegrees: Double {
        let hour = Double(components.hour ?? 0).truncatingRemainder(dividingBy: 12)
        let minute = Double(components.minute ?? 0)
        return (hour * 30) + (minute * 0.5)
    }

    private var minuteDegrees: Double {
        Double(components.minute ?? 0) * 6
    }

    private var secondDegrees: Double {
        Double(components.second ?? 0) * 6
    }

    private func hand(length: CGFloat, width: CGFloat, degrees: Double, opacity: Double) -> some View {
        Capsule()
            .fill(.white.opacity(opacity))
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(degrees))
    }
}

private struct MiniMusicWidget: View {
    @EnvironmentObject private var viewModel: StandByViewModel

    let isLarge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.24), .white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Image(systemName: "music.note")
                        .font(.system(size: isLarge ? 58 : 34, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(height: isLarge ? 130 : 58)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.musicSession.title)
                    .font(isLarge ? .title.bold() : .headline.bold())
                Text(viewModel.musicSession.artist)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

private struct WeatherWidget: View {
    let isLarge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("68")
                    .font(.system(size: isLarge ? 72 : 42, weight: .heavy, design: .rounded))
                Text("deg")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            Text("Cloudy, calm, desk-lamp weather")
                .font(isLarge ? .title3.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            if isLarge {
                HStack {
                    Label("Low 61", systemImage: "thermometer.low")
                    Label("No rain", systemImage: "drop")
                    Label("Quiet", systemImage: "wind")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            }
        }
    }
}

private struct FocusWidget: View {
    let isLarge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deep Work")
                .font(isLarge ? .largeTitle.bold() : .title2.bold())
            Text("Notifications dimmed, cozy mode on.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            ProgressView(value: 0.68)
                .tint(.white)
            if isLarge {
                Text("Next break in 18 minutes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct CalendarWidget: View {
    let isLarge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Up Next")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Design Review")
                .font(isLarge ? .largeTitle.bold() : .title2.bold())
            Label("10:30 - 11:00", systemImage: "clock")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

private struct NotesWidget: View {
    let isLarge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Desk Notes")
                .font(isLarge ? .title.bold() : .headline.bold())
            Text("Double tap any card to switch between medium and huge. Drag cards anywhere like desktop windows.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(isLarge ? 5 : 3)
        }
    }
}

private struct BatteryWidget: View {
    let isLarge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Charging")
                .font(isLarge ? .largeTitle.bold() : .title2.bold())
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                ProgressView(value: 0.76)
                    .tint(.green)
            }
            Text("iPhone 76%")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

private struct CallHUD: View {
    @EnvironmentObject private var viewModel: StandByViewModel
    let openURL: OpenURLAction

    var body: some View {
        if let call = viewModel.callSession {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.13))
                    Image(systemName: call.provider.symbolName)
                        .font(.system(size: 26, weight: .bold))
                }
                .frame(width: 62, height: 62)

                VStack(alignment: .leading, spacing: 4) {
                    Text(call.state == .incoming ? "Incoming \(call.provider.rawValue) call" : "\(call.provider.rawValue) call")
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                    Text(call.contactName)
                        .font(.title3.weight(.bold))
                }

                Spacer()

                Button {
                    if let url = call.provider.launchURL {
                        openURL(url)
                    }
                } label: {
                    Label("Open App", systemImage: "arrow.up.forward.app")
                }
                .controlButtonStyle()

                if call.state == .incoming {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.declineOrHangUpCall()
                        }
                    } label: {
                        Label("Decline", systemImage: "phone.down.fill")
                    }
                    .controlButtonStyle(tint: .red)

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.acceptCall()
                        }
                    } label: {
                        Label("Accept", systemImage: "phone.fill")
                    }
                    .controlButtonStyle(tint: .green)
                } else {
                    Button {
                        viewModel.toggleSpeaker()
                    } label: {
                        Label(call.isSpeakerEnabled ? "Speaker On" : "Speaker", systemImage: "speaker.wave.2.fill")
                    }
                    .controlButtonStyle(tint: call.isSpeakerEnabled ? .blue : nil)

                    Button {
                        viewModel.toggleMute()
                    } label: {
                        Label(call.isMuted ? "Muted" : "Mute", systemImage: call.isMuted ? "mic.slash.fill" : "mic.fill")
                    }
                    .controlButtonStyle(tint: call.isMuted ? .orange : nil)

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.declineOrHangUpCall()
                        }
                    } label: {
                        Label("Hang Up", systemImage: "phone.down.fill")
                    }
                    .controlButtonStyle(tint: .red)
                }
            }
            .padding(18)
            .glassCard(cornerRadius: 32)
        }
    }
}

private struct MusicControlPanel: View {
    @EnvironmentObject private var viewModel: StandByViewModel
    let openURL: OpenURLAction

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.85), .cyan.opacity(0.62)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image(systemName: "waveform")
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundStyle(.white.opacity(0.86))
                    }
                    .frame(width: 78, height: 78)

                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.musicSession.title)
                        .font(.title3.weight(.bold))
                    Text("\(viewModel.musicSession.artist) - \(viewModel.musicSession.appName)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    openURL(URL(string: "music://")!)
                } label: {
                    Label("Open", systemImage: "arrow.up.forward.app")
                }
                .controlButtonStyle()

                Button {
                    viewModel.musicSession.isShuffled.toggle()
                } label: {
                    Image(systemName: "shuffle")
                }
                .controlButtonStyle(tint: viewModel.musicSession.isShuffled ? .blue : nil)

                Button {
                    viewModel.cycleRepeatMode()
                } label: {
                    Label(viewModel.musicSession.repeatMode.rawValue, systemImage: viewModel.musicSession.repeatMode.symbolName)
                }
                .controlButtonStyle(tint: viewModel.musicSession.repeatMode == .off ? nil : .blue)
            }

            VStack(spacing: 8) {
                Slider(value: $viewModel.musicSession.progress, in: 0...viewModel.musicSession.duration)
                    .tint(.white)
                HStack {
                    Text(Self.timeString(viewModel.musicSession.progress))
                    Spacer()
                    Text(Self.timeString(viewModel.musicSession.duration))
                }
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Button {
                    viewModel.musicSession.progress = max(0, viewModel.musicSession.progress - 12)
                } label: {
                    Image(systemName: "backward.fill")
                }
                .transportButtonStyle()

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.78)) {
                        viewModel.togglePlayPause()
                    }
                } label: {
                    Image(systemName: viewModel.musicSession.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 26, weight: .bold))
                        .frame(width: 64, height: 64)
                        .background(.white.opacity(0.18), in: Circle())
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.musicSession.progress = min(viewModel.musicSession.duration, viewModel.musicSession.progress + 12)
                } label: {
                    Image(systemName: "forward.fill")
                }
                .transportButtonStyle()

                Spacer()

                Image(systemName: "speaker.fill")
                    .foregroundStyle(.secondary)
                Slider(value: $viewModel.musicSession.volume, in: 0...1)
                    .frame(maxWidth: 220)
                    .tint(.white)
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 34)
    }

    private static func timeString(_ seconds: Double) -> String {
        let clampedSeconds = max(0, Int(seconds))
        return String(format: "%d:%02d", clampedSeconds / 60, clampedSeconds % 60)
    }
}

private struct CustomizationView: View {
    @EnvironmentObject private var viewModel: StandByViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    customizationSection("Color palettes") {
                        VStack(spacing: 14) {
                            ColorPicker("Day primary", selection: $viewModel.dayPrimary)
                            ColorPicker("Day accent", selection: $viewModel.daySecondary)
                            Divider()
                            ColorPicker("Night primary", selection: $viewModel.nightPrimary)
                            ColorPicker("Night accent", selection: $viewModel.nightSecondary)
                        }
                    }

                    customizationSection("Clock") {
                        VStack(alignment: .leading, spacing: 14) {
                            Picker("Clock style", selection: $viewModel.clockStyle) {
                                ForEach(ClockStyle.allCases) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                            .pickerStyle(.segmented)

                            Toggle("Show seconds", isOn: $viewModel.showSeconds)
                        }
                    }

                    customizationSection("Widget windows") {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Drag cards anywhere on the standby canvas. Double tap a card to flip between medium and huge.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            ForEach($viewModel.widgets) { $widget in
                                HStack(spacing: 12) {
                                    Picker("Kind", selection: $widget.kind) {
                                        ForEach(WidgetKind.allCases) { kind in
                                            Text(kind.rawValue).tag(kind)
                                        }
                                    }
                                    .labelsHidden()

                                    Picker("Size", selection: $widget.size) {
                                        ForEach(WidgetSize.allCases) { size in
                                            Text(size.rawValue).tag(size)
                                        }
                                    }
                                    .labelsHidden()
                                }
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(WidgetKind.allCases) { kind in
                                        Button {
                                            viewModel.addWidget(kind)
                                        } label: {
                                            Label(kind.rawValue, systemImage: kind.symbolName)
                                        }
                                        .controlButtonStyle()
                                    }
                                }
                            }
                        }
                    }

                    customizationSection("Call HUD demos") {
                        HStack {
                            ForEach(CallProvider.allCases) { provider in
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        viewModel.startDemoCall(provider: provider)
                                    }
                                } label: {
                                    Label(provider.rawValue, systemImage: provider.symbolName)
                                }
                                .controlButtonStyle()
                            }
                        }
                    }
                }
                .padding(22)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Customize StandBy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func customizationSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline.weight(.bold))
            content()
        }
        .padding(18)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private extension View {
    func glassCard(cornerRadius: CGFloat) -> some View {
        background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.14), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.24), radius: 30, x: 0, y: 16)
    }

    func glassCapsule() -> some View {
        background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            }
    }

    func controlButtonStyle(tint: Color? = nil) -> some View {
        buttonStyle(.plain)
            .font(.subheadline.weight(.bold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background((tint ?? Color.white).opacity(tint == nil ? 0.11 : 0.22), in: Capsule())
            .foregroundStyle(tint ?? .primary)
    }

    func transportButtonStyle() -> some View {
        buttonStyle(.plain)
            .font(.system(size: 22, weight: .bold))
            .frame(width: 52, height: 52)
            .background(.white.opacity(0.11), in: Circle())
    }
}

#Preview {
    ContentView()
        .environmentObject(StandByViewModel())
}
