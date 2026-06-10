import SwiftUI
import EventKit

final class CalendarService: ObservableObject {
    @Published var events: [EKEvent] = []
    @Published var authorized = false

    private let store = EKEventStore()

    init() {
        refreshAuthorization()
    }

    func refreshAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17.0, *) {
            authorized = status == .fullAccess
        } else {
            authorized = status == .authorized
        }
        if authorized {
            loadEvents()
        }
    }

    func requestAccess() {
        let completion: (Bool, Error?) -> Void = { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.authorized = granted
                if granted {
                    self?.loadEvents()
                }
            }
        }
        if #available(iOS 17.0, *) {
            store.requestFullAccessToEvents(completion: completion)
        } else {
            store.requestAccess(to: .event, completion: completion)
        }
    }

    func loadEvents() {
        let start = Date()
        guard let end = Calendar.current.date(byAdding: .day, value: 7, to: start) else { return }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let found = store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
        events = Array(found.prefix(6))
    }
}

struct CalendarWidgetView: View {
    @EnvironmentObject private var theme: ThemeManager
    @StateObject private var service = CalendarService()
    let isHuge: Bool

    var body: some View {
        let palette = theme.palette
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(Date(), format: .dateTime.weekday(.wide))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(palette.accent.color)
                Text(Date(), format: .dateTime.day().month(.wide))
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(palette.secondaryText.color)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(palette.secondaryText.color)
            }

            if !service.authorized {
                Spacer()
                Button {
                    service.requestAccess()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title2)
                        Text("Tap to show events")
                            .font(.system(.footnote, design: .rounded))
                    }
                    .foregroundColor(palette.secondaryText.color)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PressableButtonStyle())
                Spacer()
            } else if service.events.isEmpty {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(palette.accent.color)
                    Text("Nothing coming up — enjoy the quiet.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(palette.secondaryText.color)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                let limit = isHuge ? 6 : 3
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(service.events.prefix(limit)), id: \.eventIdentifier) { event in
                        HStack(spacing: 8) {
                            Capsule()
                                .fill(palette.accent.color)
                                .frame(width: 3, height: 28)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(event.title ?? "Event")
                                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                    .foregroundColor(palette.primaryText.color)
                                    .lineLimit(1)
                                Text(event.startDate, format: .dateTime.weekday(.abbreviated).hour().minute())
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(palette.secondaryText.color)
                            }
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(16)
        .onAppear { service.refreshAuthorization() }
    }
}

struct BatteryWidgetView: View {
    @EnvironmentObject private var theme: ThemeManager
    @State private var level: Float = UIDevice.current.batteryLevel
    @State private var state: UIDevice.BatteryState = UIDevice.current.batteryState

    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {
        let palette = theme.palette
        let percent = max(0, Int((level * 100).rounded()))
        let charging = state == .charging || state == .full

        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            VStack(spacing: side * 0.05) {
                ZStack {
                    Circle()
                        .stroke(palette.secondaryText.color.opacity(0.2), lineWidth: side * 0.06)
                    Circle()
                        .trim(from: 0, to: CGFloat(max(0.02, level)))
                        .stroke(
                            charging ? Color.green : palette.accent.color,
                            style: StrokeStyle(lineWidth: side * 0.06, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: level)

                    VStack(spacing: 2) {
                        if charging {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: side * 0.1))
                                .foregroundColor(.green)
                        }
                        Text("\(percent)%")
                            .font(.system(size: side * 0.18, weight: .bold, design: .rounded))
                            .foregroundColor(palette.primaryText.color)
                            .monospacedDigit()
                    }
                }
                .frame(width: side * 0.62, height: side * 0.62)

                Text(charging ? "Charging" : "Battery")
                    .font(.system(size: side * 0.08, weight: .medium, design: .rounded))
                    .foregroundColor(palette.secondaryText.color)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .padding(12)
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            update()
        }
        .onReceive(timer) { _ in update() }
    }

    private func update() {
        level = max(UIDevice.current.batteryLevel, 0)
        state = UIDevice.current.batteryState
    }
}
