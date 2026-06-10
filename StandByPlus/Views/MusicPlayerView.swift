import MediaPlayer
import SwiftUI

struct MusicPlayerView: View {
    @EnvironmentObject private var settings: StandBySettings
    @EnvironmentObject private var musicService: MusicService
    @Environment(\.themePalette) private var palette

    var compact: Bool = false

    @State private var isScrubbing = false
    @State private var scrubProgress: Double = 0

    var body: some View {
        let track = musicService.track

        VStack(alignment: .leading, spacing: compact ? 12 : 16) {
            header(for: track)

            if !compact {
                artwork(for: track)
            }

            progressSection(for: track)

            if !compact {
                volumeSection
            }

            controlsRow(for: track)
        }
        .padding(compact ? 16 : 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onChange(of: track.elapsed) { _, _ in
            if !isScrubbing, track.duration > 0 {
                scrubProgress = track.elapsed / track.duration
            }
        }
        .onAppear {
            if track.duration > 0 {
                scrubProgress = track.elapsed / track.duration
            }
        }
    }

    private func header(for track: NowPlayingTrack) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Label(track.source.displayName, systemImage: track.source.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.textSecondary.color)

                Text(track.title)
                    .font(compact ? .headline : .title2.weight(.semibold))
                    .foregroundStyle(palette.textPrimary.color)
                    .lineLimit(2)

                Text(track.artist)
                    .font(.subheadline)
                    .foregroundStyle(palette.textSecondary.color)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: musicService.openMusicApp) {
                Image(systemName: "arrow.up.forward.app")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(palette.accent.color)
                    .frame(width: 36, height: 36)
                    .background(palette.accent.color.opacity(0.12))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Open music app")
        }
    }

    @ViewBuilder
    private func artwork(for track: NowPlayingTrack) -> some View {
        Group {
            if let data = track.artworkData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [
                            palette.accent.color.opacity(0.35),
                            palette.surface.color
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "music.note")
                        .font(.largeTitle)
                        .foregroundStyle(palette.textPrimary.color.opacity(0.7))
                }
            }
        }
        .frame(height: compact ? 0 : 120)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .opacity(compact ? 0 : 1)
    }

    private func progressSection(for track: NowPlayingTrack) -> some View {
        VStack(spacing: 8) {
            Slider(
                value: Binding(
                    get: { isScrubbing ? scrubProgress : (track.duration > 0 ? track.elapsed / track.duration : 0) },
                    set: { newValue in
                        scrubProgress = newValue
                    }
                ),
                in: 0...1,
                onEditingChanged: { editing in
                    isScrubbing = editing
                    if !editing {
                        musicService.seek(to: scrubProgress)
                    }
                }
            )
            .tint(palette.accent.color)

            HStack {
                Text(formatTime(track.elapsed))
                Spacer()
                Text(formatTime(track.duration))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(palette.textSecondary.color)
        }
    }

    private var volumeSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "speaker.fill")
                .foregroundStyle(palette.textSecondary.color)
                .font(.caption)

            MPVolumeSliderRepresentable(volume: Binding(
                get: { musicService.volume },
                set: { musicService.setVolume($0) }
            ))
            .frame(height: 24)

            Image(systemName: "speaker.wave.3.fill")
                .foregroundStyle(palette.textSecondary.color)
                .font(.caption)
        }
    }

    private func controlsRow(for track: NowPlayingTrack) -> some View {
        HStack(spacing: compact ? 8 : 14) {
            MusicControlButton(
                systemImage: "shuffle",
                isActive: track.shuffleEnabled,
                accent: palette.accent.color,
                action: musicService.toggleShuffle
            )

            MusicControlButton(
                systemImage: "backward.fill",
                isActive: false,
                accent: palette.textPrimary.color,
                action: musicService.previousTrack
            )

            Button(action: musicService.togglePlayPause) {
                Image(systemName: track.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: compact ? 44 : 52, height: compact ? 44 : 52)
                    .background(palette.accent.color)
                    .clipShape(Circle())
                    .shadow(color: palette.glow.color, radius: 10, y: 4)
            }

            MusicControlButton(
                systemImage: "forward.fill",
                isActive: false,
                accent: palette.textPrimary.color,
                action: musicService.nextTrack
            )

            MusicControlButton(
                systemImage: track.repeatMode.systemImage,
                isActive: track.repeatMode != .off,
                accent: palette.accent.color,
                action: musicService.cycleRepeatMode
            )
        }
        .frame(maxWidth: .infinity)
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        guard interval.isFinite, interval >= 0 else { return "0:00" }
        let total = Int(interval)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MusicControlButton: View {
    let systemImage: String
    let isActive: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(isActive ? accent : accent.opacity(0.65))
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }
}

struct MPVolumeSliderRepresentable: UIViewRepresentable {
    @Binding var volume: Float

    func makeUIView(context: Context) -> MPVolumeView {
        let view = MPVolumeView(frame: .zero)
        view.showsRouteButton = false
        view.tintColor = UIColor.systemBlue
        return view
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        // MPVolumeView manages system volume; binding is read-mostly.
    }
}
