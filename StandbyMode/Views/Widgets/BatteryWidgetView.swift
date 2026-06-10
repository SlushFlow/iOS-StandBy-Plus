import SwiftUI

struct BatteryWidgetView: View {
    let size: WidgetSize
    @EnvironmentObject var themeManager: ThemeManager

    @State private var batteryLevel: Float = 0
    @State private var isCharging: Bool = false

    var body: some View {
        VStack(spacing: size == .huge ? 16 : 8) {
            ZStack {
                Circle()
                    .stroke(themeManager.colors.textSecondary.opacity(0.15), lineWidth: size == .huge ? 10 : 6)

                Circle()
                    .trim(from: 0, to: CGFloat(batteryLevel))
                    .stroke(
                        batteryColor,
                        style: StrokeStyle(lineWidth: size == .huge ? 10 : 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: batteryLevel)

                VStack(spacing: 2) {
                    if isCharging {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: size == .huge ? 16 : 10))
                            .foregroundColor(themeManager.colors.accent)
                    }

                    Text("\(Int(batteryLevel * 100))%")
                        .font(.system(size: size == .huge ? 28 : 18, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.colors.textPrimary)
                        .contentTransition(.numericText())
                }
            }
            .padding(size == .huge ? 16 : 10)

            if size == .huge {
                Text(isCharging ? "Charging" : "Battery")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.colors.textSecondary)
            }
        }
        .padding(8)
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            updateBattery()
            NotificationCenter.default.addObserver(
                forName: UIDevice.batteryLevelDidChangeNotification,
                object: nil, queue: .main
            ) { _ in updateBattery() }
            NotificationCenter.default.addObserver(
                forName: UIDevice.batteryStateDidChangeNotification,
                object: nil, queue: .main
            ) { _ in updateBattery() }
        }
    }

    private func updateBattery() {
        batteryLevel = max(0, UIDevice.current.batteryLevel)
        if batteryLevel < 0 { batteryLevel = 0.75 }
        isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
    }

    private var batteryColor: Color {
        if batteryLevel > 0.5 {
            return themeManager.colors.accent
        } else if batteryLevel > 0.2 {
            return .orange
        } else {
            return .red
        }
    }
}
