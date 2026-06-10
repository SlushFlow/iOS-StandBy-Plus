import SwiftUI

@main
struct StandByPlusApp: App {
    @StateObject private var theme = ThemeManager()
    @StateObject private var widgets = WidgetStore()
    @StateObject private var clockPrefs = ClockPreferences()
    @StateObject private var music = MusicController()
    @StateObject private var calls = CallMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
                .environmentObject(widgets)
                .environmentObject(clockPrefs)
                .environmentObject(music)
                .environmentObject(calls)
                .preferredColorScheme(theme.isNight ? .dark : .light)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}
