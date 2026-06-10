import SwiftUI

@main
struct StandbyModeApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var widgetManager = WidgetManager()
    @StateObject private var callManager = CallManager()
    @StateObject private var musicManager = MusicPlayerManager()
    @StateObject private var settingsManager = SettingsManager()

    var body: some Scene {
        WindowGroup {
            StandbyContainerView()
                .environmentObject(themeManager)
                .environmentObject(widgetManager)
                .environmentObject(callManager)
                .environmentObject(musicManager)
                .environmentObject(settingsManager)
                .preferredColorScheme(.dark)
                .persistentSystemOverlays(.hidden)
                .statusBarHidden(true)
        }
    }
}
