import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var widgets: WidgetStore
    @EnvironmentObject private var music: MusicController
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    NavigationLink {
                        ThemeSettingsView()
                    } label: {
                        Label("Colors & Night Mode", systemImage: "paintpalette.fill")
                    }
                    NavigationLink {
                        ClockSettingsView()
                    } label: {
                        Label("Clock", systemImage: "clock.fill")
                    }
                }

                Section("Widgets") {
                    ForEach(WidgetKind.allCases) { kind in
                        Button {
                            widgets.add(kind)
                            Haptics.success()
                        } label: {
                            HStack {
                                Label(kind.name, systemImage: kind.symbol)
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    Button(role: .destructive) {
                        widgets.resetLayout()
                    } label: {
                        Label("Reset Layout", systemImage: "arrow.counterclockwise")
                    }
                }

                Section {
                    Picker("Preferred Music App", selection: $music.preferredApp) {
                        ForEach(MusicApp.allCases) { app in
                            Text(app.name).tag(app.rawValue)
                        }
                    }
                } header: {
                    Text("Music")
                } footer: {
                    Text("Playback controls work with the system player (Apple Music). The volume slider always controls real device volume. \"Open Music App\" jumps straight into your preferred app.")
                }

                Section {
                    LabeledContent("Version", value: "1.0.0")
                } header: {
                    Text("About")
                } footer: {
                    Text("StandBy+ keeps the screen awake while open. Long-press any widget to move it like a window, resize it between Medium and Huge, or remove it. During calls, a HUD appears with quick controls; iOS only allows full call control from the app that owns the call, so quick-open buttons are always one tap away.")
                }
            }
            .navigationTitle("StandBy+ Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large, .medium])
    }
}

struct ThemeSettingsView: View {
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Form {
            Section("Mode") {
                Picker("Theme Mode", selection: $theme.mode) {
                    ForEach(ThemeMode.allCases) { mode in
                        Label(mode.label, systemImage: mode.symbol).tag(mode)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()

                if theme.mode == .auto {
                    DatePicker(
                        "Night starts",
                        selection: minutesBinding($theme.nightStartMinutes),
                        displayedComponents: .hourAndMinute
                    )
                    DatePicker(
                        "Night ends",
                        selection: minutesBinding($theme.nightEndMinutes),
                        displayedComponents: .hourAndMinute
                    )
                }
            }

            Section("Presets") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ThemePreset.all) { preset in
                            Button {
                                theme.applyPreset(preset)
                                Haptics.success()
                            } label: {
                                VStack(spacing: 6) {
                                    HStack(spacing: 0) {
                                        preset.day.background.color
                                        preset.night.background.color
                                    }
                                    .frame(width: 76, height: 46)
                                    .overlay(
                                        Circle()
                                            .fill(preset.night.accent.color)
                                            .frame(width: 14, height: 14)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                                    )
                                    Text(preset.name)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            PaletteEditorSection(title: "Day Colors", palette: $theme.day)
            PaletteEditorSection(title: "Night Colors", palette: $theme.night)
        }
        .navigationTitle("Colors & Night Mode")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func minutesBinding(_ binding: Binding<Int>) -> Binding<Date> {
        Binding<Date>(
            get: {
                let hour = binding.wrappedValue / 60
                let minute = binding.wrappedValue % 60
                return Calendar.current.date(
                    bySettingHour: hour, minute: minute, second: 0, of: Date()
                ) ?? Date()
            },
            set: { date in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                binding.wrappedValue = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
            }
        )
    }
}

private struct PaletteEditorSection: View {
    let title: String
    @Binding var palette: Palette

    var body: some View {
        Section(title) {
            ColorPicker("Background", selection: $palette.background.asColor, supportsOpacity: false)
            ColorPicker("Widget Background", selection: $palette.widgetBackground.asColor, supportsOpacity: true)
            ColorPicker("Primary Text", selection: $palette.primaryText.asColor, supportsOpacity: false)
            ColorPicker("Secondary Text", selection: $palette.secondaryText.asColor, supportsOpacity: false)
            ColorPicker("Accent", selection: $palette.accent.asColor, supportsOpacity: false)
            VStack(alignment: .leading, spacing: 6) {
                Text("Extra Dimming — \(Int(palette.dim * 100))%")
                    .font(.subheadline)
                Slider(value: $palette.dim, in: 0...0.6)
            }
        }
    }
}

struct ClockSettingsView: View {
    @EnvironmentObject private var prefs: ClockPreferences
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Form {
            Section {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(theme.palette.widgetBackground.color)
                    ClockWidgetView()
                }
                .frame(height: 150)
                .listRowBackground(theme.palette.background.color)
            } header: {
                Text("Preview")
            }

            Section("Face") {
                Picker("Clock Face", selection: $prefs.face) {
                    ForEach(ClockFace.allCases) { face in
                        Label(face.name, systemImage: face.symbol).tag(face)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section("Style") {
                Picker("Font", selection: $prefs.fontStyle) {
                    ForEach(ClockFontStyle.allCases) { style in
                        Text(style.name).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Show Seconds", isOn: $prefs.showSeconds)
                Toggle("24-Hour Time", isOn: $prefs.use24Hour)
                Toggle("Show Date", isOn: $prefs.showDate)
            }

            Section {
                Toggle("Custom Clock Color", isOn: $prefs.useCustomColor)
                if prefs.useCustomColor {
                    ColorPicker("Clock Color", selection: $prefs.customColor.asColor, supportsOpacity: false)
                }
            } footer: {
                Text("When off, the clock follows your theme's text color.")
            }
        }
        .navigationTitle("Clock")
        .navigationBarTitleDisplayMode(.inline)
    }
}
