import SwiftUI
import Combine

/// The single source of truth for everything the user can customise. It is a
/// `Codable` value snapshot wrapped in an `ObservableObject` that automatically
/// persists itself to `UserDefaults` whenever anything changes.
final class AppSettings: ObservableObject {

    // MARK: Persisted, user-facing settings

    @Published var dayPalette: ThemePalette
    @Published var nightPalette: ThemePalette

    @Published var clockStyle: ClockStyle
    @Published var fontStyle: ClockFontStyle
    @Published var use24Hour: Bool
    @Published var showSeconds: Bool

    @Published var widgets: [PlacedWidget]

    /// Automatically switch between day and night palettes based on the clock.
    @Published var autoDayNight: Bool
    @Published var nightStartHour: Int   // 0...23
    @Published var dayStartHour: Int     // 0...23
    /// Manual override when `autoDayNight` is off.
    @Published var manualNightMode: Bool

    /// Dim the whole surface at night to be gentle in a dark room.
    @Published var nightDimming: Double  // 0 (off) ... 0.7
    /// Subtle ambient motion behind the widgets.
    @Published var ambientAnimation: Bool
    /// Burn-in protection nudge (the StandBy "drift").
    @Published var screenBurnProtection: Bool
    /// Show the now-playing surface automatically when audio starts.
    @Published var autoShowMusic: Bool
    /// Pop the call HUD automatically when a call is detected.
    @Published var autoShowCalls: Bool
    /// Accent the seconds / progress with the palette accent color.
    @Published var accentHighlights: Bool

    // MARK: - Derived helpers

    /// Whether night styling should currently apply.
    func isNight(at date: Date = Date()) -> Bool {
        guard autoDayNight else { return manualNightMode }
        let hour = Calendar.current.component(.hour, from: date)
        if nightStartHour == dayStartHour { return false }
        if nightStartHour < dayStartHour {
            return hour >= nightStartHour && hour < dayStartHour
        } else {
            // Night wraps past midnight (e.g. 20:00 -> 07:00).
            return hour >= nightStartHour || hour < dayStartHour
        }
    }

    func palette(at date: Date = Date()) -> ThemePalette {
        isNight(at: date) ? nightPalette : dayPalette
    }

    func dimming(at date: Date = Date()) -> Double {
        isNight(at: date) ? nightDimming : 0
    }

    // MARK: - Persistence

    private static let storageKey = "StandByPlus.settings.v1"
    private var cancellable: AnyCancellable?

    init() {
        let stored = AppSettings.loadStored()
        dayPalette = stored?.dayPalette ?? .warmDay
        nightPalette = stored?.nightPalette ?? .cozyNight
        clockStyle = stored?.clockStyle ?? .digital
        fontStyle = stored?.fontStyle ?? .rounded
        use24Hour = stored?.use24Hour ?? false
        showSeconds = stored?.showSeconds ?? false
        widgets = stored?.widgets ?? PlacedWidget.defaultLayout()
        autoDayNight = stored?.autoDayNight ?? true
        nightStartHour = stored?.nightStartHour ?? 20
        dayStartHour = stored?.dayStartHour ?? 7
        manualNightMode = stored?.manualNightMode ?? true
        nightDimming = stored?.nightDimming ?? 0.25
        ambientAnimation = stored?.ambientAnimation ?? true
        screenBurnProtection = stored?.screenBurnProtection ?? true
        autoShowMusic = stored?.autoShowMusic ?? true
        autoShowCalls = stored?.autoShowCalls ?? true
        accentHighlights = stored?.accentHighlights ?? true

        // Persist whenever any published property changes (debounced).
        cancellable = objectWillChange
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] in self?.save() }
    }

    func resetToDefaults() {
        dayPalette = .warmDay
        nightPalette = .cozyNight
        clockStyle = .digital
        fontStyle = .rounded
        use24Hour = false
        showSeconds = false
        widgets = PlacedWidget.defaultLayout()
        autoDayNight = true
        nightStartHour = 20
        dayStartHour = 7
        manualNightMode = true
        nightDimming = 0.25
        ambientAnimation = true
        screenBurnProtection = true
        autoShowMusic = true
        autoShowCalls = true
        accentHighlights = true
    }

    // MARK: Codable snapshot

    private struct Snapshot: Codable {
        var dayPalette: ThemePalette
        var nightPalette: ThemePalette
        var clockStyle: ClockStyle
        var fontStyle: ClockFontStyle
        var use24Hour: Bool
        var showSeconds: Bool
        var widgets: [PlacedWidget]
        var autoDayNight: Bool
        var nightStartHour: Int
        var dayStartHour: Int
        var manualNightMode: Bool
        var nightDimming: Double
        var ambientAnimation: Bool
        var screenBurnProtection: Bool
        var autoShowMusic: Bool
        var autoShowCalls: Bool
        var accentHighlights: Bool
    }

    private func snapshot() -> Snapshot {
        Snapshot(
            dayPalette: dayPalette,
            nightPalette: nightPalette,
            clockStyle: clockStyle,
            fontStyle: fontStyle,
            use24Hour: use24Hour,
            showSeconds: showSeconds,
            widgets: widgets,
            autoDayNight: autoDayNight,
            nightStartHour: nightStartHour,
            dayStartHour: dayStartHour,
            manualNightMode: manualNightMode,
            nightDimming: nightDimming,
            ambientAnimation: ambientAnimation,
            screenBurnProtection: screenBurnProtection,
            autoShowMusic: autoShowMusic,
            autoShowCalls: autoShowCalls,
            accentHighlights: accentHighlights
        )
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(snapshot()) else { return }
        UserDefaults.standard.set(data, forKey: AppSettings.storageKey)
    }

    private static func loadStored() -> Snapshot? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }
}
