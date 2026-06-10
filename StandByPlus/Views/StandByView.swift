import SwiftUI

struct StandByView: View {
    @EnvironmentObject private var settings: StandBySettings
    @EnvironmentObject private var callService: CallService
    @EnvironmentObject private var musicService: MusicService

    @Binding var showSettings: Bool
    @Binding var showCustomization: Bool

    @State private var currentTime = Date()
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                backgroundLayer

                VStack(spacing: 16) {
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    WidgetCanvasView(containerSize: CGSize(
                        width: proxy.size.width - 32,
                        height: proxy.size.height - 120
                    ))
                    .padding(.horizontal, 16)
                }

                if settings.showCallHUD, let call = callService.activeCall, call.isActiveSession {
                    CallHUDView(call: call)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                }
            }
        }
        .ignoresSafeArea()
        .environment(\.themePalette, settings.activePalette)
        .onReceive(clockTimer) { date in
            currentTime = date
            settings.refreshDayNight()
        }
        .animation(
            SmoothAnimation.spring(reduceMotion: settings.reduceMotion),
            value: callService.activeCall?.id
        )
        .animation(
            SmoothAnimation.spring(reduceMotion: settings.reduceMotion),
            value: settings.activePalette
        )
    }

    private var backgroundLayer: some View {
        ZStack {
            settings.activePalette.background.color
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    settings.activePalette.glow.color.opacity(0.45),
                    settings.activePalette.background.color.opacity(0.05)
                ],
                center: .topLeading,
                startRadius: 40,
                endRadius: max(500, UIScreen.main.bounds.width)
            )
            .ignoresSafeArea()
            .blendMode(.plusLighter)

            RadialGradient(
                colors: [
                    settings.activePalette.accent.color.opacity(0.12),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("StandBy Plus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(settings.activePalette.textSecondary.color)
                Text(currentTime.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(settings.activePalette.textPrimary.color)
            }

            Spacer()

            HStack(spacing: 10) {
                StandByIconButton(systemImage: "slider.horizontal.3", label: "Customize") {
                    showCustomization = true
                }

                StandByIconButton(systemImage: "gearshape.fill", label: "Settings") {
                    showSettings = true
                }
            }
        }
    }
}

struct StandByIconButton: View {
    @Environment(\.themePalette) private var palette

    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.textPrimary.color)
                .frame(width: 42, height: 42)
                .background(palette.surface.color.opacity(0.85))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(palette.accent.color.opacity(0.2), lineWidth: 1)
                )
        }
        .accessibilityLabel(label)
    }
}
