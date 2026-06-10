import SwiftUI

struct RootView: View {
    @EnvironmentObject private var settings: StandBySettings
    @State private var showSettings = false
    @State private var showCustomization = false
    @State private var isStandByActive = true

    var body: some View {
        ZStack {
            if isStandByActive {
                StandByView(
                    showSettings: $showSettings,
                    showCustomization: $showCustomization
                )
                .transition(.opacity.combined(with: .scale(scale: 1.02)))
            } else {
                OnboardingView(isStandByActive: $isStandByActive)
                    .transition(.opacity)
            }
        }
        .animation(SmoothAnimation.spring(reduceMotion: settings.reduceMotion), value: isStandByActive)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showCustomization) {
            CustomizationView()
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                isStandByActive = true
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var settings: StandBySettings
    @Binding var isStandByActive: Bool

    var body: some View {
        ZStack {
            settings.activePalette.background.color.ignoresSafeArea()

            VStack(spacing: 28) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(settings.activePalette.accent.color)
                    .symbolEffect(.pulse, options: .repeating)

                VStack(spacing: 10) {
                    Text("StandBy Plus")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(settings.activePalette.textPrimary.color)

                    Text("A cozy, customizable nightstand experience with calls, music, and window-style widgets.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(settings.activePalette.textSecondary.color)
                        .padding(.horizontal, 32)
                }

                Button {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    withAnimation(SmoothAnimation.spring(reduceMotion: settings.reduceMotion)) {
                        isStandByActive = true
                    }
                } label: {
                    Text("Enter StandBy Mode")
                        .font(.headline)
                        .frame(maxWidth: 280)
                        .padding(.vertical, 16)
                        .background(settings.activePalette.accent.color)
                        .foregroundStyle(Color.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .environment(\.themePalette, settings.activePalette)
    }
}
