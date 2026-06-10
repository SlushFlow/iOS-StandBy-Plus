import SwiftUI
import Combine

enum TimeOfDay {
    case day, night

    static var current: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        return (6..<20).contains(hour) ? .day : .night
    }
}

struct ThemeColors: Codable, Equatable {
    var primaryHex: String
    var secondaryHex: String
    var accentHex: String
    var backgroundHex: String
    var surfaceHex: String
    var textPrimaryHex: String
    var textSecondaryHex: String

    var primary: Color { Color(hex: primaryHex) }
    var secondary: Color { Color(hex: secondaryHex) }
    var accent: Color { Color(hex: accentHex) }
    var background: Color { Color(hex: backgroundHex) }
    var surface: Color { Color(hex: surfaceHex) }
    var textPrimary: Color { Color(hex: textPrimaryHex) }
    var textSecondary: Color { Color(hex: textSecondaryHex) }

    static let defaultDay = ThemeColors(
        primaryHex: "#4A90D9",
        secondaryHex: "#7B68EE",
        accentHex: "#00BFA5",
        backgroundHex: "#1A1A2E",
        surfaceHex: "#16213E",
        textPrimaryHex: "#E8E8E8",
        textSecondaryHex: "#A0A0B0"
    )

    static let defaultNight = ThemeColors(
        primaryHex: "#6C5CE7",
        secondaryHex: "#A29BFE",
        accentHex: "#00CEC9",
        backgroundHex: "#0D0D1A",
        surfaceHex: "#111128",
        textPrimaryHex: "#C8C8D8",
        textSecondaryHex: "#707088"
    )
}

class ThemeManager: ObservableObject {
    @Published var dayColors: ThemeColors {
        didSet { save() }
    }
    @Published var nightColors: ThemeColors {
        didSet { save() }
    }
    @Published var timeOfDay: TimeOfDay = .current
    @Published var autoDayNight: Bool = true {
        didSet { save() }
    }

    private var timer: Timer?

    var colors: ThemeColors {
        timeOfDay == .day ? dayColors : nightColors
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "dayColors"),
           let decoded = try? JSONDecoder().decode(ThemeColors.self, from: data) {
            self.dayColors = decoded
        } else {
            self.dayColors = .defaultDay
        }

        if let data = UserDefaults.standard.data(forKey: "nightColors"),
           let decoded = try? JSONDecoder().decode(ThemeColors.self, from: data) {
            self.nightColors = decoded
        } else {
            self.nightColors = .defaultNight
        }

        self.autoDayNight = UserDefaults.standard.object(forKey: "autoDayNight") as? Bool ?? true

        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self, self.autoDayNight else { return }
            DispatchQueue.main.async {
                self.timeOfDay = .current
            }
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(dayColors) {
            UserDefaults.standard.set(data, forKey: "dayColors")
        }
        if let data = try? JSONEncoder().encode(nightColors) {
            UserDefaults.standard.set(data, forKey: "nightColors")
        }
        UserDefaults.standard.set(autoDayNight, forKey: "autoDayNight")
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        let r = Int((components[0] * 255).rounded())
        let g = Int((components.count > 1 ? components[1] : components[0]) * 255)
        let b = Int((components.count > 2 ? components[2] : components[0]) * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
