import SwiftUI

/// A full set of colors that drives the look of the whole StandBy surface for a
/// single mode (day or night). Every color is user-customisable.
struct ThemePalette: Codable, Equatable {
    var background: RGBAColor
    var backgroundSecondary: RGBAColor
    var surface: RGBAColor
    var primaryText: RGBAColor
    var secondaryText: RGBAColor
    var accent: RGBAColor

    /// The gradient painted behind everything.
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [background.color, backgroundSecondary.color],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: Built-in presets

    /// "Cozy" night palette — deep indigo instead of the stock creepy red.
    static let cozyNight = ThemePalette(
        background: RGBAColor(hex: 0x0B0D1A),
        backgroundSecondary: RGBAColor(hex: 0x141021),
        surface: RGBAColor(hex: 0xFFFFFF, opacity: 0.06),
        primaryText: RGBAColor(hex: 0xF3EFFF),
        secondaryText: RGBAColor(hex: 0x9C97C7),
        accent: RGBAColor(hex: 0x8AB7E6)
    )

    /// Soft, warm light palette for daytime desks.
    static let warmDay = ThemePalette(
        background: RGBAColor(hex: 0xF6F1E7),
        backgroundSecondary: RGBAColor(hex: 0xEADFce),
        surface: RGBAColor(hex: 0x000000, opacity: 0.05),
        primaryText: RGBAColor(hex: 0x2C2A26),
        secondaryText: RGBAColor(hex: 0x7A766D),
        accent: RGBAColor(hex: 0xC2742B)
    )

    static let presets: [(name: String, palette: ThemePalette)] = [
        ("Cozy Night", .cozyNight),
        ("Midnight Ocean", ThemePalette(
            background: RGBAColor(hex: 0x021019),
            backgroundSecondary: RGBAColor(hex: 0x06283D),
            surface: RGBAColor(hex: 0xFFFFFF, opacity: 0.07),
            primaryText: RGBAColor(hex: 0xEAF6FF),
            secondaryText: RGBAColor(hex: 0x7FB6D6),
            accent: RGBAColor(hex: 0x49C6E5))),
        ("Forest", ThemePalette(
            background: RGBAColor(hex: 0x081410),
            backgroundSecondary: RGBAColor(hex: 0x10261C),
            surface: RGBAColor(hex: 0xFFFFFF, opacity: 0.06),
            primaryText: RGBAColor(hex: 0xEAF7EE),
            secondaryText: RGBAColor(hex: 0x84B79A),
            accent: RGBAColor(hex: 0x66D19E))),
        ("Sunset", ThemePalette(
            background: RGBAColor(hex: 0x1A0A12),
            backgroundSecondary: RGBAColor(hex: 0x2C0F1A),
            surface: RGBAColor(hex: 0xFFFFFF, opacity: 0.06),
            primaryText: RGBAColor(hex: 0xFFEEF2),
            secondaryText: RGBAColor(hex: 0xCE8AA0),
            accent: RGBAColor(hex: 0xFF6F91))),
        ("Warm Day", .warmDay),
        ("Paper", ThemePalette(
            background: RGBAColor(hex: 0xFFFFFF),
            backgroundSecondary: RGBAColor(hex: 0xEFEFF4),
            surface: RGBAColor(hex: 0x000000, opacity: 0.04),
            primaryText: RGBAColor(hex: 0x1C1C1E),
            secondaryText: RGBAColor(hex: 0x8E8E93),
            accent: RGBAColor(hex: 0x0A84FF)))
    ]
}
