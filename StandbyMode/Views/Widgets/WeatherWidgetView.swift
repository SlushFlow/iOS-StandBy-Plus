import SwiftUI

struct WeatherWidgetView: View {
    let size: WidgetSize
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: size == .huge ? 12 : 6) {
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: size == .huge ? 40 : 24))
                    .symbolRenderingMode(.multicolor)

                if size == .huge {
                    Spacer()
                }

                VStack(alignment: size == .huge ? .trailing : .leading, spacing: 2) {
                    Text("72\u{00B0}")
                        .font(.system(size: size == .huge ? 42 : 28, weight: .semibold, design: .rounded))
                        .foregroundColor(themeManager.colors.textPrimary)

                    if size == .huge {
                        Text("Partly Cloudy")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 8)

            if size == .huge {
                Divider()
                    .background(themeManager.colors.textSecondary.opacity(0.2))

                HStack(spacing: 16) {
                    weatherDetail(icon: "drop.fill", value: "45%", label: "Humidity")
                    weatherDetail(icon: "wind", value: "8 mph", label: "Wind")
                    weatherDetail(icon: "eye.fill", value: "10 mi", label: "Visibility")
                }
            }
        }
        .padding()
    }

    private func weatherDetail(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeManager.colors.primary)
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.colors.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(themeManager.colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
