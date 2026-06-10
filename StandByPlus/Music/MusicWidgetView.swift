import SwiftUI

struct MusicWidgetView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var music: MusicController
    let isHuge: Bool
    var onExpand: () -> Void

    var body: some View {
        Group {
            if isHuge {
                MusicControlsView(compact: false)
            } else {
                mediumBody
            }
        }
    }

    private var mediumBody: some View {
        let palette = theme.palette
        return VStack(spacing: 12) {
            HStack(spacing: 14) {
                ArtworkView(image: music.artwork, size: 64, accent: palette.accent.color)

                VStack(alignment: .leading, spacing: 3) {
                    Text(music.title)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(palette.primaryText.color)
                        .lineLimit(1)
                    Text(music.artist.isEmpty ? "—" : music.artist)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(palette.secondaryText.color)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)

                Button(action: onExpand) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(palette.secondaryText.color)
                        .padding(8)
                        .background(Circle().fill(palette.secondaryText.color.opacity(0.12)))
                }
                .buttonStyle(PressableButtonStyle())
            }

            HStack(spacing: 26) {
                Button { music.previous() } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(palette.primaryText.color)
                }
                .buttonStyle(PressableButtonStyle())

                Button { music.togglePlayPause() } label: {
                    Image(systemName: music.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(palette.background.color)
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(palette.accent.color))
                }
                .buttonStyle(PressableButtonStyle())

                Button { music.next() } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(palette.primaryText.color)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(16)
        .onAppear {
            if !music.authorized {
                music.requestAuthorization()
            }
        }
    }
}

struct ArtworkView: View {
    let image: UIImage?
    let size: CGFloat
    let accent: Color

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [accent.opacity(0.45), accent.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "music.note")
                        .font(.system(size: size * 0.36, weight: .medium))
                        .foregroundColor(accent)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }
}

/// The full, clean control surface — used by the huge widget and the expanded player.
struct MusicControlsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var music: MusicController
    /// Compact hides the volume row to fit smaller spaces.
    let compact: Bool

    @State private var scrubTime: TimeInterval = 0
    @State private var isScrubbing = false

    var body: some View {
        let palette = theme.palette
        GeometryReader { geo in
            let horizontal = geo.size.width > geo.size.height * 1.35

            Group {
                if horizontal {
                    HStack(spacing: geo.size.width * 0.05) {
                        artworkAndTitle(palette: palette, artSize: min(geo.size.height * 0.72, 240))
                            .frame(maxWidth: geo.size.width * 0.4)
                        controls(palette: palette)
                    }
                } else {
                    VStack(spacing: 18) {
                        artworkAndTitle(palette: palette, artSize: min(geo.size.width * 0.5, 220))
                        controls(palette: palette)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .padding(20)
        .onAppear {
            if !music.authorized {
                music.requestAuthorization()
            }
        }
    }

    private func artworkAndTitle(palette: Palette, artSize: CGFloat) -> some View {
        VStack(spacing: 12) {
            ArtworkView(image: music.artwork, size: artSize, accent: palette.accent.color)
            VStack(spacing: 3) {
                Text(music.title)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(palette.primaryText.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(music.artist.isEmpty ? "—" : music.artist)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(palette.secondaryText.color)
                    .lineLimit(1)
            }
        }
    }

    private func controls(palette: Palette) -> some View {
        VStack(spacing: 14) {
            // Scrubber
            VStack(spacing: 4) {
                ScrubSlider(
                    value: Binding(
                        get: { isScrubbing ? scrubTime : music.currentTime },
                        set: { scrubTime = $0 }
                    ),
                    range: 0...max(music.duration, 1),
                    tint: palette.accent.color,
                    track: palette.secondaryText.color.opacity(0.2)
                ) { editing in
                    if editing {
                        scrubTime = music.currentTime
                        isScrubbing = true
                    } else {
                        music.seek(to: scrubTime)
                        isScrubbing = false
                    }
                }

                HStack {
                    Text((isScrubbing ? scrubTime : music.currentTime).playbackString)
                    Spacer()
                    Text(music.duration.playbackString)
                }
                .font(.system(.caption2, design: .rounded).weight(.medium).monospacedDigit())
                .foregroundColor(palette.secondaryText.color)
            }

            // Transport
            HStack(spacing: 0) {
                Button { music.toggleShuffle() } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(music.shuffleOn ? palette.accent.color : palette.secondaryText.color)
                }
                .buttonStyle(PressableButtonStyle())
                .frame(maxWidth: .infinity)

                Button { music.previous() } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(palette.primaryText.color)
                }
                .buttonStyle(PressableButtonStyle())
                .frame(maxWidth: .infinity)

                Button { music.togglePlayPause() } label: {
                    Image(systemName: music.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(palette.background.color)
                        .frame(width: 66, height: 66)
                        .background(Circle().fill(palette.accent.color))
                        .shadow(color: palette.accent.color.opacity(0.35), radius: 12, y: 4)
                }
                .buttonStyle(PressableButtonStyle())
                .frame(maxWidth: .infinity)

                Button { music.next() } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(palette.primaryText.color)
                }
                .buttonStyle(PressableButtonStyle())
                .frame(maxWidth: .infinity)

                Button { music.cycleRepeat() } label: {
                    Image(systemName: music.repeatSetting.symbol)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(music.repeatSetting == .off ? palette.secondaryText.color : palette.accent.color)
                }
                .buttonStyle(PressableButtonStyle())
                .frame(maxWidth: .infinity)
            }

            if !compact {
                // Volume
                HStack(spacing: 10) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 12))
                        .foregroundColor(palette.secondaryText.color)
                    SystemVolumeSlider(tint: palette.accent.uiColor)
                        .frame(height: 24)
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 12))
                        .foregroundColor(palette.secondaryText.color)
                }

                // Open the source app
                Menu {
                    ForEach(MusicApp.allCases) { app in
                        Button(app.name) { music.openApp(app) }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.forward.app.fill")
                        Text("Open Music App")
                    }
                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                    .foregroundColor(palette.accent.color)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(palette.accent.color.opacity(0.14)))
                } primaryAction: {
                    music.openPreferredApp()
                }
            }
        }
    }
}
