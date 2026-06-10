import SwiftUI
import Combine

final class ThemeManager: ObservableObject {
    @Published var mode: ThemeMode = .auto
    @Published var day: Palette = .cozyDay
    @Published var night: Palette = .cozyNight
    /// Minutes after midnight when night mode begins / ends (auto mode).
    @Published var nightStartMinutes: Int = 21 * 60
    @Published var nightEndMinutes: Int = 7 * 60

    @Published private(set) var isNight: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var clockTimer: Timer?
    private static let storageKey = "standbyplus.theme.v1"

    private struct Snapshot: Codable {
        var mode: ThemeMode
        var day: Palette
        var night: Palette
        var nightStartMinutes: Int
        var nightEndMinutes: Int
    }

    init() {
        load()
        recomputeNight()

        let changes: [AnyPublisher<Void, Never>] = [
            $mode.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $day.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $night.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $nightStartMinutes.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $nightEndMinutes.dropFirst().map { _ in () }.eraseToAnyPublisher()
        ]
        Publishers.MergeMany(changes)
            .handleEvents(receiveOutput: { [weak self] in
                // @Published emits on willSet, so defer until the new value lands.
                DispatchQueue.main.async { self?.recomputeNight() }
            })
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.save() }
            .store(in: &cancellables)

        clockTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.recomputeNight()
        }
    }

    deinit {
        clockTimer?.invalidate()
    }

    var palette: Palette { isNight ? night : day }

    func applyPreset(_ preset: ThemePreset) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            day = preset.day
            night = preset.night
        }
    }

    func toggleDayNight() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            mode = isNight ? .day : .night
        }
    }

    private func recomputeNight() {
        let newValue: Bool
        switch mode {
        case .day:
            newValue = false
        case .night:
            newValue = true
        case .auto:
            let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
            let now = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
            if nightStartMinutes <= nightEndMinutes {
                newValue = now >= nightStartMinutes && now < nightEndMinutes
            } else {
                // Window wraps past midnight, e.g. 21:00 -> 07:00.
                newValue = now >= nightStartMinutes || now < nightEndMinutes
            }
        }
        if newValue != isNight {
            withAnimation(.easeInOut(duration: 0.8)) {
                isNight = newValue
            }
        }
    }

    private func save() {
        let snapshot = Snapshot(
            mode: mode,
            day: day,
            night: night,
            nightStartMinutes: nightStartMinutes,
            nightEndMinutes: nightEndMinutes
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        mode = snapshot.mode
        day = snapshot.day
        night = snapshot.night
        nightStartMinutes = snapshot.nightStartMinutes
        nightEndMinutes = snapshot.nightEndMinutes
    }
}
