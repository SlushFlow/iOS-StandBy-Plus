import SwiftUI
import Combine

enum ClockStyle: String, Codable, CaseIterable {
    case digital
    case analog
    case minimal
    case flip
    case neon

    var displayName: String {
        switch self {
        case .digital: return "Digital"
        case .analog: return "Analog"
        case .minimal: return "Minimal"
        case .flip: return "Flip"
        case .neon: return "Neon"
        }
    }
}

class SettingsManager: ObservableObject {
    @Published var clockStyle: ClockStyle {
        didSet { UserDefaults.standard.set(clockStyle.rawValue, forKey: "clockStyle") }
    }
    @Published var showSeconds: Bool {
        didSet { UserDefaults.standard.set(showSeconds, forKey: "showSeconds") }
    }
    @Published var use24Hour: Bool {
        didSet { UserDefaults.standard.set(use24Hour, forKey: "use24Hour") }
    }
    @Published var showDate: Bool {
        didSet { UserDefaults.standard.set(showDate, forKey: "showDate") }
    }
    @Published var clockFontName: String {
        didSet { UserDefaults.standard.set(clockFontName, forKey: "clockFontName") }
    }
    @Published var keepScreenOn: Bool {
        didSet {
            UserDefaults.standard.set(keepScreenOn, forKey: "keepScreenOn")
            UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        }
    }
    @Published var screenBrightness: Double {
        didSet { UserDefaults.standard.set(screenBrightness, forKey: "screenBrightness") }
    }
    @Published var showSettingsPanel: Bool = false

    init() {
        let style = UserDefaults.standard.string(forKey: "clockStyle") ?? ClockStyle.digital.rawValue
        self.clockStyle = ClockStyle(rawValue: style) ?? .digital
        self.showSeconds = UserDefaults.standard.object(forKey: "showSeconds") as? Bool ?? false
        self.use24Hour = UserDefaults.standard.object(forKey: "use24Hour") as? Bool ?? false
        self.showDate = UserDefaults.standard.object(forKey: "showDate") as? Bool ?? true
        self.clockFontName = UserDefaults.standard.string(forKey: "clockFontName") ?? "default"
        self.keepScreenOn = UserDefaults.standard.object(forKey: "keepScreenOn") as? Bool ?? true
        self.screenBrightness = UserDefaults.standard.object(forKey: "screenBrightness") as? Double ?? 0.5

        UIApplication.shared.isIdleTimerDisabled = keepScreenOn
    }
}
