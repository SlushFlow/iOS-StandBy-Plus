import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var calls: CallManager
    @Environment(\.dismiss) private var dismiss
    @Binding var editingWidgets: Bool

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                clockSection
                widgetsSection
                dayNightSection
                ambienceSection
                behaviorSection
                demoSection
                aboutSection
            }
            .navigationTitle("StandBy+ Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: Appearance

    private var appearanceSection: some View {
        Section("Colors") {
            NavigationLink {
                PaletteEditor(title: "Day Theme", palette: $settings.dayPalette)
            } label: {
                Label("Day Theme", systemImage: "sun.max.fill")
            }
            NavigationLink {
                PaletteEditor(title: "Night Theme", palette: $settings.nightPalette)
            } label: {
                Label("Night Theme", systemImage: "moon.stars.fill")
            }
        }
    }

    // MARK: Clock

    private var clockSection: some View {
        Section("Clock") {
            Picker("Face", selection: $settings.clockStyle) {
                ForEach(ClockStyle.allCases) { style in
                    Label(style.title, systemImage: style.systemImage).tag(style)
                }
            }
            Picker("Font", selection: $settings.fontStyle) {
                ForEach(ClockFontStyle.allCases) { Text($0.title).tag($0) }
            }
            Toggle("24-Hour Time", isOn: $settings.use24Hour)
            Toggle("Show Seconds", isOn: $settings.showSeconds)
            Toggle("Accent Highlights", isOn: $settings.accentHighlights)
        }
    }

    // MARK: Widgets

    private var widgetsSection: some View {
        Section("Widgets") {
            Button {
                editingWidgets = true
                dismiss()
            } label: {
                Label("Arrange Widgets", systemImage: "rectangle.3.group")
            }
            Menu {
                ForEach(WidgetKind.allCases) { kind in
                    Button {
                        addWidget(kind)
                    } label: {
                        Label(kind.title, systemImage: kind.systemImage)
                    }
                }
            } label: {
                Label("Add Widget", systemImage: "plus.app")
            }
            if !settings.widgets.isEmpty {
                ForEach(settings.widgets) { widget in
                    HStack {
                        Label(widget.kind.title, systemImage: widget.kind.systemImage)
                        Spacer()
                        Text(widget.size.title)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { settings.widgets.remove(atOffsets: $0) }
            }
        }
    }

    // MARK: Day / Night

    private var dayNightSection: some View {
        Section("Day & Night") {
            Toggle("Automatic Day/Night", isOn: $settings.autoDayNight)
            if settings.autoDayNight {
                Stepper("Night starts at \(hourLabel(settings.nightStartHour))",
                        value: $settings.nightStartHour, in: 0...23)
                Stepper("Day starts at \(hourLabel(settings.dayStartHour))",
                        value: $settings.dayStartHour, in: 0...23)
            } else {
                Toggle("Night Mode", isOn: $settings.manualNightMode)
            }
            VStack(alignment: .leading) {
                Text("Night Dimming")
                Slider(value: $settings.nightDimming, in: 0...0.7)
            }
        }
    }

    // MARK: Ambience

    private var ambienceSection: some View {
        Section("Ambience") {
            Toggle("Ambient Animation", isOn: $settings.ambientAnimation)
            Toggle("Burn-in Protection Drift", isOn: $settings.screenBurnProtection)
        }
    }

    // MARK: Behavior

    private var behaviorSection: some View {
        Section("Behavior") {
            Toggle("Auto-show Music", isOn: $settings.autoShowMusic)
            Toggle("Auto-show Calls", isOn: $settings.autoShowCalls)
        }
    }

    // MARK: Demo

    private var demoSection: some View {
        Section {
            Button {
                calls.simulateIncoming()
                dismiss()
            } label: {
                Label("Preview Incoming Call", systemImage: "phone.arrow.down.left")
            }
            Button {
                calls.simulateActive()
                dismiss()
            } label: {
                Label("Preview Active Call", systemImage: "phone.connection")
            }
        } header: {
            Text("Call HUD Preview")
        } footer: {
            Text("Real calls from the Phone app and CallKit-based apps (WhatsApp, Messenger, Telegram, etc.) trigger the HUD automatically. These buttons let you preview it now.")
        }
    }

    // MARK: About

    private var aboutSection: some View {
        Section {
            Button(role: .destructive) {
                withAnimation { settings.resetToDefaults() }
            } label: {
                Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
            }
        } footer: {
            Text("StandBy+ \(Bundle.main.appVersion) — a cozy overhaul for iOS StandBy.")
        }
    }

    // MARK: Helpers

    private func addWidget(_ kind: WidgetKind) {
        let new = PlacedWidget(kind: kind, size: .medium, centerX: 0.5, centerY: 0.5)
        settings.widgets.append(new)
    }

    private func hourLabel(_ hour: Int) -> String {
        var comps = DateComponents(); comps.hour = hour
        let date = Calendar.current.date(from: comps) ?? Date()
        let f = DateFormatter(); f.dateFormat = settings.use24Hour ? "HH:mm" : "h a"
        return f.string(from: date)
    }
}

extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}
