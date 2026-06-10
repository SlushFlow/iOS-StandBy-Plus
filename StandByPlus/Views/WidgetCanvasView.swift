import SwiftUI

/// The free-form "windows" canvas. Widgets are positioned by a normalized center
/// point and can be dragged anywhere, resized between Medium and Huge, and
/// removed — all live, with the layout persisted via `AppSettings`.
struct WidgetCanvasView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette
    @Binding var editing: Bool

    @State private var selectedID: UUID?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(settings.widgets) { widget in
                    widgetView(widget, in: geo.size)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: settings.widgets)
    }

    @ViewBuilder
    private func widgetView(_ widget: PlacedWidget, in canvas: CGSize) -> some View {
        let footprint = widget.size.normalizedSize
        let w = canvas.width * footprint.width
        let h = canvas.height * footprint.height
        let x = canvas.width * widget.centerX
        let y = canvas.height * widget.centerY
        let isSelected = editing && selectedID == widget.id

        ZStack {
            content(for: widget)
        }
        .frame(width: w, height: h)
        .overlay(alignment: .topTrailing) {
            if editing { editControls(for: widget) }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(palette.accent.color, style: StrokeStyle(lineWidth: 2, dash: [7, 6]))
            }
        }
        .scaleEffect(isSelected ? 1.02 : 1)
        .position(x: x, y: y)
        .gesture(dragGesture(widget, canvas: canvas), including: editing ? .all : .subviews)
        .onTapGesture { if editing { selectedID = widget.id } }
        .zIndex(isSelected ? 1 : 0)
    }

    @ViewBuilder
    private func content(for widget: PlacedWidget) -> some View {
        // The big clock floats borderless for the classic StandBy look; every
        // other widget lives inside a frosted window.
        if widget.kind == .clock && !editing {
            WidgetRenderer(widget: widget)
        } else {
            GlassPanel {
                WidgetRenderer(widget: widget)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func editControls(for widget: PlacedWidget) -> some View {
        HStack(spacing: 8) {
            Button {
                toggleSize(widget)
            } label: {
                Image(systemName: widget.size == .medium ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(palette.background.color)
                    .padding(8)
                    .background(Circle().fill(palette.accent.color))
            }
            Button {
                remove(widget)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Circle().fill(Color.red))
            }
        }
        .buttonStyle(.plain)
        .padding(10)
    }

    private func dragGesture(_ widget: PlacedWidget, canvas: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard let idx = settings.widgets.firstIndex(where: { $0.id == widget.id }) else { return }
                selectedID = widget.id
                let nx = min(max(value.location.x / canvas.width, 0.05), 0.95)
                let ny = min(max(value.location.y / canvas.height, 0.05), 0.95)
                settings.widgets[idx].centerX = nx
                settings.widgets[idx].centerY = ny
            }
    }

    private func toggleSize(_ widget: PlacedWidget) {
        guard let idx = settings.widgets.firstIndex(where: { $0.id == widget.id }) else { return }
        settings.widgets[idx].size = widget.size == .medium ? .huge : .medium
    }

    private func remove(_ widget: PlacedWidget) {
        settings.widgets.removeAll { $0.id == widget.id }
        if selectedID == widget.id { selectedID = nil }
    }
}
