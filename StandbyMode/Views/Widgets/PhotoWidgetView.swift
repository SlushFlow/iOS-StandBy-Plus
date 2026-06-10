import SwiftUI

struct PhotoWidgetView: View {
    let size: WidgetSize
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    themeManager.colors.primary.opacity(0.3),
                    themeManager.colors.secondary.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: size == .huge ? 40 : 24))
                    .foregroundColor(themeManager.colors.textPrimary.opacity(0.5))

                Text("Photos")
                    .font(.system(size: size == .huge ? 16 : 12, weight: .medium))
                    .foregroundColor(themeManager.colors.textSecondary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
