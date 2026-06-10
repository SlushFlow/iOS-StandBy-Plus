import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var widgetManager: WidgetManager

    @State private var selectedTab: SettingsTab = .theme

    enum SettingsTab: String, CaseIterable {
        case theme = "Theme"
        case clock = "Clock"
        case widgets = "Widgets"
        case display = "Display"

        var icon: String {
            switch self {
            case .theme: return "paintpalette.fill"
            case .clock: return "clock.fill"
            case .widgets: return "square.grid.2x2.fill"
            case .display: return "sun.max.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        isPresented = false
                    }
                }

            HStack(spacing: 0) {
                Spacer()
                settingsPanel
                    .frame(width: 340)
            }
        }
    }

    private var settingsPanel: some View {
        VStack(spacing: 0) {
            header

            tabBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    switch selectedTab {
                    case .theme:
                        themeSettings
                    case .clock:
                        clockSettings
                    case .widgets:
                        widgetSettings
                    case .display:
                        displaySettings
                    }
                }
                .padding(20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(themeManager.colors.background)
                .shadow(color: .black.opacity(0.5), radius: 30, x: -10)
                .ignoresSafeArea()
        )
    }

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.colors.textPrimary)
            Spacer()
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    isPresented = false
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.colors.textSecondary)
            }
        }
        .padding(20)
        .padding(.top, 40)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16))
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(selectedTab == tab ? themeManager.colors.primary : themeManager.colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == tab ? themeManager.colors.primary.opacity(0.1) : Color.clear)
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Theme Settings
    private var themeSettings: some View {
        VStack(spacing: 16) {
            settingsSection(title: "Mode") {
                Toggle("Auto Day/Night", isOn: $themeManager.autoDayNight)
                    .tint(themeManager.colors.accent)
                    .foregroundColor(themeManager.colors.textPrimary)

                if !themeManager.autoDayNight {
                    HStack(spacing: 12) {
                        modeButton(title: "Day", icon: "sun.max.fill", isSelected: themeManager.timeOfDay == .day) {
                            themeManager.timeOfDay = .day
                        }
                        modeButton(title: "Night", icon: "moon.fill", isSelected: themeManager.timeOfDay == .night) {
                            themeManager.timeOfDay = .night
                        }
                    }
                }
            }

            settingsSection(title: "Day Colors") {
                colorRow(label: "Primary", hex: $themeManager.dayColors.primaryHex)
                colorRow(label: "Secondary", hex: $themeManager.dayColors.secondaryHex)
                colorRow(label: "Accent", hex: $themeManager.dayColors.accentHex)
                colorRow(label: "Background", hex: $themeManager.dayColors.backgroundHex)
                colorRow(label: "Surface", hex: $themeManager.dayColors.surfaceHex)
                colorRow(label: "Text", hex: $themeManager.dayColors.textPrimaryHex)
            }

            settingsSection(title: "Night Colors") {
                colorRow(label: "Primary", hex: $themeManager.nightColors.primaryHex)
                colorRow(label: "Secondary", hex: $themeManager.nightColors.secondaryHex)
                colorRow(label: "Accent", hex: $themeManager.nightColors.accentHex)
                colorRow(label: "Background", hex: $themeManager.nightColors.backgroundHex)
                colorRow(label: "Surface", hex: $themeManager.nightColors.surfaceHex)
                colorRow(label: "Text", hex: $themeManager.nightColors.textPrimaryHex)
            }

            settingsSection(title: "Presets") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    presetButton(name: "Ocean", colors: ThemeColors(
                        primaryHex: "#0984E3", secondaryHex: "#6C5CE7", accentHex: "#00B894",
                        backgroundHex: "#0A1628", surfaceHex: "#132238", textPrimaryHex: "#DFE6E9", textSecondaryHex: "#74B9FF"
                    ))
                    presetButton(name: "Sunset", colors: ThemeColors(
                        primaryHex: "#E17055", secondaryHex: "#FDCB6E", accentHex: "#E84393",
                        backgroundHex: "#1A0A1A", surfaceHex: "#2D1B2E", textPrimaryHex: "#FFEAA7", textSecondaryHex: "#DDA0DD"
                    ))
                    presetButton(name: "Forest", colors: ThemeColors(
                        primaryHex: "#00B894", secondaryHex: "#55EFC4", accentHex: "#81ECEC",
                        backgroundHex: "#0A1A14", surfaceHex: "#132E22", textPrimaryHex: "#DFE6E9", textSecondaryHex: "#55EFC4"
                    ))
                    presetButton(name: "Midnight", colors: ThemeColors(
                        primaryHex: "#A29BFE", secondaryHex: "#6C5CE7", accentHex: "#FD79A8",
                        backgroundHex: "#0D0D1A", surfaceHex: "#1A1A30", textPrimaryHex: "#E0E0F0", textSecondaryHex: "#8080A0"
                    ))
                    presetButton(name: "Cherry", colors: ThemeColors(
                        primaryHex: "#FF6B6B", secondaryHex: "#EE5A24", accentHex: "#FFD93D",
                        backgroundHex: "#1A0808", surfaceHex: "#2D1414", textPrimaryHex: "#FFE8E8", textSecondaryHex: "#FF9999"
                    ))
                    presetButton(name: "Arctic", colors: ThemeColors(
                        primaryHex: "#74B9FF", secondaryHex: "#A3D8F4", accentHex: "#B8E6FF",
                        backgroundHex: "#0A1420", surfaceHex: "#142030", textPrimaryHex: "#E8F4FD", textSecondaryHex: "#7DB8DA"
                    ))
                }
            }
        }
    }

    // MARK: - Clock Settings
    private var clockSettings: some View {
        VStack(spacing: 16) {
            settingsSection(title: "Style") {
                ForEach(ClockStyle.allCases, id: \.self) { style in
                    Button(action: { settingsManager.clockStyle = style }) {
                        HStack {
                            Text(style.displayName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(themeManager.colors.textPrimary)
                            Spacer()
                            if settingsManager.clockStyle == style {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(themeManager.colors.accent)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }

            settingsSection(title: "Options") {
                Toggle("Show Seconds", isOn: $settingsManager.showSeconds)
                    .tint(themeManager.colors.accent)
                    .foregroundColor(themeManager.colors.textPrimary)

                Toggle("24-Hour Format", isOn: $settingsManager.use24Hour)
                    .tint(themeManager.colors.accent)
                    .foregroundColor(themeManager.colors.textPrimary)

                Toggle("Show Date", isOn: $settingsManager.showDate)
                    .tint(themeManager.colors.accent)
                    .foregroundColor(themeManager.colors.textPrimary)
            }
        }
    }

    // MARK: - Widget Settings
    private var widgetSettings: some View {
        VStack(spacing: 16) {
            settingsSection(title: "Add Widget") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(WidgetType.allCases) { type in
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                widgetManager.addWidget(type: type, size: .medium)
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(themeManager.colors.primary)
                                Text(type.displayName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(themeManager.colors.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(themeManager.colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(themeManager.colors.primary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }

            settingsSection(title: "Active Widgets (\(widgetManager.widgets.count))") {
                ForEach(widgetManager.widgets) { widget in
                    HStack {
                        Image(systemName: widget.type.icon)
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.colors.primary)
                            .frame(width: 30)

                        Text(widget.type.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.colors.textPrimary)

                        Spacer()

                        Text(widget.size.displayName)
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.colors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(themeManager.colors.surface)
                            )

                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                widgetManager.removeWidget(id: widget.id)
                            }
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    widgetManager.isEditing.toggle()
                    isPresented = false
                }
            }) {
                HStack {
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                    Text("Arrange Widgets")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(themeManager.colors.primary)
                )
            }
        }
    }

    // MARK: - Display Settings
    private var displaySettings: some View {
        VStack(spacing: 16) {
            settingsSection(title: "Screen") {
                Toggle("Keep Screen On", isOn: $settingsManager.keepScreenOn)
                    .tint(themeManager.colors.accent)
                    .foregroundColor(themeManager.colors.textPrimary)
            }
        }
    }

    // MARK: - Helper Views
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(themeManager.colors.textSecondary)
                .textCase(.uppercase)

            VStack(spacing: 10) {
                content()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(themeManager.colors.surface.opacity(0.6))
            )
        }
    }

    private func colorRow(label: String, hex: Binding<String>) -> some View {
        HStack {
            Circle()
                .fill(Color(hex: hex.wrappedValue))
                .frame(width: 24, height: 24)
                .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1))

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(themeManager.colors.textPrimary)

            Spacer()

            TextField("", text: hex)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(themeManager.colors.textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeManager.colors.background)
                )
        }
    }

    private func modeButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? themeManager.colors.primary : themeManager.colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? themeManager.colors.primary.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? themeManager.colors.primary.opacity(0.3) : themeManager.colors.textSecondary.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }

    private func presetButton(name: String, colors: ThemeColors) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                if themeManager.timeOfDay == .day {
                    themeManager.dayColors = colors
                } else {
                    themeManager.nightColors = colors
                }
            }
        }) {
            VStack(spacing: 6) {
                HStack(spacing: 3) {
                    Circle().fill(Color(hex: colors.primaryHex)).frame(width: 14, height: 14)
                    Circle().fill(Color(hex: colors.secondaryHex)).frame(width: 14, height: 14)
                    Circle().fill(Color(hex: colors.accentHex)).frame(width: 14, height: 14)
                }
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: colors.backgroundHex))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(hex: colors.primaryHex).opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}
