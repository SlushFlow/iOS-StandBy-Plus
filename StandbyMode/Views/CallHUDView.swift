import SwiftUI

struct CallHUDView: View {
    @EnvironmentObject var callManager: CallManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var pulseAnimation = false

    var body: some View {
        VStack {
            callContent
                .padding(.horizontal, 20)
                .padding(.top, 60)
            Spacer()
        }
    }

    @ViewBuilder
    private var callContent: some View {
        switch callManager.callState {
        case .none:
            EmptyView()

        case .incoming(let caller, let source):
            incomingCallView(caller: caller, source: source)

        case .active(let caller, let source, let duration):
            activeCallView(caller: caller, source: source, duration: duration)

        case .onHold(let caller, let source):
            onHoldCallView(caller: caller, source: source)
        }
    }

    private func incomingCallView(caller: String, source: CallSource) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(source.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0.3 : 0.8)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseAnimation)

                    Image(systemName: source.icon)
                        .font(.system(size: 22))
                        .foregroundColor(source.color)
                }
                .onAppear { pulseAnimation = true }

                VStack(alignment: .leading, spacing: 2) {
                    Text(caller)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.colors.textPrimary)

                    Text("\(source.rawValue) call")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.colors.textSecondary)
                }

                Spacer()

                Button(action: callManager.openSourceApp) {
                    Image(systemName: "arrow.up.forward.square.fill")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.colors.textSecondary)
                }
            }

            HStack(spacing: 40) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        callManager.declineCall()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 16))
                        Text("Decline")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.red)
                            .shadow(color: .red.opacity(0.4), radius: 8, y: 4)
                    )
                }

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        callManager.acceptCall()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16))
                        Text("Accept")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.green)
                            .shadow(color: .green.opacity(0.4), radius: 8, y: 4)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(source.color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
        )
    }

    private func activeCallView(caller: String, source: CallSource, duration: TimeInterval) -> some View {
        HStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: source.icon)
                    .font(.system(size: 18))
                    .foregroundColor(source.color)

                VStack(alignment: .leading, spacing: 1) {
                    Text(caller)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.colors.textPrimary)
                        .lineLimit(1)

                    Text(callManager.formatDuration(duration))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(themeManager.colors.accent)
                }
            }

            Spacer()

            HStack(spacing: 12) {
                callControlButton(
                    icon: callManager.isMuted ? "mic.slash.fill" : "mic.fill",
                    isActive: callManager.isMuted,
                    activeColor: .orange,
                    action: callManager.toggleMute
                )

                callControlButton(
                    icon: callManager.isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill",
                    isActive: callManager.isSpeakerOn,
                    activeColor: themeManager.colors.primary,
                    action: callManager.toggleSpeaker
                )

                Button(action: callManager.openSourceApp) {
                    Image(systemName: "arrow.up.forward.square.fill")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.colors.textSecondary)
                }

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        callManager.endCall()
                    }
                }) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(.red)
                                .shadow(color: .red.opacity(0.3), radius: 6, y: 2)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(source.color.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
        )
    }

    private func onHoldCallView(caller: String, source: CallSource) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 1) {
                Text(caller)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.colors.textPrimary)
                Text("On Hold")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
            }

            Spacer()

            Button(action: callManager.openSourceApp) {
                Text("Resume")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.colors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(themeManager.colors.primary.opacity(0.15))
                    )
            }

            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    callManager.endCall()
                }
            }) {
                Image(systemName: "phone.down.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(.red))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
        )
    }

    private func callControlButton(icon: String, isActive: Bool, activeColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isActive ? activeColor : themeManager.colors.textSecondary)
                .padding(10)
                .background(
                    Circle()
                        .fill(isActive ? activeColor.opacity(0.15) : themeManager.colors.surface.opacity(0.5))
                )
        }
    }
}
