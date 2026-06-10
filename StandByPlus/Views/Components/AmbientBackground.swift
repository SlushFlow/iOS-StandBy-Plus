import SwiftUI

/// A calm, slowly-drifting gradient backdrop. Two soft accent blobs breathe in
/// the background to give the cozy, living feel without being distracting.
struct AmbientBackground: View {
    @Environment(\.palette) private var palette
    var animated: Bool

    @State private var phase = false

    var body: some View {
        ZStack {
            palette.backgroundGradient
                .ignoresSafeArea()

            blob(color: palette.accent.color.opacity(0.20), size: 360)
                .offset(x: phase ? -120 : -60, y: phase ? -140 : -90)

            blob(color: palette.accent.color.opacity(0.12), size: 460)
                .offset(x: phase ? 150 : 90, y: phase ? 160 : 120)

            blob(color: palette.primaryText.with(opacity: 0.05).color, size: 300)
                .offset(x: phase ? 40 : -20, y: phase ? -160 : -120)
        }
        .ignoresSafeArea()
        .onAppear {
            guard animated else { return }
            withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                phase = true
            }
        }
    }

    private func blob(color: Color, size: CGFloat) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 90)
    }
}
