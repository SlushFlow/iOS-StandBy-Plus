import SwiftUI

@main
struct StandByPlusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings = StandBySettings()
    @StateObject private var callService = CallService()
    @StateObject private var musicService = MusicService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(callService)
                .environmentObject(musicService)
                .preferredColorScheme(settings.resolvedColorScheme)
                .onAppear {
                    callService.startObserving()
                    musicService.startObserving()
                }
        }
    }
}
