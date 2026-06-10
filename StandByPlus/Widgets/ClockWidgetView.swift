import SwiftUI

struct ClockWidgetView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var prefs: ClockPreferences

    var body: some View {
        TimelineView(.periodic(from: .now, by: prefs.showSeconds ? 1 : 5)) { context in
            GeometryReader { geo in
                clockBody(for: context.date, in: geo.size)
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .padding(12)
    }

    @ViewBuilder
    private func clockBody(for date: Date, in size: CGSize) -> some View {
        let color = prefs.displayColor(in: theme.palette)
        let secondary = theme.palette.secondaryText.color

        switch prefs.face {
        case .digital:
            DigitalClockFace(date: date, size: size, color: color, secondary: secondary)
        case .stacked:
            StackedClockFace(date: date, size: size, color: color, secondary: secondary)
        case .analog:
            AnalogClockFace(date: date, size: size, color: color, secondary: secondary)
        case .minimal:
            MinimalClockFace(date: date, size: size, color: color, secondary: secondary)
        }
    }
}

// MARK: - Digital

private struct DigitalClockFace: View {
    @EnvironmentObject private var prefs: ClockPreferences
    let date: Date
    let size: CGSize
    let color: Color
    let secondary: Color

    var body: some View {
        VStack(spacing: size.height * 0.02) {
            HStack(alignment: .firstTextBaseline, spacing: size.width * 0.02) {
                Text(prefs.hourMinuteString(for: date))
                    .font(.system(size: size.height * 0.42, weight: .bold, design: prefs.fontStyle.design))
                    .foregroundColor(color)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)

                VStack(alignment: .leading, spacing: 2) {
                    if prefs.showSeconds {
                        Text(prefs.secondsString(for: date))
                            .font(.system(size: size.height * 0.13, weight: .semibold, design: prefs.fontStyle.design))
                            .foregroundColor(secondary)
                            .monospacedDigit()
                    }
                    if let amPm = prefs.amPmString(for: date) {
                        Text(amPm)
                            .font(.system(size: size.height * 0.11, weight: .semibold, design: prefs.fontStyle.design))
                            .foregroundColor(secondary)
                    }
                }
            }
            if prefs.showDate {
                Text(ClockPreferences.dateString(for: date))
                    .font(.system(size: size.height * 0.1, weight: .medium, design: prefs.fontStyle.design))
                    .foregroundColor(secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Stacked (StandBy-style hours over minutes)

private struct StackedClockFace: View {
    @EnvironmentObject private var prefs: ClockPreferences
    let date: Date
    let size: CGSize
    let color: Color
    let secondary: Color

    var body: some View {
        HStack(spacing: size.width * 0.05) {
            VStack(spacing: -size.height * 0.08) {
                Text(prefs.hourString(for: date))
                    .foregroundColor(color)
                Text(prefs.minuteString(for: date))
                    .foregroundColor(color.opacity(0.55))
            }
            .font(.system(size: size.height * 0.42, weight: .heavy, design: prefs.fontStyle.design).monospacedDigit())
            .lineLimit(1)
            .minimumScaleFactor(0.3)

            VStack(alignment: .leading, spacing: size.height * 0.03) {
                if let amPm = prefs.amPmString(for: date) {
                    Text(amPm)
                        .font(.system(size: size.height * 0.1, weight: .bold, design: prefs.fontStyle.design))
                        .foregroundColor(secondary)
                }
                if prefs.showSeconds {
                    Text(prefs.secondsString(for: date))
                        .font(.system(size: size.height * 0.1, weight: .semibold, design: prefs.fontStyle.design))
                        .foregroundColor(secondary)
                        .monospacedDigit()
                }
                if prefs.showDate {
                    Text(ClockPreferences.dateString(for: date))
                        .font(.system(size: size.height * 0.075, weight: .medium, design: prefs.fontStyle.design))
                        .foregroundColor(secondary)
                        .fixedSize()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Analog

private struct AnalogClockFace: View {
    @EnvironmentObject private var prefs: ClockPreferences
    let date: Date
    let size: CGSize
    let color: Color
    let secondary: Color

    var body: some View {
        let diameter = min(size.width, size.height) * 0.92
        let comps = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let hour = Double(comps.hour ?? 0).truncatingRemainder(dividingBy: 12)
        let minute = Double(comps.minute ?? 0)
        let second = Double(comps.second ?? 0)

        VStack(spacing: size.height * 0.02) {
            ZStack {
                Circle()
                    .strokeBorder(secondary.opacity(0.35), lineWidth: 2)

                ForEach(0..<12, id: \.self) { tick in
                    Capsule()
                        .fill(tick % 3 == 0 ? color : secondary.opacity(0.5))
                        .frame(width: tick % 3 == 0 ? 4 : 2, height: diameter * 0.05)
                        .offset(y: -diameter * 0.44)
                        .rotationEffect(.degrees(Double(tick) * 30))
                }

                // Hour hand
                Capsule()
                    .fill(color)
                    .frame(width: diameter * 0.025, height: diameter * 0.24)
                    .offset(y: -diameter * 0.12)
                    .rotationEffect(.degrees(hour * 30 + minute * 0.5))

                // Minute hand
                Capsule()
                    .fill(color.opacity(0.85))
                    .frame(width: diameter * 0.018, height: diameter * 0.36)
                    .offset(y: -diameter * 0.18)
                    .rotationEffect(.degrees(minute * 6 + second * 0.1))

                if prefs.showSeconds {
                    Capsule()
                        .fill(secondary)
                        .frame(width: diameter * 0.008, height: diameter * 0.4)
                        .offset(y: -diameter * 0.2)
                        .rotationEffect(.degrees(second * 6))
                }

                Circle()
                    .fill(color)
                    .frame(width: diameter * 0.04, height: diameter * 0.04)
            }
            .frame(width: diameter, height: diameter)

            if prefs.showDate {
                Text(ClockPreferences.dateString(for: date))
                    .font(.system(size: size.height * 0.07, weight: .medium, design: prefs.fontStyle.design))
                    .foregroundColor(secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Minimal

private struct MinimalClockFace: View {
    @EnvironmentObject private var prefs: ClockPreferences
    let date: Date
    let size: CGSize
    let color: Color
    let secondary: Color

    var body: some View {
        VStack(spacing: size.height * 0.04) {
            Text(prefs.hourMinuteString(for: date) + (prefs.showSeconds ? ":" + prefs.secondsString(for: date) : ""))
                .font(.system(size: size.height * 0.3, weight: .ultraLight, design: prefs.fontStyle.design).monospacedDigit())
                .tracking(size.width * 0.01)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.3)

            if prefs.showDate {
                Text(ClockPreferences.dateString(for: date).uppercased())
                    .font(.system(size: size.height * 0.07, weight: .light, design: prefs.fontStyle.design))
                    .foregroundColor(secondary)
                    .tracking(3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
