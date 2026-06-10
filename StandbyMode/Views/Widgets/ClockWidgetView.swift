import SwiftUI

struct ClockWidgetView: View {
    let size: WidgetSize
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var settingsManager: SettingsManager

    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            switch settingsManager.clockStyle {
            case .digital:
                digitalClock
            case .analog:
                analogClock
            case .minimal:
                minimalClock
            case .flip:
                flipClock
            case .neon:
                neonClock
            }
        }
        .padding()
        .onReceive(timer) { self.currentTime = $0 }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = settingsManager.use24Hour
            ? (settingsManager.showSeconds ? "HH:mm:ss" : "HH:mm")
            : (settingsManager.showSeconds ? "h:mm:ss a" : "h:mm a")
        return formatter.string(from: currentTime)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: currentTime)
    }

    private var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = settingsManager.use24Hour ? "HH" : "h"
        return formatter.string(from: currentTime)
    }

    private var minuteString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter.string(from: currentTime)
    }

    private var secondString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter.string(from: currentTime)
    }

    private var amPmString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return settingsManager.use24Hour ? "" : formatter.string(from: currentTime)
    }

    // MARK: - Digital Clock
    private var digitalClock: some View {
        VStack(spacing: size == .huge ? 8 : 4) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(hourString)
                    .font(.system(size: size == .huge ? 72 : 40, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.colors.primary)

                Text(":")
                    .font(.system(size: size == .huge ? 72 : 40, weight: .light, design: .rounded))
                    .foregroundColor(themeManager.colors.primary.opacity(0.6))
                    .offset(y: -2)

                Text(minuteString)
                    .font(.system(size: size == .huge ? 72 : 40, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.colors.primary)

                if settingsManager.showSeconds {
                    Text(":")
                        .font(.system(size: size == .huge ? 40 : 24, weight: .light, design: .rounded))
                        .foregroundColor(themeManager.colors.primary.opacity(0.4))
                    Text(secondString)
                        .font(.system(size: size == .huge ? 40 : 24, weight: .medium, design: .rounded))
                        .foregroundColor(themeManager.colors.primary.opacity(0.7))
                }

                if !amPmString.isEmpty {
                    Text(amPmString)
                        .font(.system(size: size == .huge ? 24 : 14, weight: .medium, design: .rounded))
                        .foregroundColor(themeManager.colors.textSecondary)
                        .padding(.leading, 4)
                }
            }
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: currentTime)

            if settingsManager.showDate {
                Text(dateString)
                    .font(.system(size: size == .huge ? 18 : 13, weight: .medium, design: .rounded))
                    .foregroundColor(themeManager.colors.textSecondary)
            }
        }
    }

    // MARK: - Analog Clock
    private var analogClock: some View {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: currentTime) % 12)
        let minute = Double(calendar.component(.minute, from: currentTime))
        let second = Double(calendar.component(.second, from: currentTime))

        return GeometryReader { geo in
            let radius = min(geo.size.width, geo.size.height) / 2 - 20

            ZStack {
                Circle()
                    .stroke(themeManager.colors.primary.opacity(0.2), lineWidth: 2)
                    .frame(width: radius * 2, height: radius * 2)

                ForEach(0..<12) { tick in
                    Rectangle()
                        .fill(themeManager.colors.textSecondary)
                        .frame(width: tick % 3 == 0 ? 3 : 1, height: tick % 3 == 0 ? 16 : 8)
                        .offset(y: -radius + (tick % 3 == 0 ? 10 : 6))
                        .rotationEffect(.degrees(Double(tick) * 30))
                }

                // Hour hand
                ClockHand(length: radius * 0.5, width: 4, color: themeManager.colors.primary)
                    .rotationEffect(.degrees((hour + minute / 60) * 30))

                // Minute hand
                ClockHand(length: radius * 0.7, width: 3, color: themeManager.colors.secondary)
                    .rotationEffect(.degrees(minute * 6))

                if settingsManager.showSeconds {
                    ClockHand(length: radius * 0.8, width: 1, color: themeManager.colors.accent)
                        .rotationEffect(.degrees(second * 6))
                }

                Circle()
                    .fill(themeManager.colors.accent)
                    .frame(width: 8, height: 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Minimal Clock
    private var minimalClock: some View {
        VStack(spacing: 0) {
            Text(hourString)
                .font(.system(size: size == .huge ? 80 : 48, weight: .ultraLight, design: .default))
                .foregroundColor(themeManager.colors.textPrimary)

            Text(minuteString)
                .font(.system(size: size == .huge ? 80 : 48, weight: .ultraLight, design: .default))
                .foregroundColor(themeManager.colors.primary)
        }
        .contentTransition(.numericText())
        .animation(.easeInOut(duration: 0.3), value: currentTime)
    }

    // MARK: - Flip Clock
    private var flipClock: some View {
        HStack(spacing: size == .huge ? 16 : 8) {
            FlipDigitView(value: hourString, color: themeManager.colors.primary, bgColor: themeManager.colors.surface, fontSize: size == .huge ? 56 : 32)
            Text(":")
                .font(.system(size: size == .huge ? 56 : 32, weight: .bold))
                .foregroundColor(themeManager.colors.primary.opacity(0.5))
            FlipDigitView(value: minuteString, color: themeManager.colors.primary, bgColor: themeManager.colors.surface, fontSize: size == .huge ? 56 : 32)
            if settingsManager.showSeconds {
                Text(":")
                    .font(.system(size: size == .huge ? 36 : 20, weight: .bold))
                    .foregroundColor(themeManager.colors.primary.opacity(0.3))
                FlipDigitView(value: secondString, color: themeManager.colors.primary.opacity(0.7), bgColor: themeManager.colors.surface, fontSize: size == .huge ? 36 : 20)
            }
        }
    }

    // MARK: - Neon Clock
    private var neonClock: some View {
        VStack(spacing: size == .huge ? 8 : 4) {
            Text(timeString)
                .font(.system(size: size == .huge ? 64 : 36, weight: .bold, design: .monospaced))
                .foregroundColor(themeManager.colors.accent)
                .shadow(color: themeManager.colors.accent.opacity(0.8), radius: 12)
                .shadow(color: themeManager.colors.accent.opacity(0.4), radius: 24)
                .shadow(color: themeManager.colors.accent.opacity(0.2), radius: 48)

            if settingsManager.showDate {
                Text(dateString)
                    .font(.system(size: size == .huge ? 16 : 12, weight: .medium, design: .monospaced))
                    .foregroundColor(themeManager.colors.accent.opacity(0.6))
                    .shadow(color: themeManager.colors.accent.opacity(0.3), radius: 6)
            }
        }
        .contentTransition(.numericText())
        .animation(.easeInOut(duration: 0.3), value: currentTime)
    }
}

struct ClockHand: View {
    let length: CGFloat
    let width: CGFloat
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: width / 2)
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
    }
}

struct FlipDigitView: View {
    let value: String
    let color: Color
    let bgColor: Color
    let fontSize: CGFloat

    var body: some View {
        Text(value)
            .font(.system(size: fontSize, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, fontSize * 0.3)
            .padding(.vertical, fontSize * 0.15)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(bgColor.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(color.opacity(0.15), lineWidth: 1)
                    )
            )
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: value)
    }
}
