import SwiftUI

@main
struct StandByPlusApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var nowPlaying = NowPlayingManager()
    @StateObject private var calls = CallManager()
    @StateObject private var volume = VolumeController()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(nowPlaying)
                .environmentObject(calls)
                .environmentObject(volume)
                .preferredColorScheme(.dark)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}
