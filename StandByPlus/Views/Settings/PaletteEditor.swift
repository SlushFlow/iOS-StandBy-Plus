import SwiftUI

/// Edits a single `ThemePalette` with live preview, preset shortcuts, and a
/// color well for every role.
struct PaletteEditor: View {
    var title: String
    @Binding var palette: ThemePalette

    var body: some View {
        Form {
            Section {
                preview
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section("Presets") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ThemePalette.presets, id: \.name) { preset in
                            Button {
                                withAnimation { palette = preset.palette }
                            } label: {
                                VStack(spacing: 6) {
                                    swatch(preset.palette)
                                    Text(preset.name)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Custom Colors") {
                colorRow("Background", $palette.background)
                colorRow("Background (Gradient End)", $palette.backgroundSecondary)
                colorRow("Surface / Cards", $palette.surface)
                colorRow("Primary Text", $palette.primaryText)
                colorRow("Secondary Text", $palette.secondaryText)
                colorRow("Accent", $palette.accent)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var preview: some View {
        ZStack {
            palette.backgroundGradient
            VStack(alignment: .leading, spacing: 6) {
                Text("9:41")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText.color)
                Text("Tuesday, June 10")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryText.color)
                Capsule()
                    .fill(palette.accent.color)
                    .frame(width: 90, height: 8)
                    .padding(.top, 4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.vertical, 6)
    }

    private func swatch(_ p: ThemePalette) -> some View {
        ZStack {
            p.backgroundGradient
            Circle().fill(p.accent.color).frame(width: 16, height: 16)
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.white.opacity(0.15)))
    }

    private func colorRow(_ label: String, _ binding: Binding<RGBAColor>) -> some View {
        ColorPicker(label, selection: Binding(
            get: { binding.wrappedValue.color },
            set: { binding.wrappedValue = RGBAColor($0) }
        ), supportsOpacity: true)
    }
}
