import SwiftUI

struct CallHUDView: View {
    @EnvironmentObject private var settings: StandBySettings
    @EnvironmentObject private var callService: CallService
    @Environment(\.themePalette) private var palette

    let call: ActiveCall

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(palette.accent.color.opacity(0.2))
                        .frame(width: 54, height: 54)
                    Image(systemName: call.source.systemImage)
                        .font(.title2)
                        .foregroundStyle(palette.accent.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(call.source.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.textSecondary.color)
                    Text(call.callerName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(palette.textPrimary.color)
                    Text(call.statusText)
                        .font(.subheadline)
                        .foregroundStyle(palette.accent.color)
                }

                Spacer()

                if call.canAcceptOrDecline {
                    acceptDeclineButtons
                } else {
                    activeCallButtons
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(palette.surface.color.opacity(0.95))
                    .shadow(color: palette.glow.color, radius: 20, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(palette.accent.color.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var acceptDeclineButtons: some View {
        HStack(spacing: 12) {
            CallHUDButton(
                title: "Decline",
                systemImage: "phone.down.fill",
                tint: .red,
                action: callService.declineCall
            )

            CallHUDButton(
                title: "Accept",
                systemImage: "phone.fill",
                tint: .green,
                action: callService.acceptCall
            )
        }
    }

    private var activeCallButtons: some View {
        HStack(spacing: 10) {
            CallHUDButton(
                title: "Open",
                systemImage: "arrow.up.forward.app",
                tint: palette.accent.color,
                action: callService.openCallingApp
            )

            CallHUDButton(
                title: callService.isMuted ? "Unmute" : "Mute",
                systemImage: callService.isMuted ? "mic.slash.fill" : "mic.fill",
                tint: palette.textPrimary.color,
                action: callService.toggleMute
            )

            CallHUDButton(
                title: "Speaker",
                systemImage: callService.isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill",
                tint: palette.textPrimary.color,
                action: callService.toggleSpeaker
            )

            CallHUDButton(
                title: "End",
                systemImage: "phone.down.fill",
                tint: .red,
                action: callService.hangUp
            )
        }
    }
}

struct CallHUDButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .background(tint.opacity(0.15))
                    .foregroundStyle(tint)
                    .clipShape(Circle())

                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}
