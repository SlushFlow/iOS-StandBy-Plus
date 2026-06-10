import SwiftUI

@main
struct StandByPlusApp: App {
    @StateObject private var viewModel = StandByViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
