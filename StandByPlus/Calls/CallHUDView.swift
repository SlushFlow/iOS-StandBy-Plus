import SwiftUI

struct CallHUDView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var monitor: CallMonitor

    var body: some View {
        VStack(spacing: 10) {
            if let call = monitor.primaryCall {
                hud(for: call)
            }
            if let message = monitor.statusMessage {
                Text(message)
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundColor(theme.palette.primaryText.color)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(theme.palette.widgetBackground.color))
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.top, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func hud(for call: ObservedCall) -> some View {
        let palette = theme.palette
        return VStack(spacing: 14) {
            // State + timer row
            HStack(spacing: 10) {
                PulsingDot(color: call.isRinging ? .green : palette.accent.color)
                Text(call.stateLabel)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(palette.primaryText.color)
                if let connectedAt = call.connectedAt {
                    CallDurationText(since: connectedAt)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold).monospacedDigit())
                        .foregroundColor(palette.secondaryText.color)
                }
            }

            // Action buttons
            if call.isRinging {
                HStack(spacing: 22) {
                    CallActionButton(symbol: "phone.down.fill", label: "Decline", background: .red, foreground: .white) {
                        monitor.decline(call)
                    }
                    CallActionButton(symbol: "phone.fill", label: "Accept", background: .green, foreground: .white) {
                        monitor.answer(call)
                    }
                }
            } else {
                HStack(spacing: 18) {
                    CallActionButton(
                        symbol: monitor.isMuted ? "mic.slash.fill" : "mic.fill",
                        label: "Mute",
                        background: monitor.isMuted ? palette.accent.color : palette.widgetBackground.color,
                        foreground: monitor.isMuted ? palette.background.color : palette.primaryText.color
                    ) {
                        monitor.toggleMute(call)
                    }
                    CallActionButton(
                        symbol: "speaker.wave.2.fill",
                        label: "Speaker",
                        background: monitor.speakerOn ? palette.accent.color : palette.widgetBackground.color,
                        foreground: monitor.speakerOn ? palette.background.color : palette.primaryText.color
                    ) {
                        monitor.toggleSpeaker()
                    }
                    CallActionButton(symbol: "phone.down.fill", label: "Hang Up", background: .red, foreground: .white) {
                        monitor.hangUp(call)
                    }
                }
            }

            // Quick-open the app the call lives in.
            VStack(spacing: 6) {
                Text("OPEN APP")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(palette.secondaryText.color)
                HStack(spacing: 14) {
                    ForEach(CallApp.all) { app in
                        Button {
                            monitor.openApp(app)
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: app.symbol)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(palette.accent.color)
                                    .frame(width: 38, height: 38)
                                    .background(Circle().fill(palette.accent.color.opacity(0.13)))
                                Text(app.name)
                                    .font(.system(size: 8, weight: .medium, design: .rounded))
                                    .foregroundColor(palette.secondaryText.color)
                            }
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(theme.palette.widgetBackground.color.opacity(0.65))
                )
                .shadow(color: .black.opacity(0.35), radius: 24, y: 10)
        )
        .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.92)))
    }
}

private struct CallActionButton: View {
    let symbol: String
    let label: String
    let background: Color
    let foreground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(foreground)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(background))
                    .shadow(color: background.opacity(0.4), radius: 8, y: 3)
                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct PulsingDot: View {
    let color: Color
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 9, height: 9)
            .scaleEffect(pulse ? 1.35 : 0.85)
            .opacity(pulse ? 0.6 : 1)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

private struct CallDurationText: View {
    let since: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(context.date.timeIntervalSince(since).playbackString)
        }
    }
}
