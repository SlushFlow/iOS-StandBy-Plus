import SwiftUI
import UIKit

/// A round, tappable control used throughout the music and call HUDs, with a
/// gentle press animation.
struct CircleButton: View {
    var systemImage: String
    var size: CGFloat = 56
    var iconScale: CGFloat = 0.42
    var isActive: Bool = false
    var fill: Color? = nil
    var foreground: Color? = nil
    var action: () -> Void

    @Environment(\.palette) private var palette
    @State private var pressed = false

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(fill ?? (isActive ? palette.accent.color : palette.primaryText.with(opacity: 0.08).color))
                Image(systemName: systemImage)
                    .font(.system(size: size * iconScale, weight: .semibold))
                    .foregroundStyle(foreground ?? (isActive ? palette.background.color : palette.primaryText.color))
            }
            .frame(width: size, height: size)
            .scaleEffect(pressed ? 0.9 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.12)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { pressed = false } }
        )
    }
}
