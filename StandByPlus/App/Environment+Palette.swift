import SwiftUI

/// Makes the currently-active palette available to any view via the environment,
/// so widgets don't each have to recompute day/night state.
private struct PaletteKey: EnvironmentKey {
    static let defaultValue = ThemePalette.cozyNight
}

extension EnvironmentValues {
    var palette: ThemePalette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}
