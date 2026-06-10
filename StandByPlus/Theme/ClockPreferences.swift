import SwiftUI
import Combine

enum ClockFace: String, Codable, CaseIterable, Identifiable {
    case digital
    case stacked
    case analog
    case minimal

    var id: String { rawValue }

    var name: String {
        switch self {
        case .digital: return "Digital"
        case .stacked: return "Stacked"
        case .analog: return "Analog"
        case .minimal: return "Minimal"
        }
    }

    var symbol: String {
        switch self {
        case .digital: return "textformat.123"
        case .stacked: return "square.stack.fill"
        case .analog: return "clock"
        case .minimal: return "minus"
        }
    }
}

enum ClockFontStyle: String, Codable, CaseIterable, Identifiable {
    case rounded
    case standard
    case serif
    case mono

    var id: String { rawValue }

    var name: String {
        switch self {
        case .rounded: return "Rounded"
        case .standard: return "Standard"
        case .serif: return "Serif"
        case .mono: return "Mono"
        }
    }

    var design: Font.Design {
        switch self {
        case .rounded: return .rounded
        case .standard: return .default
        case .serif: return .serif
        case .mono: return .monospaced
        }
    }
}

final class ClockPreferences: ObservableObject {
    @Published var face: ClockFace = .stacked
    @Published var fontStyle: ClockFontStyle = .rounded
    @Published var showSeconds: Bool = false
    @Published var use24Hour: Bool = false
    @Published var showDate: Bool = true
    @Published var useCustomColor: Bool = false
    @Published var customColor: CodableColor = .hex(0xE8A04C)

    private var cancellables = Set<AnyCancellable>()
    private static let storageKey = "standbyplus.clock.v1"

    private struct Snapshot: Codable {
        var face: ClockFace
        var fontStyle: ClockFontStyle
        var showSeconds: Bool
        var use24Hour: Bool
        var showDate: Bool
        var useCustomColor: Bool
        var customColor: CodableColor
    }

    init() {
        load()
        let changes: [AnyPublisher<Void, Never>] = [
            $face.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $fontStyle.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $showSeconds.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $use24Hour.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $showDate.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $useCustomColor.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $customColor.dropFirst().map { _ in () }.eraseToAnyPublisher()
        ]
        Publishers.MergeMany(changes)
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.save() }
            .store(in: &cancellables)
    }

    /// The color clock digits/hands should use given the current palette.
    func displayColor(in palette: Palette) -> Color {
        useCustomColor ? customColor.color : palette.primaryText.color
    }

    func hourMinuteString(for date: Date) -> String {
        let formatter = Self.cachedFormatter
        formatter.dateFormat = use24Hour ? "HH:mm" : "h:mm"
        return formatter.string(from: date)
    }

    func secondsString(for date: Date) -> String {
        let formatter = Self.cachedFormatter
        formatter.dateFormat = "ss"
        return formatter.string(from: date)
    }

    func amPmString(for date: Date) -> String? {
        guard !use24Hour else { return nil }
        let formatter = Self.cachedFormatter
        formatter.dateFormat = "a"
        return formatter.string(from: date)
    }

    func hourString(for date: Date) -> String {
        let formatter = Self.cachedFormatter
        formatter.dateFormat = use24Hour ? "HH" : "h"
        return formatter.string(from: date)
    }

    func minuteString(for date: Date) -> String {
        let formatter = Self.cachedFormatter
        formatter.dateFormat = "mm"
        return formatter.string(from: date)
    }

    static func dateString(for date: Date) -> String {
        let formatter = cachedFormatter
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    private static let cachedFormatter = DateFormatter()

    private func save() {
        let snapshot = Snapshot(
            face: face,
            fontStyle: fontStyle,
            showSeconds: showSeconds,
            use24Hour: use24Hour,
            showDate: showDate,
            useCustomColor: useCustomColor,
            customColor: customColor
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        face = snapshot.face
        fontStyle = snapshot.fontStyle
        showSeconds = snapshot.showSeconds
        use24Hour = snapshot.use24Hour
        showDate = snapshot.showDate
        useCustomColor = snapshot.useCustomColor
        customColor = snapshot.customColor
    }
}
