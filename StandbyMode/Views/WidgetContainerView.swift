import SwiftUI

struct WidgetContainerView: View {
    let widget: StandbyWidget
    let screenSize: CGSize

    @EnvironmentObject var widgetManager: WidgetManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    private var widgetPixelSize: CGSize {
        let unitW = screenSize.width / 6
        let unitH = screenSize.height / 5
        return CGSize(
            width: widget.size.gridSize.width * unitW,
            height: widget.size.gridSize.height * unitH
        )
    }

    var body: some View {
        ZStack {
            widgetContent
                .frame(width: widgetPixelSize.width, height: widgetPixelSize.height)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(themeManager.colors.surface.opacity(0.85))
                        .shadow(color: themeManager.colors.primary.opacity(0.1), radius: 16, y: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            widgetManager.isEditing && widgetManager.selectedWidgetId == widget.id
                                ? themeManager.colors.accent
                                : Color.clear,
                            lineWidth: 2
                        )
                )
                .overlay(editOverlay)
                .scaleEffect(isDragging ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
        }
        .position(
            x: widget.position.x + dragOffset.width,
            y: widget.position.y + dragOffset.height
        )
        .gesture(dragGesture)
        .onTapGesture {
            if widgetManager.isEditing {
                withAnimation(.easeInOut(duration: 0.2)) {
                    widgetManager.selectedWidgetId = widget.id
                    widgetManager.bringToFront(id: widget.id)
                }
            }
        }
    }

    @ViewBuilder
    private var widgetContent: some View {
        switch widget.type {
        case .clock:
            ClockWidgetView(size: widget.size)
        case .music:
            MusicWidgetView(size: widget.size)
        case .calendar:
            CalendarWidgetView(size: widget.size)
        case .weather:
            WeatherWidgetView(size: widget.size)
        case .battery:
            BatteryWidgetView(size: widget.size)
        case .photo:
            PhotoWidgetView(size: widget.size)
        }
    }

    @ViewBuilder
    private var editOverlay: some View {
        if widgetManager.isEditing {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            widgetManager.removeWidget(id: widget.id)
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.red)
                            .background(Circle().fill(.white).padding(4))
                    }
                    .offset(x: 8, y: -8)
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            let newSize: WidgetSize = widget.size == .medium ? .huge : .medium
                            widgetManager.updateSize(id: widget.id, size: newSize)
                        }
                    }) {
                        Image(systemName: widget.size == .medium ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.colors.textPrimary)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(themeManager.colors.surface)
                                    .shadow(color: .black.opacity(0.2), radius: 4)
                            )
                    }
                    .offset(x: 8, y: 8)
                }
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard widgetManager.isEditing else { return }
                isDragging = true
                dragOffset = value.translation
            }
            .onEnded { value in
                guard widgetManager.isEditing else { return }
                isDragging = false
                let newPosition = CGPoint(
                    x: widget.position.x + value.translation.width,
                    y: widget.position.y + value.translation.height
                )
                let clamped = CGPoint(
                    x: max(widgetPixelSize.width / 2, min(screenSize.width - widgetPixelSize.width / 2, newPosition.x)),
                    y: max(widgetPixelSize.height / 2, min(screenSize.height - widgetPixelSize.height / 2, newPosition.y))
                )
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    widgetManager.updatePosition(id: widget.id, position: clamped)
                    dragOffset = .zero
                }
            }
    }
}
