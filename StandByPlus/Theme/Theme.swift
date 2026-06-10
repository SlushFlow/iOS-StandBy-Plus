import SwiftUI

/// One full set of colors for either day or night.
struct Palette: Codable, Equatable {
    var background: CodableColor
    var widgetBackground: CodableColor
    var primaryText: CodableColor
    var secondaryText: CodableColor
    var accent: CodableColor
    /// Extra dimming layered on top of everything (0 = none, 1 = black).
    var dim: Double

    static let cozyDay = Palette(
        background: .hex(0xF4EFE8),
        widgetBackground: .hex(0xFFFFFF, alpha: 0.82),
        primaryText: .hex(0x2B2622),
        secondaryText: .hex(0x8A8077),
        accent: .hex(0xE08A3C),
        dim: 0
    )

    static let cozyNight = Palette(
        background: .hex(0x0B0B0F),
        widgetBackground: .hex(0x17171D, alpha: 0.92),
        primaryText: .hex(0xF2E3C9),
        secondaryText: .hex(0x8B8170),
        accent: .hex(0xE8A04C),
        dim: 0.12
    )

    static let paperDay = Palette(
        background: .hex(0xFDFBF7),
        widgetBackground: .hex(0xF1EBE1, alpha: 0.95),
        primaryText: .hex(0x3A3530),
        secondaryText: .hex(0x9A9288),
        accent: .hex(0x4C7A6B),
        dim: 0
    )

    static let midnightTeal = Palette(
        background: .hex(0x06090C),
        widgetBackground: .hex(0x0E1519, alpha: 0.94),
        primaryText: .hex(0xC9EDE4),
        secondaryText: .hex(0x5E7A74),
        accent: .hex(0x35C4A2),
        dim: 0.1
    )

    static let lavenderDay = Palette(
        background: .hex(0xF2EFF8),
        widgetBackground: .hex(0xFFFFFF, alpha: 0.85),
        primaryText: .hex(0x322D40),
        secondaryText: .hex(0x8D86A3),
        accent: .hex(0x8A6FE8),
        dim: 0
    )

    static let lavenderNight = Palette(
        background: .hex(0x0B0A12),
        widgetBackground: .hex(0x16141F, alpha: 0.92),
        primaryText: .hex(0xE2DBFA),
        secondaryText: .hex(0x6F6790),
        accent: .hex(0x9D7FFF),
        dim: 0.1
    )

    static let emberNight = Palette(
        background: .hex(0x0D0808),
        widgetBackground: .hex(0x1A1110, alpha: 0.92),
        primaryText: .hex(0xFFD9C2),
        secondaryText: .hex(0x8F6F5E),
        accent: .hex(0xFF7A45),
        dim: 0.14
    )
}

struct ThemePreset: Identifiable {
    let id: String
    let name: String
    let day: Palette
    let night: Palette

    static let all: [ThemePreset] = [
        ThemePreset(id: "cozy", name: "Cozy Amber", day: .cozyDay, night: .cozyNight),
        ThemePreset(id: "teal", name: "Midnight Teal", day: .paperDay, night: .midnightTeal),
        ThemePreset(id: "lavender", name: "Lavender", day: .lavenderDay, night: .lavenderNight),
        ThemePreset(id: "ember", name: "Ember", day: .cozyDay, night: .emberNight)
    ]
}

enum ThemeMode: String, Codable, CaseIterable, Identifiable {
    case auto
    case day
    case night

    var id: String { rawValue }

    var label: String {
        switch self {
        case .auto: return "Automatic"
        case .day: return "Always Day"
        case .night: return "Always Night"
        }
    }

    var symbol: String {
        switch self {
        case .auto: return "circle.lefthalf.filled"
        case .day: return "sun.max.fill"
        case .night: return "moon.fill"
        }
    }
}
