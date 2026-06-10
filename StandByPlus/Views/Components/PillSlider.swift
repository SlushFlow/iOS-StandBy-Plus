import SwiftUI

/// A minimalist, draggable slider used for the music scrubber and volume. It
/// grows slightly while dragging for a tactile feel.
struct PillSlider: View {
    @Binding var value: Double           // 0...1
    var leadingIcon: String? = nil
    var trailingIcon: String? = nil
    var onEditingChanged: ((Bool) -> Void)? = nil

    @Environment(\.palette) private var palette
    @State private var dragging = false

    var body: some View {
        HStack(spacing: 12) {
            if let leadingIcon {
                Image(systemName: leadingIcon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.secondaryText.color)
            }
            GeometryReader { geo in
                let width = geo.size.width
                let clamped = min(max(value, 0), 1)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(palette.primaryText.with(opacity: 0.14).color)
                    Capsule()
                        .fill(palette.accent.color)
                        .frame(width: max(width * clamped, 0))
                }
                .frame(height: dragging ? 12 : 7)
                .frame(maxHeight: .infinity, alignment: .center)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { g in
                            if !dragging {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { dragging = true }
                                onEditingChanged?(true)
                            }
                            value = min(max(Double(g.location.x / width), 0), 1)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { dragging = false }
                            onEditingChanged?(false)
                        }
                )
                .animation(.easeOut(duration: 0.15), value: clamped)
            }
            .frame(height: 24)
            if let trailingIcon {
                Image(systemName: trailingIcon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(palette.secondaryText.color)
            }
        }
    }
}
