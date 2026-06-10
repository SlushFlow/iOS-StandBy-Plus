import SwiftUI

struct WidgetCanvasView: View {
    @EnvironmentObject private var settings: StandBySettings

    let containerSize: CGSize

    private let columns = 8
    private let rows = 4
    private let spacing: CGFloat = 14

    var body: some View {
        let cellWidth = (containerSize.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        let cellHeight = (containerSize.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)

        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )

            ForEach(settings.widgets.filter(\.isVisible)) { widget in
                let span = widget.size.gridSpan
                let width = cellWidth * CGFloat(span.columns) + spacing * CGFloat(span.columns - 1)
                let height = cellHeight * CGFloat(span.rows) + spacing * CGFloat(span.rows - 1)
                let x = CGFloat(widget.column) * (cellWidth + spacing) + 12
                let y = CGFloat(widget.row) * (cellHeight + spacing) + 12

                WidgetWindowView(widget: widget)
                    .frame(width: width, height: height)
                    .offset(x: x, y: y)
                    .animation(
                        SmoothAnimation.spring(reduceMotion: settings.reduceMotion),
                        value: widget.column
                    )
                    .animation(
                        SmoothAnimation.spring(reduceMotion: settings.reduceMotion),
                        value: widget.size
                    )
            }
        }
        .frame(width: containerSize.width, height: containerSize.height)
    }
}

struct WidgetWindowView: View {
    @EnvironmentObject private var settings: StandBySettings
    @EnvironmentObject private var musicService: MusicService

    let widget: WidgetWindow

    var body: some View {
        Group {
            switch widget.type {
            case .clock:
                ClockWidgetView()
            case .music:
                MusicPlayerView(compact: widget.size == .medium)
            case .calls:
                CallWidgetPlaceholder()
            case .calendar:
                CalendarWidgetView()
            case .weather:
                WeatherWidgetView()
            case .photo:
                PhotoWidgetView()
            case .notes:
                NotesWidgetView()
            }
        }
        .cozyCard()
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct CallWidgetPlaceholder: View {
    @Environment(\.themePalette) private var palette
    @EnvironmentObject private var callService: CallService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Calls", systemImage: "phone.fill")
                .font(.headline)
                .foregroundStyle(palette.textPrimary.color)

            if let call = callService.activeCall, call.isActiveSession {
                HStack(spacing: 12) {
                    Image(systemName: call.source.systemImage)
                        .font(.title2)
                        .foregroundStyle(palette.accent.color)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(call.callerName)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(palette.textPrimary.color)
                        Text(call.statusText)
                            .font(.subheadline)
                            .foregroundStyle(palette.textSecondary.color)
                    }
                }
            } else {
                Text("No active calls")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(palette.textSecondary.color)
                Text("CallKit-enabled apps appear here")
                    .font(.caption)
                    .foregroundStyle(palette.textSecondary.color.opacity(0.8))
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct CalendarWidgetView: View {
    @Environment(\.themePalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Today", systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(palette.textPrimary.color)

            Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.title3.weight(.semibold))
                .foregroundStyle(palette.textPrimary.color)

            Text("Your calendar widgets can be expanded in a future update.")
                .font(.caption)
                .foregroundStyle(palette.textSecondary.color)

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct WeatherWidgetView: View {
    @Environment(\.themePalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Weather", systemImage: "cloud.sun.fill")
                .font(.headline)
                .foregroundStyle(palette.textPrimary.color)

            Text("72°")
                .font(.system(size: 44, weight: .light, design: .rounded))
                .foregroundStyle(palette.textPrimary.color)

            Text("Clear · Cozy workspace")
                .font(.subheadline)
                .foregroundStyle(palette.textSecondary.color)

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct PhotoWidgetView: View {
    @Environment(\.themePalette) private var palette

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    palette.accent.color.opacity(0.35),
                    palette.surface.color
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.largeTitle)
                    .foregroundStyle(palette.textPrimary.color.opacity(0.8))
                Text("Photo Frame")
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary.color)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NotesWidgetView: View {
    @Environment(\.themePalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)
                .foregroundStyle(palette.textPrimary.color)

            Text("Pin a thought for your desk.")
                .font(.title3.weight(.medium))
                .foregroundStyle(palette.textSecondary.color)

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
