import SwiftUI

@main
struct StandByPlusApp: App {
    @StateObject private var store = StandByStore()

    var body: some Scene {
        WindowGroup {
            StandByDashboardView()
                .environmentObject(store)
        }
    }
}
