import SwiftUI

struct CustomizationView: View {
    @EnvironmentObject private var settings: StandBySettings
    @Environment(\.dismiss) private var dismiss

    @State private var selectedWidgetID: UUID?
    @State private var editingDayPalette = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    paletteSection
                    widgetLayoutSection
                    widgetEditorSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Customize")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        settings.resetWidgetsToDefault()
                        settings.dayPalette = .cozyLight
                        settings.nightPalette = .cozyDark
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var paletteSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Colors")
                .font(.title3.weight(.semibold))

            Picker("Editing", selection: $editingDayPalette) {
                Text("Day").tag(true)
                Text("Night").tag(false)
            }
            .pickerStyle(.segmented)

            PaletteEditor(
                palette: editingDayPalette ? $settings.dayPalette : $settings.nightPalette,
                presets: editingDayPalette
                    ? [.cozyLight, .warmSunrise]
                    : [.cozyDark, .midnight]
            )
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var widgetLayoutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Widget Windows")
                .font(.title3.weight(.semibold))

            Text("Place widgets like floating windows. Choose medium or huge sizes and drag positions on the grid.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(settings.widgets) { widget in
                WidgetEditorRow(
                    widget: widget,
                    isSelected: selectedWidgetID == widget.id,
                    onSelect: { selectedWidgetID = widget.id },
                    onToggleVisibility: { toggleVisibility(widget) },
                    onResize: { size in settings.resizeWidget(widget, to: size) },
                    onMove: { column, row in settings.moveWidget(widget, toColumn: column, toRow: row) }
                )
            }

            Menu {
                ForEach(WidgetType.allCases) { type in
                    Button(type.label) {
                        addWidget(type: type)
                    }
                }
            } label: {
                Label("Add Widget Window", systemImage: "plus.rectangle.on.rectangle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var widgetEditorSection: some View {
        if let id = selectedWidgetID,
           let widget = settings.widgets.first(where: { $0.id == id }) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Selected: \(widget.type.label)")
                    .font(.headline)

                GridPositionPicker(
                    column: widget.column,
                    row: widget.row,
                    span: widget.size.gridSpan
                ) { column, row in
                    settings.moveWidget(widget, toColumn: column, toRow: row)
                }
            }
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func toggleVisibility(_ widget: WidgetWindow) {
        guard let index = settings.widgets.firstIndex(where: { $0.id == widget.id }) else { return }
        settings.widgets[index].isVisible.toggle()
    }

    private func addWidget(type: WidgetType) {
        let newWidget = WidgetWindow(
            type: type,
            size: .medium,
            column: 0,
            row: 0
        )
        settings.widgets.append(newWidget)
        selectedWidgetID = newWidget.id
    }
}

struct PaletteEditor: View {
    @Binding var palette: ThemePalette
    let presets: [ThemePalette]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Presets")
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 10) {
                ForEach(Array(presets.enumerated()), id: \.offset) { _, preset in
                    Button {
                        palette = preset
                    } label: {
                        HStack(spacing: 4) {
                            Circle().fill(preset.background.color).frame(width: 16, height: 16)
                            Circle().fill(preset.accent.color).frame(width: 16, height: 16)
                        }
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            ColorSliderRow(title: "Background", color: $palette.background)
            ColorSliderRow(title: "Surface", color: $palette.surface)
            ColorSliderRow(title: "Accent", color: $palette.accent)
            ColorSliderRow(title: "Primary text", color: $palette.textPrimary)
            ColorSliderRow(title: "Secondary text", color: $palette.textSecondary)
        }
    }
}

struct ColorSliderRow: View {
    let title: String
    @Binding var color: CodableColor

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.color)
                    .frame(width: 28, height: 20)
            }

            HStack {
                Text("R")
                Slider(value: $color.red, in: 0...1)
            }
            HStack {
                Text("G")
                Slider(value: $color.green, in: 0...1)
            }
            HStack {
                Text("B")
                Slider(value: $color.blue, in: 0...1)
            }
        }
    }
}

struct WidgetEditorRow: View {
    let widget: WidgetWindow
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleVisibility: () -> Void
    let onResize: (WidgetSize) -> Void
    let onMove: (Int, Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(widget.type.label, systemImage: widget.type.systemImage)
                    .font(.headline)
                Spacer()
                Toggle("Visible", isOn: Binding(
                    get: { widget.isVisible },
                    set: { _ in onToggleVisibility() }
                ))
                .labelsHidden()
            }

            HStack {
                Picker("Size", selection: Binding(
                    get: { widget.size },
                    set: { onResize($0) }
                )) {
                    ForEach(WidgetSize.allCases) { size in
                        Text(size.label).tag(size)
                    }
                }
                .pickerStyle(.segmented)

                Button("Edit", action: onSelect)
                    .buttonStyle(.bordered)
            }

            Stepper("Column: \(widget.column)") {
                onMove(widget.column + 1, widget.row)
            } onDecrement: {
                onMove(max(0, widget.column - 1), widget.row)
            }

            Stepper("Row: \(widget.row)") {
                onMove(widget.column, widget.row + 1)
            } onDecrement: {
                onMove(widget.column, max(0, widget.row - 1))
            }
        }
        .padding(12)
        .background(isSelected ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct GridPositionPicker: View {
    let column: Int
    let row: Int
    let span: (columns: Int, rows: Int)
    let onSelect: (Int, Int) -> Void

    private let gridColumns = 8
    private let gridRows = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grid position")
                .font(.subheadline.weight(.semibold))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: gridColumns), spacing: 4) {
                ForEach(0..<(gridColumns * gridRows), id: \.self) { index in
                    let col = index % gridColumns
                    let r = index / gridColumns
                    let isOrigin = col == column && r == row
                    let isOccupied = col >= column && col < column + span.columns
                        && r >= row && r < row + span.rows

                    Button {
                        onSelect(col, r)
                    } label: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isOrigin ? Color.accentColor : (isOccupied ? Color.accentColor.opacity(0.35) : Color(.tertiarySystemFill)))
                            .frame(height: 18)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
