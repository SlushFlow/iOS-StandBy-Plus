import SwiftUI

/// Selectable clock faces for the main clock widget.
enum ClockStyle: String, Codable, CaseIterable, Identifiable {
    case digital
    case flip
    case analog
    case minimal
    case stacked

    var id: String { rawValue }

    var title: String {
        switch self {
        case .digital: return "Digital"
        case .flip: return "Flip"
        case .analog: return "Analog"
        case .minimal: return "Minimal"
        case .stacked: return "Stacked"
        }
    }

    var systemImage: String {
        switch self {
        case .digital: return "7.square"
        case .flip: return "rectangle.split.2x1"
        case .analog: return "clock"
        case .minimal: return "minus"
        case .stacked: return "square.stack"
        }
    }
}

/// Font personality applied to the clock and headings.
enum ClockFontStyle: String, Codable, CaseIterable, Identifiable {
    case rounded
    case standard
    case serif
    case monospaced

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var design: Font.Design {
        switch self {
        case .rounded: return .rounded
        case .standard: return .default
        case .serif: return .serif
        case .monospaced: return .monospaced
        }
    }
}
