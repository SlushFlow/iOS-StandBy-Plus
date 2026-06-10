import SwiftUI

struct MusicWidgetView: View {
    let size: WidgetSize
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var musicManager: MusicPlayerManager

    var body: some View {
        Group {
            if size == .huge {
                largeMusicView
            } else {
                compactMusicView
            }
        }
        .padding()
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                musicManager.showMusicPanel.toggle()
            }
        }
        .sheet(isPresented: $musicManager.showMusicPanel) {
            MusicDetailView()
                .environmentObject(themeManager)
                .environmentObject(musicManager)
        }
    }

    private var compactMusicView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                albumArtView(size: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(musicManager.songTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeManager.colors.textPrimary)
                        .lineLimit(1)

                    Text(musicManager.artistName)
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.colors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            HStack(spacing: 24) {
                Button(action: musicManager.previousTrack) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.colors.textPrimary)
                }

                Button(action: musicManager.togglePlayPause) {
                    Image(systemName: musicManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22))
                        .foregroundColor(themeManager.colors.primary)
                }

                Button(action: musicManager.nextTrack) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.colors.textPrimary)
                }
            }

            progressBar
        }
    }

    private var largeMusicView: some View {
        HStack(spacing: 20) {
            albumArtView(size: 120)

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(musicManager.songTitle)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.colors.textPrimary)
                        .lineLimit(2)

                    Text(musicManager.artistName)
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.colors.textSecondary)
                        .lineLimit(1)
                }

                progressBar

                HStack(spacing: 20) {
                    Button(action: musicManager.toggleShuffle) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 14))
                            .foregroundColor(musicManager.isShuffled ? themeManager.colors.accent : themeManager.colors.textSecondary)
                    }

                    Spacer()

                    Button(action: musicManager.previousTrack) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(themeManager.colors.textPrimary)
                    }

                    Button(action: musicManager.togglePlayPause) {
                        Image(systemName: musicManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(themeManager.colors.primary)
                    }

                    Button(action: musicManager.nextTrack) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(themeManager.colors.textPrimary)
                    }

                    Spacer()

                    Button(action: musicManager.cycleLoopMode) {
                        Image(systemName: loopIcon)
                            .font(.system(size: 14))
                            .foregroundColor(musicManager.loopMode != .none ? themeManager.colors.accent : themeManager.colors.textSecondary)
                    }
                }
            }
        }
    }

    private var progressBar: some View {
        VStack(spacing: 2) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(themeManager.colors.textSecondary.opacity(0.2))
                        .frame(height: 3)

                    Capsule()
                        .fill(themeManager.colors.primary)
                        .frame(width: progressWidth(in: geo.size.width), height: 3)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let ratio = max(0, min(1, value.location.x / geo.size.width))
                            musicManager.seekTo(ratio * musicManager.duration)
                        }
                )
            }
            .frame(height: 3)

            HStack {
                Text(musicManager.formatTime(musicManager.currentTime))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(themeManager.colors.textSecondary)
                Spacer()
                Text(musicManager.formatTime(musicManager.duration))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(themeManager.colors.textSecondary)
            }
        }
    }

    private func albumArtView(size: CGFloat) -> some View {
        Group {
            if let artwork = musicManager.albumArtwork {
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.15, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: size * 0.15, style: .continuous)
                    .fill(themeManager.colors.primary.opacity(0.2))
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: size * 0.35))
                            .foregroundColor(themeManager.colors.primary.opacity(0.5))
                    )
            }
        }
    }

    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        guard musicManager.duration > 0 else { return 0 }
        return totalWidth * CGFloat(musicManager.currentTime / musicManager.duration)
    }

    private var loopIcon: String {
        switch musicManager.loopMode {
        case .none: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }
}
