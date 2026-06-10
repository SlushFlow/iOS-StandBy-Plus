import SwiftUI
import Combine

enum WidgetSize: String, Codable, CaseIterable {
    case medium
    case huge

    var gridSize: CGSize {
        switch self {
        case .medium: return CGSize(width: 2, height: 2)
        case .huge: return CGSize(width: 4, height: 3)
        }
    }

    var displayName: String {
        switch self {
        case .medium: return "Medium"
        case .huge: return "Huge"
        }
    }
}

enum WidgetType: String, Codable, CaseIterable, Identifiable {
    case clock
    case music
    case calendar
    case weather
    case battery
    case photo

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .clock: return "Clock"
        case .music: return "Music"
        case .calendar: return "Calendar"
        case .weather: return "Weather"
        case .battery: return "Battery"
        case .photo: return "Photo"
        }
    }

    var icon: String {
        switch self {
        case .clock: return "clock.fill"
        case .music: return "music.note"
        case .calendar: return "calendar"
        case .weather: return "cloud.sun.fill"
        case .battery: return "battery.75percent"
        case .photo: return "photo.fill"
        }
    }
}

struct StandbyWidget: Identifiable, Codable, Equatable {
    let id: UUID
    var type: WidgetType
    var size: WidgetSize
    var position: CGPoint
    var zIndex: Int

    init(type: WidgetType, size: WidgetSize, position: CGPoint, zIndex: Int = 0) {
        self.id = UUID()
        self.type = type
        self.size = size
        self.position = position
        self.zIndex = zIndex
    }
}

class WidgetManager: ObservableObject {
    @Published var widgets: [StandbyWidget] = [] {
        didSet { save() }
    }
    @Published var isEditing: Bool = false
    @Published var selectedWidgetId: UUID? = nil

    init() {
        load()
        if widgets.isEmpty {
            setupDefaults()
        }
    }

    func addWidget(type: WidgetType, size: WidgetSize) {
        let maxZ = widgets.map(\.zIndex).max() ?? 0
        let widget = StandbyWidget(
            type: type,
            size: size,
            position: CGPoint(x: 200, y: 200),
            zIndex: maxZ + 1
        )
        widgets.append(widget)
    }

    func removeWidget(id: UUID) {
        widgets.removeAll { $0.id == id }
        if selectedWidgetId == id {
            selectedWidgetId = nil
        }
    }

    func updatePosition(id: UUID, position: CGPoint) {
        if let index = widgets.firstIndex(where: { $0.id == id }) {
            widgets[index].position = position
        }
    }

    func bringToFront(id: UUID) {
        let maxZ = widgets.map(\.zIndex).max() ?? 0
        if let index = widgets.firstIndex(where: { $0.id == id }) {
            widgets[index].zIndex = maxZ + 1
        }
    }

    func updateSize(id: UUID, size: WidgetSize) {
        if let index = widgets.firstIndex(where: { $0.id == id }) {
            widgets[index].size = size
        }
    }

    private func setupDefaults() {
        widgets = [
            StandbyWidget(type: .clock, size: .huge, position: CGPoint(x: 400, y: 180), zIndex: 1),
            StandbyWidget(type: .music, size: .medium, position: CGPoint(x: 150, y: 400), zIndex: 2),
            StandbyWidget(type: .battery, size: .medium, position: CGPoint(x: 650, y: 400), zIndex: 3)
        ]
    }

    private func save() {
        if let data = try? JSONEncoder().encode(widgets) {
            UserDefaults.standard.set(data, forKey: "standbyWidgets")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: "standbyWidgets"),
           let decoded = try? JSONDecoder().decode([StandbyWidget].self, from: data) {
            self.widgets = decoded
        }
    }
}
