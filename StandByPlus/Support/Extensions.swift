import SwiftUI
import UIKit

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func rigid() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

enum AppLauncher {
    /// Opens the first URL the system can handle, returns whether anything opened.
    @discardableResult
    static func open(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            return false
        }
        UIApplication.shared.open(url)
        return true
    }
}

extension TimeInterval {
    /// "3:07" / "1:02:45" style formatting.
    var playbackString: String {
        guard isFinite, self >= 0 else { return "0:00" }
        let total = Int(self)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension View {
    /// Standard springy animation used across the app for a cohesive feel.
    func smoothSpring<V: Equatable>(value: V) -> some View {
        animation(.spring(response: 0.45, dampingFraction: 0.82), value: value)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
