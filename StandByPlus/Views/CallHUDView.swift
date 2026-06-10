import SwiftUI

/// A full-surface HUD that appears when a call is ringing or active. It mirrors
/// the call state reported by CallKit and exposes the controls the platform
/// allows (and deep-links into the owning app for the rest).
struct CallHUDView: View {
    @EnvironmentObject private var calls: CallManager
    @Environment(\.palette) private var palette

    var body: some View {
        if let call = calls.call {
            ZStack {
                // Dim and blur the surface behind the call.
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(palette.background.with(opacity: 0.45).color)
                    .ignoresSafeArea()

                VStack(spacing: 26) {
                    header(call)
                    if call.state == .incoming {
                        incomingControls()
                    } else if call.state == .active {
                        activeControls()
                    } else {
                        Text("Call Ended")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.secondaryText.color)
                    }
                }
                .padding(40)
                .frame(maxWidth: 560)
            }
            .transition(.asymmetric(
                insertion: .scale(scale: 1.06).combined(with: .opacity),
                removal: .opacity))
        }
    }

    private func header(_ call: CallManager.CallInfo) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(call.app.tint.opacity(0.18))
                    .frame(width: 130, height: 130)
                Circle()
                    .strokeBorder(call.app.tint.opacity(0.5), lineWidth: 2)
                    .frame(width: 130, height: 130)
                    .scaleEffect(call.state == .incoming ? 1.18 : 1)
                    .opacity(call.state == .incoming ? 0 : 1)
                    .animation(call.state == .incoming ?
                        .easeOut(duration: 1.2).repeatForever(autoreverses: false) : .default,
                        value: call.state)
                Image(systemName: call.app.systemImage)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(call.app.tint)
            }
            VStack(spacing: 4) {
                Text(call.handle)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText.color)
                Text(subtitle(call))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryText.color)
            }
        }
    }

    private func subtitle(_ call: CallManager.CallInfo) -> String {
        switch call.state {
        case .incoming: return "Incoming • \(call.app.displayName)"
        case .active:
            let secs = Int(calls.duration)
            return String(format: "%@ • %d:%02d", call.app.displayName, secs / 60, secs % 60)
        case .ended: return call.app.displayName
        }
    }

    private func incomingControls() -> some View {
        HStack(spacing: 70) {
            VStack(spacing: 10) {
                CircleButton(systemImage: "phone.down.fill", size: 76, iconScale: 0.42,
                             fill: .red, foreground: .white) {
                    withAnimation { calls.decline() }
                }
                Text("Decline").font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryText.color)
            }
            VStack(spacing: 10) {
                CircleButton(systemImage: "phone.fill", size: 76, iconScale: 0.42,
                             fill: .green, foreground: .white) {
                    withAnimation { calls.answer() }
                }
                Text("Accept").font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryText.color)
            }
        }
    }

    private func activeControls() -> some View {
        VStack(spacing: 26) {
            HStack(spacing: 40) {
                labeled("Mute", active: calls.isMuted) {
                    CircleButton(systemImage: calls.isMuted ? "mic.slash.fill" : "mic.fill",
                                 size: 66, isActive: calls.isMuted) { calls.toggleMute() }
                }
                labeled("Speaker", active: calls.isSpeaker) {
                    CircleButton(systemImage: "speaker.wave.2.fill",
                                 size: 66, isActive: calls.isSpeaker) { calls.toggleSpeaker() }
                }
                labeled("Open App", active: false) {
                    CircleButton(systemImage: "arrow.up.forward.app.fill", size: 66) { calls.openApp() }
                }
            }
            VStack(spacing: 10) {
                CircleButton(systemImage: "phone.down.fill", size: 78, iconScale: 0.42,
                             fill: .red, foreground: .white) {
                    withAnimation { calls.hangUp() }
                }
                Text("End").font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryText.color)
            }
        }
    }

    private func labeled<V: View>(_ title: String, active: Bool, @ViewBuilder content: () -> V) -> some View {
        VStack(spacing: 10) {
            content()
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(palette.secondaryText.color)
        }
    }
}
