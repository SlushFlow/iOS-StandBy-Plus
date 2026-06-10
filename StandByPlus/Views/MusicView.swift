import SwiftUI

/// The clean, easy-on-the-eyes now-playing surface with full transport controls.
struct MusicView: View {
    @EnvironmentObject private var nowPlaying: NowPlayingManager
    @EnvironmentObject private var volume: VolumeController
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette

    @State private var scrubbing = false
    @State private var scrubValue: Double = 0

    var body: some View {
        GeometryReader { geo in
            let landscape = geo.size.width > geo.size.height
            let track = nowPlaying.track
            Group {
                if landscape {
                    HStack(spacing: 40) {
                        artwork(side: min(geo.size.height * 0.78, 320))
                        controls(track: track)
                            .frame(maxWidth: 440)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 50)
                } else {
                    VStack(spacing: 28) {
                        artwork(side: min(geo.size.width * 0.7, 300))
                        controls(track: track)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 32)
                }
            }
        }
    }

    private func artwork(side: CGFloat) -> some View {
        Artwork(image: nowPlaying.track?.artwork, size: side, corner: 28)
            .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 18)
            .scaleEffect(nowPlaying.isPlaying ? 1 : 0.92)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: nowPlaying.isPlaying)
    }

    private func controls(track: NowPlayingManager.Track?) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            // Title block + open source app
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(track?.title ?? "Nothing Playing")
                        .font(.system(size: 30, weight: .bold, design: settings.fontStyle.design))
                        .foregroundStyle(palette.primaryText.color)
                        .lineLimit(2)
                    Text(track?.artist ?? "—")
                        .font(.system(size: 19, weight: .medium, design: settings.fontStyle.design))
                        .foregroundStyle(palette.secondaryText.color)
                        .lineLimit(1)
                    if nowPlaying.isDemo {
                        Text("Demo session")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.accent.color)
                            .padding(.top, 2)
                    }
                }
                Spacer()
                CircleButton(systemImage: "arrow.up.forward.app.fill", size: 46) {
                    nowPlaying.openSourceApp()
                }
            }

            // Scrubber + times
            VStack(spacing: 6) {
                PillSlider(
                    value: Binding(
                        get: {
                            guard let dur = track?.duration, dur > 0 else { return 0 }
                            return scrubbing ? scrubValue : nowPlaying.elapsed / dur
                        },
                        set: { scrubValue = $0 }
                    ),
                    onEditingChanged: { editing in
                        if editing {
                            scrubbing = true
                        } else {
                            if let dur = track?.duration {
                                nowPlaying.seek(to: scrubValue * dur)
                            }
                            scrubbing = false
                        }
                    }
                )
                HStack {
                    Text(timeText(scrubbing ? scrubValue * (track?.duration ?? 0) : nowPlaying.elapsed))
                    Spacer()
                    Text("-" + timeText(max((track?.duration ?? 0) - (scrubbing ? scrubValue * (track?.duration ?? 0) : nowPlaying.elapsed), 0)))
                }
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(palette.secondaryText.color)
            }

            // Transport
            HStack {
                CircleButton(systemImage: "shuffle", size: 48, isActive: nowPlaying.shuffleEnabled) {
                    nowPlaying.toggleShuffle()
                }
                Spacer()
                CircleButton(systemImage: "backward.fill", size: 56) { nowPlaying.previous() }
                Spacer()
                CircleButton(systemImage: nowPlaying.isPlaying ? "pause.fill" : "play.fill",
                             size: 78, iconScale: 0.4,
                             fill: palette.accent.color,
                             foreground: palette.background.color) {
                    nowPlaying.togglePlayPause()
                }
                Spacer()
                CircleButton(systemImage: "forward.fill", size: 56) { nowPlaying.next() }
                Spacer()
                CircleButton(systemImage: nowPlaying.repeatMode.systemImage, size: 48,
                             isActive: nowPlaying.repeatMode != .off) {
                    nowPlaying.cycleRepeat()
                }
            }

            // Volume
            PillSlider(
                value: Binding(
                    get: { volume.volume },
                    set: { volume.setVolume($0) }
                ),
                leadingIcon: "speaker.fill",
                trailingIcon: "speaker.wave.3.fill"
            )
        }
    }

    private func timeText(_ t: TimeInterval) -> String {
        guard t.isFinite, t >= 0 else { return "0:00" }
        let total = Int(t)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
