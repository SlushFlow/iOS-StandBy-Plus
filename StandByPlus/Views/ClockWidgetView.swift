import SwiftUI

struct ClockWidgetView: View {
    @EnvironmentObject private var settings: StandBySettings
    @Environment(\.themePalette) private var palette

    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            switch settings.clockStyle {
            case .digital:
                digitalClock
            case .analog:
                analogClock
            case .minimal:
                minimalClock
            case .flip:
                flipClock
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(timer) { date in
            now = date
        }
    }

    private var digitalClock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(timeString)
                .font(.system(size: 64, weight: settings.clockFontWeight.fontWeight, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(palette.textPrimary.color)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text(now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.title3.weight(.medium))
                .foregroundStyle(palette.textSecondary.color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var minimalClock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timeString)
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(palette.textPrimary.color)
                .minimumScaleFactor(0.4)
                .lineLimit(1)

            Capsule()
                .fill(palette.accent.color.opacity(0.6))
                .frame(width: 80, height: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var flipClock: some View {
        HStack(spacing: 8) {
            ForEach(Array(timeComponents.enumerated()), id: \.offset) { index, component in
                FlipDigitView(digit: component, accent: palette.accent.color)
                if index < timeComponents.count - 1 {
                    Text(":")
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundStyle(palette.textSecondary.color)
                        .offset(y: -6)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var analogClock: some View {
        AnalogClockFace(date: now, palette: palette)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var timeString: String {
        if settings.use24Hour {
            if settings.showSeconds {
                return now.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).second(.twoDigits))
            }
            return now.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
        }

        if settings.showSeconds {
            return now.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits).second(.twoDigits))
        }
        return now.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits))
    }

    private var timeComponents: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = settings.use24Hour
            ? (settings.showSeconds ? "HH:mm:ss" : "HH:mm")
            : (settings.showSeconds ? "h:mm:ss" : "h:mm")
        let parts = formatter.string(from: now).split(separator: ":").map(String.init)
        return parts.flatMap { part -> [String] in
            part.map { String($0) }
        }
    }
}

struct FlipDigitView: View {
    let digit: String
    let accent: Color

    var body: some View {
        Text(digit)
            .font(.system(size: 42, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.white)
            .frame(width: 38, height: 54)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(accent.opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

struct AnalogClockFace: View {
    let date: Date
    let palette: ThemePalette

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)

            ZStack {
                Circle()
                    .stroke(palette.textSecondary.color.opacity(0.25), lineWidth: 2)
                    .frame(width: size * 0.9, height: size * 0.9)
                    .position(center)

                ForEach(0..<12, id: \.self) { tick in
                    Capsule()
                        .fill(palette.textSecondary.color.opacity(tick % 3 == 0 ? 0.8 : 0.35))
                        .frame(width: 2, height: tick % 3 == 0 ? 14 : 8)
                        .offset(y: -(size * 0.42))
                        .rotationEffect(.degrees(Double(tick) * 30))
                        .position(center)
                }

                clockHand(length: size * 0.22, width: 4, degrees: hourDegrees, color: palette.textPrimary.color)
                    .position(center)

                clockHand(length: size * 0.32, width: 3, degrees: minuteDegrees, color: palette.textPrimary.color)
                    .position(center)

                clockHand(length: size * 0.36, width: 1.5, degrees: secondDegrees, color: palette.accent.color)
                    .position(center)

                Circle()
                    .fill(palette.accent.color)
                    .frame(width: 8, height: 8)
                    .position(center)
            }
        }
    }

    private func clockHand(length: CGFloat, width: CGFloat, degrees: Double, color: Color) -> some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(degrees))
    }

    private var calendar: Calendar { .current }

    private var hourDegrees: Double {
        let hour = Double(calendar.component(.hour, from: date) % 12)
        let minute = Double(calendar.component(.minute, from: date))
        return (hour + minute / 60) * 30
    }

    private var minuteDegrees: Double {
        let minute = Double(calendar.component(.minute, from: date))
        let second = Double(calendar.component(.second, from: date))
        return (minute + second / 60) * 6
    }

    private var secondDegrees: Double {
        Double(calendar.component(.second, from: date)) * 6
    }
}
