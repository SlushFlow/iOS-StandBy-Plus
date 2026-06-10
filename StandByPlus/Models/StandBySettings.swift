import SwiftUI

enum AppearanceMode: String, CaseIterable, Codable, Identifiable {
    case system
    case dark
    case light

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
}

enum WidgetSize: String, CaseIterable, Codable, Identifiable {
    case medium
    case huge

    var id: String { rawValue }

    var label: String {
        switch self {
        case .medium: return "Medium"
        case .huge: return "Huge"
        }
    }

    var gridSpan: (columns: Int, rows: Int) {
        switch self {
        case .medium: return (2, 2)
        case .huge: return (4, 3)
        }
    }
}

enum WidgetType: String, CaseIterable, Codable, Identifiable {
    case clock
    case music
    case calls
    case calendar
    case weather
    case photo
    case notes

    var id: String { rawValue }

    var label: String {
        switch self {
        case .clock: return "Clock"
        case .music: return "Music"
        case .calls: return "Calls"
        case .calendar: return "Calendar"
        case .weather: return "Weather"
        case .photo: return "Photo"
        case .notes: return "Notes"
        }
    }

    var systemImage: String {
        switch self {
        case .clock: return "clock.fill"
        case .music: return "music.note"
        case .calls: return "phone.fill"
        case .calendar: return "calendar"
        case .weather: return "cloud.sun.fill"
        case .photo: return "photo.fill"
        case .notes: return "note.text"
        }
    }
}

struct WidgetWindow: Identifiable, Codable, Equatable {
    var id: UUID
    var type: WidgetType
    var size: WidgetSize
    var column: Int
    var row: Int
    var isVisible: Bool

    init(
        id: UUID = UUID(),
        type: WidgetType,
        size: WidgetSize = .medium,
        column: Int = 0,
        row: Int = 0,
        isVisible: Bool = true
    ) {
        self.id = id
        self.type = type
        self.size = size
        self.column = column
        self.row = row
        self.isVisible = isVisible
    }
}

enum ClockStyle: String, CaseIterable, Codable, Identifiable {
    case digital
    case analog
    case minimal
    case flip

    var id: String { rawValue }

    var label: String {
        switch self {
        case .digital: return "Digital"
        case .analog: return "Analog"
        case .minimal: return "Minimal"
        case .flip: return "Flip"
        }
    }
}

enum ClockFontWeight: String, CaseIterable, Codable, Identifiable {
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy

    var id: String { rawValue }

    var fontWeight: Font.Weight {
        switch self {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        }
    }
}

struct ThemePalette: Codable, Equatable {
    var background: CodableColor
    var surface: CodableColor
    var accent: CodableColor
    var textPrimary: CodableColor
    var textSecondary: CodableColor
    var glow: CodableColor

    static let cozyDark = ThemePalette(
        background: CodableColor(red: 0.06, green: 0.07, blue: 0.10),
        surface: CodableColor(red: 0.11, green: 0.12, blue: 0.16),
        accent: CodableColor(red: 0.45, green: 0.72, blue: 0.95),
        textPrimary: CodableColor(red: 0.94, green: 0.95, blue: 0.97),
        textSecondary: CodableColor(red: 0.62, green: 0.66, blue: 0.72),
        glow: CodableColor(red: 0.35, green: 0.55, blue: 0.85, opacity: 0.35)
    )

    static let cozyLight = ThemePalette(
        background: CodableColor(red: 0.96, green: 0.95, blue: 0.93),
        surface: CodableColor(red: 1.0, green: 0.99, blue: 0.97),
        accent: CodableColor(red: 0.28, green: 0.48, blue: 0.72),
        textPrimary: CodableColor(red: 0.12, green: 0.13, blue: 0.16),
        textSecondary: CodableColor(red: 0.42, green: 0.45, blue: 0.50),
        glow: CodableColor(red: 0.55, green: 0.72, blue: 0.90, opacity: 0.25)
    )

    static let midnight = ThemePalette(
        background: CodableColor(red: 0.04, green: 0.05, blue: 0.12),
        surface: CodableColor(red: 0.08, green: 0.09, blue: 0.18),
        accent: CodableColor(red: 0.58, green: 0.45, blue: 0.95),
        textPrimary: CodableColor(red: 0.95, green: 0.94, blue: 1.0),
        textSecondary: CodableColor(red: 0.65, green: 0.64, blue: 0.75),
        glow: CodableColor(red: 0.45, green: 0.35, blue: 0.85, opacity: 0.4)
    )

    static let warmSunrise = ThemePalette(
        background: CodableColor(red: 0.98, green: 0.94, blue: 0.88),
        surface: CodableColor(red: 1.0, green: 0.97, blue: 0.92),
        accent: CodableColor(red: 0.85, green: 0.45, blue: 0.32),
        textPrimary: CodableColor(red: 0.18, green: 0.14, blue: 0.12),
        textSecondary: CodableColor(red: 0.48, green: 0.42, blue: 0.38),
        glow: CodableColor(red: 0.95, green: 0.65, blue: 0.35, opacity: 0.3)
    )
}

struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

@MainActor
final class StandBySettings: ObservableObject {
    private enum StorageKey {
        static let appearanceMode = "appearanceMode"
        static let dayPalette = "dayPalette"
        static let nightPalette = "nightPalette"
        static let useAutoDayNight = "useAutoDayNight"
        static let clockStyle = "clockStyle"
        static let clockFontWeight = "clockFontWeight"
        static let showSeconds = "showSeconds"
        static let use24Hour = "use24Hour"
        static let widgets = "widgets"
        static let showCallHUD = "showCallHUD"
        static let showMusicWhenPlaying = "showMusicWhenPlaying"
        static let reduceMotion = "reduceMotion"
    }

    @Published var appearanceMode: AppearanceMode {
        didSet { persist() }
    }

    @Published var dayPalette: ThemePalette {
        didSet { persist() }
    }

    @Published var nightPalette: ThemePalette {
        didSet { persist() }
    }

    @Published var useAutoDayNight: Bool {
        didSet { persist() }
    }

    @Published var clockStyle: ClockStyle {
        didSet { persist() }
    }

    @Published var clockFontWeight: ClockFontWeight {
        didSet { persist() }
    }

    @Published var showSeconds: Bool {
        didSet { persist() }
    }

    @Published var use24Hour: Bool {
        didSet { persist() }
    }

    @Published var widgets: [WidgetWindow] {
        didSet { persist() }
    }

    @Published var showCallHUD: Bool {
        didSet { persist() }
    }

    @Published var showMusicWhenPlaying: Bool {
        didSet { persist() }
    }

    @Published var reduceMotion: Bool {
        didSet { persist() }
    }

    @Published private(set) var isNightMode: Bool = true

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var dayNightTimer: Timer?

    init() {
        appearanceMode = AppearanceMode(rawValue: defaults.string(forKey: StorageKey.appearanceMode) ?? "") ?? .dark
        dayPalette = Self.loadPalette(forKey: StorageKey.dayPalette) ?? .cozyLight
        nightPalette = Self.loadPalette(forKey: StorageKey.nightPalette) ?? .cozyDark
        useAutoDayNight = defaults.object(forKey: StorageKey.useAutoDayNight) as? Bool ?? true
        clockStyle = ClockStyle(rawValue: defaults.string(forKey: StorageKey.clockStyle) ?? "") ?? .digital
        clockFontWeight = ClockFontWeight(rawValue: defaults.string(forKey: StorageKey.clockFontWeight) ?? "") ?? .light
        showSeconds = defaults.object(forKey: StorageKey.showSeconds) as? Bool ?? true
        use24Hour = defaults.object(forKey: StorageKey.use24Hour) as? Bool ?? true
        widgets = Self.loadWidgets() ?? Self.defaultWidgets()
        showCallHUD = defaults.object(forKey: StorageKey.showCallHUD) as? Bool ?? true
        showMusicWhenPlaying = defaults.object(forKey: StorageKey.showMusicWhenPlaying) as? Bool ?? true
        reduceMotion = defaults.object(forKey: StorageKey.reduceMotion) as? Bool ?? false

        refreshDayNight()
        startDayNightTimer()
    }

    var resolvedColorScheme: ColorScheme? {
        switch appearanceMode {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }

    var activePalette: ThemePalette {
        if useAutoDayNight {
            return isNightMode ? nightPalette : dayPalette
        }
        switch appearanceMode {
        case .light: return dayPalette
        case .dark: return nightPalette
        case .system: return isNightMode ? nightPalette : dayPalette
        }
    }

    func refreshDayNight() {
        let hour = Calendar.current.component(.hour, from: Date())
        isNightMode = hour < 7 || hour >= 19
    }

    func resetWidgetsToDefault() {
        widgets = Self.defaultWidgets()
    }

    func moveWidget(_ widget: WidgetWindow, toColumn column: Int, toRow row: Int) {
        guard let index = widgets.firstIndex(where: { $0.id == widget.id }) else { return }
        widgets[index].column = max(0, column)
        widgets[index].row = max(0, row)
    }

    func resizeWidget(_ widget: WidgetWindow, to size: WidgetSize) {
        guard let index = widgets.firstIndex(where: { $0.id == widget.id }) else { return }
        widgets[index].size = size
    }

    private func startDayNightTimer() {
        dayNightTimer?.invalidate()
        dayNightTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshDayNight()
            }
        }
    }

    private func persist() {
        defaults.set(appearanceMode.rawValue, forKey: StorageKey.appearanceMode)
        savePalette(dayPalette, forKey: StorageKey.dayPalette)
        savePalette(nightPalette, forKey: StorageKey.nightPalette)
        defaults.set(useAutoDayNight, forKey: StorageKey.useAutoDayNight)
        defaults.set(clockStyle.rawValue, forKey: StorageKey.clockStyle)
        defaults.set(clockFontWeight.rawValue, forKey: StorageKey.clockFontWeight)
        defaults.set(showSeconds, forKey: StorageKey.showSeconds)
        defaults.set(use24Hour, forKey: StorageKey.use24Hour)
        defaults.set(showCallHUD, forKey: StorageKey.showCallHUD)
        defaults.set(showMusicWhenPlaying, forKey: StorageKey.showMusicWhenPlaying)
        defaults.set(reduceMotion, forKey: StorageKey.reduceMotion)

        if let data = try? encoder.encode(widgets) {
            defaults.set(data, forKey: StorageKey.widgets)
        }
    }

    private func savePalette(_ palette: ThemePalette, forKey key: String) {
        if let data = try? encoder.encode(palette) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadPalette(forKey key: String) -> ThemePalette? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ThemePalette.self, from: data)
    }

    private static func loadWidgets() -> [WidgetWindow]? {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.widgets) else { return nil }
        return try? JSONDecoder().decode([WidgetWindow].self, from: data)
    }

    static func defaultWidgets() -> [WidgetWindow] {
        [
            WidgetWindow(type: .clock, size: .huge, column: 0, row: 0),
            WidgetWindow(type: .music, size: .medium, column: 4, row: 0),
            WidgetWindow(type: .calendar, size: .medium, column: 4, row: 2),
            WidgetWindow(type: .weather, size: .medium, column: 6, row: 0)
        ]
    }
}
