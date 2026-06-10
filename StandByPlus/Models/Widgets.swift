import SwiftUI

/// The kinds of widgets that can be dropped onto the StandBy canvas.
enum WidgetKind: String, Codable, CaseIterable, Identifiable {
    case clock
    case date
    case calendar
    case weather
    case battery
    case music
    case quote
    case worldClock

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clock: return "Clock"
        case .date: return "Date"
        case .calendar: return "Calendar"
        case .weather: return "Weather"
        case .battery: return "Battery"
        case .music: return "Music"
        case .quote: return "Quote"
        case .worldClock: return "World Clock"
        }
    }

    var systemImage: String {
        switch self {
        case .clock: return "clock"
        case .date: return "calendar.day.timeline.left"
        case .calendar: return "calendar"
        case .weather: return "cloud.sun.fill"
        case .battery: return "battery.75"
        case .music: return "music.note"
        case .quote: return "quote.bubble.fill"
        case .worldClock: return "globe"
        }
    }
}

/// Widgets snap to one of two sizes — like resizable windows rather than the
/// fixed OS grid. "Medium" is roughly a 2x2 home-screen widget; "Huge" spans a
/// large region of the canvas.
enum WidgetSize: String, Codable, CaseIterable, Identifiable {
    case medium
    case huge

    var id: String { rawValue }

    var title: String { self == .medium ? "Medium" : "Huge" }

    /// Normalized footprint (fraction of the available canvas) for each size.
    var normalizedSize: CGSize {
        switch self {
        case .medium: return CGSize(width: 0.30, height: 0.42)
        case .huge: return CGSize(width: 0.52, height: 0.72)
        }
    }
}

/// A widget that has been freely placed on the canvas. Position is stored as a
/// normalized center point so layouts survive rotation and different devices.
struct PlacedWidget: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var kind: WidgetKind
    var size: WidgetSize = .medium
    /// Normalized center, 0...1 in both axes.
    var centerX: Double = 0.5
    var centerY: Double = 0.5

    static func defaultLayout() -> [PlacedWidget] {
        [
            PlacedWidget(kind: .clock, size: .huge, centerX: 0.30, centerY: 0.5),
            PlacedWidget(kind: .calendar, size: .medium, centerX: 0.74, centerY: 0.30),
            PlacedWidget(kind: .weather, size: .medium, centerX: 0.74, centerY: 0.74)
        ]
    }
}
