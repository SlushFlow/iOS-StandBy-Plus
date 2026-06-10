import SwiftUI
import UIKit

/// Maps a `WidgetKind` to its concrete view, sized to fill its window.
struct WidgetRenderer: View {
    let widget: PlacedWidget
    @Environment(\.palette) private var palette

    var body: some View {
        switch widget.kind {
        case .clock:      ClockWidgetView()
        case .date:       DateWidget()
        case .calendar:   CalendarWidget()
        case .weather:    WeatherWidget()
        case .battery:    BatteryWidget()
        case .music:      MusicMiniWidget()
        case .quote:      QuoteWidget()
        case .worldClock: WorldClockWidget()
        }
    }
}

// MARK: - Date

struct DateWidget: View {
    @Environment(\.palette) private var palette
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { ctx in
            let date = ctx.date
            VStack(alignment: .leading, spacing: 2) {
                Text(date.formatted(.dateTime.weekday(.wide)).uppercased())
                    .font(.system(size: 22, weight: .heavy, design: settings.fontStyle.design))
                    .foregroundStyle(settings.accentHighlights ? palette.accent.color : palette.secondaryText.color)
                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 86, weight: .bold, design: settings.fontStyle.design))
                    .foregroundStyle(palette.primaryText.color)
                    .minimumScaleFactor(0.4)
                Text(date.formatted(.dateTime.month(.wide)))
                    .font(.system(size: 22, weight: .semibold, design: settings.fontStyle.design))
                    .foregroundStyle(palette.secondaryText.color)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Calendar

struct CalendarWidget: View {
    @Environment(\.palette) private var palette
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        let cal = Calendar.current
        let today = Date()
        let day = cal.component(.day, from: today)
        let range = cal.range(of: .day, in: .month, for: today) ?? 1..<29
        let firstWeekday = (cal.component(.weekday, from: today.startOfMonth) - 1)

        VStack(alignment: .leading, spacing: 8) {
            Text(today.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(palette.primaryText.color)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<firstWeekday, id: \.self) { _ in Color.clear.frame(height: 18) }
                ForEach(range, id: \.self) { d in
                    Text("\(d)")
                        .font(.system(size: 12, weight: d == day ? .bold : .regular, design: .rounded))
                        .foregroundStyle(d == day ? palette.background.color : palette.secondaryText.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: 18)
                        .background {
                            if d == day {
                                Circle().fill(palette.accent.color)
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Weather (stylised mock)

struct WeatherWidget: View {
    @Environment(\.palette) private var palette
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "cloud.moon.fill")
                    .font(.system(size: 30))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(palette.primaryText.color, palette.accent.color)
                Spacer()
                Text("18°")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText.color)
            }
            Text("Mostly Clear")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.secondaryText.color)
            HStack(spacing: 12) {
                Label("H 21°", systemImage: "arrow.up")
                Label("L 12°", systemImage: "arrow.down")
            }
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(palette.secondaryText.color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Battery

struct BatteryWidget: View {
    @Environment(\.palette) private var palette
    @State private var level: Double = 1
    @State private var charging = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: charging ? "bolt.fill" : "battery.100")
                .font(.system(size: 26))
                .foregroundStyle(palette.accent.color)
            Text("\(Int(level * 100))%")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(palette.primaryText.color)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(palette.primaryText.with(opacity: 0.12).color)
                    Capsule().fill(palette.accent.color)
                        .frame(width: geo.size.width * level)
                }
            }
            .frame(height: 8)
            Text(charging ? "Charging" : "On Battery")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(palette.secondaryText.color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear(perform: refresh)
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in refresh() }
    }

    private func refresh() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let lvl = UIDevice.current.batteryLevel
        level = lvl < 0 ? 1 : Double(lvl)
        let state = UIDevice.current.batteryState
        charging = (state == .charging || state == .full)
    }
}

// MARK: - Quote

struct QuoteWidget: View {
    @Environment(\.palette) private var palette
    private static let quotes = [
        "Stay soft. The world is loud enough.",
        "Slow is smooth, smooth is fast.",
        "Make something quiet and good.",
        "Rest is part of the work.",
        "Small steps, warm light."
    ]
    var body: some View {
        let quote = QuoteWidget.quotes[Calendar.current.component(.day, from: Date()) % QuoteWidget.quotes.count]
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "quote.opening")
                .font(.system(size: 22))
                .foregroundStyle(palette.accent.color)
            Text(quote)
                .font(.system(size: 19, weight: .semibold, design: .serif))
                .foregroundStyle(palette.primaryText.color)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - World Clock

struct WorldClockWidget: View {
    @Environment(\.palette) private var palette
    private let zones: [(String, String)] = [
        ("Tokyo", "Asia/Tokyo"),
        ("London", "Europe/London"),
        ("New York", "America/New_York")
    ]
    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { ctx in
            VStack(alignment: .leading, spacing: 10) {
                ForEach(zones, id: \.0) { name, id in
                    HStack {
                        Text(name)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.secondaryText.color)
                        Spacer()
                        Text(time(ctx.date, zone: id))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(palette.primaryText.color)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func time(_ date: Date, zone: String) -> String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: zone)
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}

// MARK: - Music mini

struct MusicMiniWidget: View {
    @Environment(\.palette) private var palette
    @EnvironmentObject private var nowPlaying: NowPlayingManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Artwork(image: nowPlaying.track?.artwork, size: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(nowPlaying.track?.title ?? "Not Playing")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.primaryText.color)
                        .lineLimit(1)
                    Text(nowPlaying.track?.artist ?? "—")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.secondaryText.color)
                        .lineLimit(1)
                }
            }
            HStack(spacing: 22) {
                Spacer()
                Button { nowPlaying.previous() } label: {
                    Image(systemName: "backward.fill")
                }
                Button { nowPlaying.togglePlayPause() } label: {
                    Image(systemName: nowPlaying.isPlaying ? "pause.fill" : "play.fill")
                }
                Button { nowPlaying.next() } label: {
                    Image(systemName: "forward.fill")
                }
                Spacer()
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(palette.primaryText.color)
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// Shared artwork view with a graceful placeholder.
struct Artwork: View {
    @Environment(\.palette) private var palette
    var image: UIImage?
    var size: CGFloat
    var corner: CGFloat = 10

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [palette.accent.with(opacity: 0.7).color,
                                            palette.accent.with(opacity: 0.25).color],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "music.note")
                        .font(.system(size: size * 0.4, weight: .bold))
                        .foregroundStyle(palette.background.color.opacity(0.8))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }
}

private extension Date {
    var startOfMonth: Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: self)) ?? self
    }
}
