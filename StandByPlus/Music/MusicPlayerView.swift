import SwiftUI

/// Full-screen, easy-on-the-eyes now playing surface.
struct MusicPlayerView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var music: MusicController
    var onClose: () -> Void

    var body: some View {
        let palette = theme.palette
        ZStack {
            // Soft blurred artwork backdrop for coziness.
            if let artwork = music.artwork {
                Image(uiImage: artwork)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 70)
                    .opacity(theme.isNight ? 0.25 : 0.4)
                    .overlay(palette.background.color.opacity(0.72).ignoresSafeArea())
            } else {
                palette.background.color.ignoresSafeArea()
            }

            MusicControlsView(compact: false)
                .padding(.horizontal, 12)

            VStack {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(palette.secondaryText.color)
                            .padding(12)
                            .background(Circle().fill(palette.widgetBackground.color))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.trailing, 18)
                    .padding(.top, 12)
                }
                Spacer()
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 1.06)))
    }
}
