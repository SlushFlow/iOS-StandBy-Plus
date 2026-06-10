import SwiftUI
import UIKit

/// A Codable, Equatable RGBA color that bridges to SwiftUI's `Color`.
struct CodableColor: Codable, Equatable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(_ color: Color) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }

    /// Creates a color from a 0xRRGGBB hex value.
    static func hex(_ value: UInt32, alpha: Double = 1.0) -> CodableColor {
        CodableColor(
            red: Double((value >> 16) & 0xFF) / 255.0,
            green: Double((value >> 8) & 0xFF) / 255.0,
            blue: Double(value & 0xFF) / 255.0,
            alpha: alpha
        )
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// A perceived-luminance check used to pick contrasting content.
    var isBright: Bool {
        (0.299 * red + 0.587 * green + 0.114 * blue) > 0.6
    }
}

extension Binding where Value == CodableColor {
    /// Bridges a `CodableColor` binding to a `Color` binding for `ColorPicker`.
    var asColor: Binding<Color> {
        Binding<Color>(
            get: { wrappedValue.color },
            set: { wrappedValue = CodableColor($0) }
        )
    }
}
