import SwiftUI
import UIKit

/// A `Codable`, value-type color so the user's custom palettes can be persisted
/// to `UserDefaults`. SwiftUI's `Color` is not directly `Codable`, so we store
/// raw sRGB components instead.
struct RGBAColor: Codable, Equatable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    init(_ color: Color) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }

    /// Convenience for hex literals such as `0x1A1B22`.
    init(hex: UInt32, opacity: Double = 1) {
        self.red = Double((hex >> 16) & 0xFF) / 255.0
        self.green = Double((hex >> 8) & 0xFF) / 255.0
        self.blue = Double(hex & 0xFF) / 255.0
        self.opacity = opacity
    }

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    /// A perceptual brightness estimate, used to pick contrasting overlays.
    var luminance: Double {
        0.2126 * red + 0.7152 * green + 0.0722 * blue
    }

    func with(opacity newOpacity: Double) -> RGBAColor {
        RGBAColor(red: red, green: green, blue: blue, opacity: newOpacity)
    }
}

extension Color {
    /// Two-way binding helper for SwiftUI's `ColorPicker`.
    var rgba: RGBAColor { RGBAColor(self) }
}
