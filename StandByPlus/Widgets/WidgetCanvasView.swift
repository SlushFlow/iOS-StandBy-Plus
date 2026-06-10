import SwiftUI

struct WidgetCanvasView: View {
    @EnvironmentObject private var store: WidgetStore
    @EnvironmentObject private var theme: ThemeManager
    @Binding var editMode: Bool
    var onExpandMusic: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(store.items) { item in
                    WidgetContainer(
                        item: item,
                        canvasSize: geo.size,
                        editMode: $editMode,
                        onExpandMusic: onExpandMusic
                    )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private struct WidgetContainer: View {
    @EnvironmentObject private var store: WidgetStore
    @EnvironmentObject private var theme: ThemeManager
    let item: WidgetItem
    let canvasSize: CGSize
    @Binding var editMode: Bool
    var onExpandMusic: () -> Void

    @State private var dragTranslation: CGSize = .zero
    @State private var isDragging = false

    private var widgetSize: CGSize {
        switch item.size {
        case .medium:
            return CGSize(width: canvasSize.width * 0.45, height: canvasSize.height * 0.52)
        case .huge:
            return CGSize(width: canvasSize.width * 0.94, height: canvasSize.height * 0.92)
        }
    }

    private var center: CGPoint {
        let raw = CGPoint(
            x: CGFloat(item.x) * canvasSize.width + dragTranslation.width,
            y: CGFloat(item.y) * canvasSize.height + dragTranslation.height
        )
        return clamp(raw)
    }

    var body: some View {
        let palette = theme.palette

        content
            .frame(width: widgetSize.width, height: widgetSize.height)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(palette.widgetBackground.color)
                    .shadow(color: .black.opacity(theme.isNight ? 0.5 : 0.12), radius: isDragging ? 26 : 14, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(
                        editMode ? palette.accent.color.opacity(0.75) : palette.primaryText.color.opacity(0.05),
                        style: StrokeStyle(lineWidth: editMode ? 2 : 1, dash: editMode ? [7, 6] : [])
                    )
            )
            .overlay(alignment: .topTrailing) {
                if editMode {
                    editButton(symbol: "xmark", color: .red) {
                        store.remove(item)
                    }
                    .offset(x: 12, y: -12)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if editMode {
                    editButton(
                        symbol: item.size == .medium
                            ? "arrow.up.left.and.arrow.down.right"
                            : "arrow.down.right.and.arrow.up.left",
                        color: palette.accent.color
                    ) {
                        store.toggleSize(item)
                    }
                    .offset(x: 12, y: 12)
                }
            }
            .scaleEffect(isDragging ? 1.04 : (editMode ? 0.98 : 1.0))
            .position(center)
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: editMode)
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: item.size)
            .gesture(editMode ? dragGesture : nil)
            .onLongPressGesture(minimumDuration: 0.5) {
                if !editMode {
                    Haptics.rigid()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        editMode = true
                    }
                }
            }
            .zIndex(isDragging ? 10 : 0)
    }

    @ViewBuilder
    private var content: some View {
        switch item.kind {
        case .clock:
            ClockWidgetView()
        case .music:
            MusicWidgetView(isHuge: item.size == .huge, onExpand: onExpandMusic)
        case .calendar:
            CalendarWidgetView(isHuge: item.size == .huge)
        case .battery:
            BatteryWidgetView()
        }
    }

    private func editButton(symbol: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(color))
                .shadow(color: .black.opacity(0.3), radius: 5, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
        .transition(.scale.combined(with: .opacity))
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if !isDragging {
                    isDragging = true
                    store.bringToFront(item)
                    Haptics.tap()
                }
                dragTranslation = gesture.translation
            }
            .onEnded { _ in
                let final = center
                store.move(item, to: CGPoint(
                    x: final.x / canvasSize.width,
                    y: final.y / canvasSize.height
                ))
                dragTranslation = .zero
                isDragging = false
                Haptics.rigid()
            }
    }

    private func clamp(_ point: CGPoint) -> CGPoint {
        let halfWidth = widgetSize.width / 2
        let halfHeight = widgetSize.height / 2
        return CGPoint(
            x: min(max(point.x, halfWidth - 8), canvasSize.width - halfWidth + 8),
            y: min(max(point.y, halfHeight - 8), canvasSize.height - halfHeight + 8)
        )
    }
}
