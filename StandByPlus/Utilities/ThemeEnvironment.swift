import SwiftUI

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = ThemePalette.cozyDark
}

extension EnvironmentValues {
    var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}

struct CozyCardStyle: ViewModifier {
    @Environment(\.themePalette) private var palette

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(palette.surface.color)
                    .shadow(color: palette.glow.color, radius: 18, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(palette.accent.color.opacity(0.15), lineWidth: 1)
            )
    }
}

extension View {
    func cozyCard() -> some View {
        modifier(CozyCardStyle())
    }
}

struct SmoothAnimation {
    static func spring(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.82)
    }
}
