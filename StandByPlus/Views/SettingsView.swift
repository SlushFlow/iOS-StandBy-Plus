import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: StandBySettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $settings.appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }

                    Toggle("Auto day / night palettes", isOn: $settings.useAutoDayNight)
                    Toggle("Reduce motion", isOn: $settings.reduceMotion)
                }

                Section("StandBy Behavior") {
                    Toggle("Show call HUD", isOn: $settings.showCallHUD)
                    Toggle("Prioritize music widget when playing", isOn: $settings.showMusicWhenPlaying)
                }

                Section("Clock") {
                    Picker("Style", selection: $settings.clockStyle) {
                        ForEach(ClockStyle.allCases) { style in
                            Text(style.label).tag(style)
                        }
                    }

                    Picker("Font weight", selection: $settings.clockFontWeight) {
                        ForEach(ClockFontWeight.allCases) { weight in
                            Text(weight.id.capitalized).tag(weight)
                        }
                    }

                    Toggle("24-hour time", isOn: $settings.use24Hour)
                    Toggle("Show seconds", isOn: $settings.showSeconds)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    Text("Built for landscape nightstand use. Install via SideStore using the unsigned IPA from GitHub Actions releases.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
