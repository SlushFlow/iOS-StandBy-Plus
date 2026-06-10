import SwiftUI

@main
struct StandbyPlusApp: App {
    @StateObject private var viewModel = StandbyPlusViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(viewModel.interfaceStyle.preferredScheme)
        }
    }
}
