import SwiftUI
import Combine

enum WidgetKind: String, Codable, CaseIterable, Identifiable {
    case clock
    case music
    case calendar
    case battery

    var id: String { rawValue }

    var name: String {
        switch self {
        case .clock: return "Clock"
        case .music: return "Music"
        case .calendar: return "Calendar"
        case .battery: return "Battery"
        }
    }

    var symbol: String {
        switch self {
        case .clock: return "clock.fill"
        case .music: return "music.note"
        case .calendar: return "calendar"
        case .battery: return "battery.75"
        }
    }
}

enum WidgetSize: String, Codable {
    case medium
    case huge

    var toggled: WidgetSize { self == .medium ? .huge : .medium }
}

struct WidgetItem: Identifiable, Codable, Equatable {
    var id: UUID
    var kind: WidgetKind
    var size: WidgetSize
    /// Normalized center position within the canvas, 0...1 on both axes.
    var x: Double
    var y: Double

    init(kind: WidgetKind, size: WidgetSize = .medium, x: Double = 0.5, y: Double = 0.5) {
        self.id = UUID()
        self.kind = kind
        self.size = size
        self.x = x
        self.y = y
    }
}

final class WidgetStore: ObservableObject {
    @Published var items: [WidgetItem] = []

    private var cancellable: AnyCancellable?
    private static let storageKey = "standbyplus.widgets.v1"

    init() {
        load()
        cancellable = $items
            .dropFirst()
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.save() }
    }

    func add(_ kind: WidgetKind) {
        var item = WidgetItem(kind: kind)
        // Offset new widgets slightly so stacked additions stay visible.
        let count = Double(items.count)
        item.x = min(0.75, 0.3 + count * 0.06)
        item.y = min(0.75, 0.35 + count * 0.06)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            items.append(item)
        }
    }

    func remove(_ item: WidgetItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            items.removeAll { $0.id == item.id }
        }
    }

    func toggleSize(_ item: WidgetItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
            items[index].size = items[index].size.toggled
            if items[index].size == .huge {
                items[index].x = 0.5
                items[index].y = 0.5
            }
        }
    }

    func move(_ item: WidgetItem, to point: CGPoint) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].x = Double(point.x)
        items[index].y = Double(point.y)
    }

    func bringToFront(_ item: WidgetItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }),
              index != items.count - 1 else { return }
        let moved = items.remove(at: index)
        items.append(moved)
    }

    func resetLayout() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            items = Self.defaultLayout()
        }
    }

    private static func defaultLayout() -> [WidgetItem] {
        [
            WidgetItem(kind: .clock, size: .medium, x: 0.26, y: 0.5),
            WidgetItem(kind: .music, size: .medium, x: 0.74, y: 0.5)
        ]
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode([WidgetItem].self, from: data) {
            items = saved
        } else {
            items = Self.defaultLayout()
        }
    }
}
