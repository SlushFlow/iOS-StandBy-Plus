import SwiftUI

/// Renders the main clock using the user's selected face, font and format.
struct ClockWidgetView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let date = context.date
            switch settings.clockStyle {
            case .digital: digital(date)
            case .flip: flip(date)
            case .analog: AnalogClock(date: date).environment(\.palette, palette)
            case .minimal: minimal(date)
            case .stacked: stacked(date)
            }
        }
    }

    // MARK: Formatting

    private func timeString(_ date: Date, seconds: Bool) -> String {
        let f = DateFormatter()
        if settings.use24Hour {
            f.dateFormat = seconds ? "HH:mm:ss" : "HH:mm"
        } else {
            f.dateFormat = seconds ? "h:mm:ss" : "h:mm"
        }
        return f.string(from: date)
    }

    private func amPm(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "a"; return f.string(from: date)
    }

    private var accent: Color {
        settings.accentHighlights ? palette.accent.color : palette.primaryText.color
    }

    // MARK: Faces

    private func digital(_ date: Date) -> some View {
        VStack(alignment: .leading, spacing: -8) {
            Text(timeString(date, seconds: settings.showSeconds))
                .font(.system(size: 130, weight: .bold, design: settings.fontStyle.design))
                .foregroundStyle(palette.primaryText.color)
                .minimumScaleFactor(0.2)
                .lineLimit(1)
                .contentTransition(.numericText())
            if !settings.use24Hour {
                Text(amPm(date))
                    .font(.system(size: 34, weight: .semibold, design: settings.fontStyle.design))
                    .foregroundStyle(accent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func minimal(_ date: Date) -> some View {
        Text(timeString(date, seconds: false))
            .font(.system(size: 120, weight: .ultraLight, design: settings.fontStyle.design))
            .foregroundStyle(palette.primaryText.color)
            .minimumScaleFactor(0.2)
            .lineLimit(1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentTransition(.numericText())
    }

    private func stacked(_ date: Date) -> some View {
        let comps = timeString(date, seconds: false).split(separator: ":")
        return VStack(alignment: .leading, spacing: -20) {
            ForEach(Array(comps.enumerated()), id: \.offset) { _, part in
                Text(part)
                    .font(.system(size: 120, weight: .heavy, design: settings.fontStyle.design))
                    .foregroundStyle(palette.primaryText.color)
            }
        }
        .minimumScaleFactor(0.2)
        .lineLimit(1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func flip(_ date: Date) -> some View {
        let comps = timeString(date, seconds: false).split(separator: ":")
        return HStack(spacing: 12) {
            ForEach(Array(comps.enumerated()), id: \.offset) { _, part in
                FlipTile(text: String(part))
                    .environment(\.palette, palette)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A single flip-clock tile.
private struct FlipTile: View {
    @Environment(\.palette) private var palette
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 96, weight: .bold, design: .rounded))
            .foregroundStyle(palette.primaryText.color)
            .minimumScaleFactor(0.2)
            .lineLimit(1)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .frame(maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(palette.primaryText.with(opacity: 0.08).color)
                    .overlay(alignment: .center) {
                        Rectangle()
                            .fill(palette.background.with(opacity: 0.5).color)
                            .frame(height: 2)
                    }
            }
            .transition(.opacity)
            .id(text)
    }
}

/// A clean analog face.
struct AnalogClock: View {
    @Environment(\.palette) private var palette
    var date: Date

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cal = Calendar.current
            let h = Double(cal.component(.hour, from: date) % 12)
            let m = Double(cal.component(.minute, from: date))
            let s = Double(cal.component(.second, from: date))
            let hourAngle = (h + m / 60) / 12 * 360
            let minuteAngle = (m + s / 60) / 60 * 360
            let secondAngle = s / 60 * 360

            ZStack {
                Circle()
                    .stroke(palette.primaryText.with(opacity: 0.12).color, lineWidth: size * 0.02)
                ForEach(0..<12) { i in
                    Rectangle()
                        .fill(palette.secondaryText.color)
                        .frame(width: size * 0.012, height: size * 0.05)
                        .offset(y: -size * 0.43)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
                hand(length: size * 0.27, width: size * 0.022, angle: hourAngle, color: palette.primaryText.color)
                hand(length: size * 0.40, width: size * 0.016, angle: minuteAngle, color: palette.primaryText.color)
                hand(length: size * 0.42, width: size * 0.006, angle: secondAngle, color: palette.accent.color)
                Circle()
                    .fill(palette.accent.color)
                    .frame(width: size * 0.05, height: size * 0.05)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func hand(length: CGFloat, width: CGFloat, angle: Double, color: Color) -> some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(angle))
    }
}
