import SwiftUI

/// A soft, frosted container used for every widget and HUD panel. It adapts to
/// the active palette so it feels right in both cozy-dark and light modes.
struct GlassPanel<Content: View>: View {
    @Environment(\.palette) private var palette
    var cornerRadius: CGFloat = 28
    var padding: CGFloat = 18
    var content: Content

    init(cornerRadius: CGFloat = 28, padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(palette.surface.color)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [palette.primaryText.with(opacity: 0.16).color,
                                             palette.primaryText.with(opacity: 0.02).color],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing),
                                lineWidth: 1)
                    }
            }
            .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 12)
    }
}
