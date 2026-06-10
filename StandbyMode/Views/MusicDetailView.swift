import SwiftUI

struct MusicDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var musicManager: MusicPlayerManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            themeManager.colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                dragIndicator

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        albumArtSection
                        trackInfoSection
                        progressSection
                        controlsSection
                        volumeSection
                        extraControlsSection
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }

    private var dragIndicator: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(themeManager.colors.textSecondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 10)

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.colors.textSecondary)
                }
                Spacer()
                Text("Now Playing")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.colors.textSecondary)
                Spacer()
                Button(action: musicManager.openSourceApp) {
                    Image(systemName: "arrow.up.forward.square")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.colors.textSecondary)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var albumArtSection: some View {
        Group {
            if let artwork = musicManager.albumArtwork {
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 280, maxHeight: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 24, y: 12)
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [themeManager.colors.primary.opacity(0.3), themeManager.colors.secondary.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 280, height: 280)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.colors.textPrimary.opacity(0.3))
                    )
                    .shadow(color: .black.opacity(0.3), radius: 24, y: 12)
            }
        }
        .scaleEffect(musicManager.isPlaying ? 1.0 : 0.92)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: musicManager.isPlaying)
    }

    private var trackInfoSection: some View {
        VStack(spacing: 6) {
            Text(musicManager.songTitle)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(themeManager.colors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            Text(musicManager.artistName)
                .font(.system(size: 16))
                .foregroundColor(themeManager.colors.textSecondary)
                .lineLimit(1)
        }
    }

    private var progressSection: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(themeManager.colors.textSecondary.opacity(0.15))
                        .frame(height: 6)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [themeManager.colors.primary, themeManager.colors.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: progressWidth(in: geo.size.width), height: 6)

                    Circle()
                        .fill(themeManager.colors.textPrimary)
                        .frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        .offset(x: progressWidth(in: geo.size.width) - 7)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let ratio = max(0, min(1, value.location.x / geo.size.width))
                            musicManager.seekTo(ratio * musicManager.duration)
                        }
                )
            }
            .frame(height: 14)

            HStack {
                Text(musicManager.formatTime(musicManager.currentTime))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(themeManager.colors.textSecondary)
                Spacer()
                Text("-" + musicManager.formatTime(max(0, musicManager.duration - musicManager.currentTime)))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(themeManager.colors.textSecondary)
            }
        }
    }

    private var controlsSection: some View {
        HStack(spacing: 0) {
            Button(action: musicManager.toggleShuffle) {
                Image(systemName: "shuffle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(musicManager.isShuffled ? themeManager.colors.accent : themeManager.colors.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Button(action: musicManager.previousTrack) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.colors.textPrimary)
            }
            .frame(maxWidth: .infinity)

            Button(action: musicManager.togglePlayPause) {
                ZStack {
                    Circle()
                        .fill(themeManager.colors.primary)
                        .frame(width: 64, height: 64)
                        .shadow(color: themeManager.colors.primary.opacity(0.4), radius: 12, y: 4)

                    Image(systemName: musicManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .offset(x: musicManager.isPlaying ? 0 : 2)
                }
            }
            .frame(maxWidth: .infinity)

            Button(action: musicManager.nextTrack) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.colors.textPrimary)
            }
            .frame(maxWidth: .infinity)

            Button(action: musicManager.cycleLoopMode) {
                Image(systemName: loopIcon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(musicManager.loopMode != .none ? themeManager.colors.accent : themeManager.colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var volumeSection: some View {
        HStack(spacing: 14) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 13))
                .foregroundColor(themeManager.colors.textSecondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(themeManager.colors.textSecondary.opacity(0.15))
                        .frame(height: 6)

                    Capsule()
                        .fill(themeManager.colors.textPrimary)
                        .frame(width: geo.size.width * CGFloat(musicManager.volume), height: 6)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let ratio = Float(max(0, min(1, value.location.x / geo.size.width)))
                            musicManager.setVolume(ratio)
                        }
                )
            }
            .frame(height: 6)

            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 13))
                .foregroundColor(themeManager.colors.textSecondary)
        }
        .padding(.horizontal, 4)
    }

    private var extraControlsSection: some View {
        HStack(spacing: 24) {
            Button(action: musicManager.openSourceApp) {
                VStack(spacing: 6) {
                    Image(systemName: "music.note.house.fill")
                        .font(.system(size: 20))
                    Text("Open App")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(themeManager.colors.textSecondary)
                .frame(maxWidth: .infinity)
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
