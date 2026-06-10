import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var widgets: WidgetStore
    @EnvironmentObject private var calls: CallMonitor
    @EnvironmentObject private var music: MusicController

    @State private var editMode = false
    @State private var showSettings = false
    @State private var showChrome = false
    @State private var expandedMusic = false
    @State private var chromeHideTask: DispatchWorkItem?

    var body: some View {
        let palette = theme.palette

        ZStack {
            // Background — tappable to reveal the toolbar.
            palette.background.color
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    if editMode {
                        exitEditMode()
                    } else {
                        toggleChrome()
                    }
                }

            WidgetCanvasView(editMode: $editMode) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    expandedMusic = true
                }
            }

            // Night dim layer sits above widgets but below controls.
            Color.black
                .opacity(palette.dim)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            if showChrome || editMode {
                chrome
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if expandedMusic {
                MusicPlayerView {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        expandedMusic = false
                    }
                }
                .zIndex(20)
            }

            if calls.hasActivity || calls.statusMessage != nil {
                CallHUDView()
                    .zIndex(30)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: showChrome)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: editMode)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: calls.hasActivity)
        .animation(.easeInOut(duration: 0.8), value: theme.isNight)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    private var chrome: some View {
        let palette = theme.palette
        return VStack {
            Spacer()
            HStack(spacing: 14) {
                if editMode {
                    chromeButton(symbol: "checkmark", label: "Done", prominent: true) {
                        exitEditMode()
                    }
                    chromeButton(symbol: "plus", label: "Add Widget") {
                        showSettings = true
                    }
                    chromeButton(symbol: "arrow.counterclockwise", label: "Reset") {
                        widgets.resetLayout()
                    }
                } else {
                    chromeButton(symbol: "square.grid.2x2", label: "Edit") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            editMode = true
                        }
                    }
                    chromeButton(
                        symbol: theme.isNight ? "sun.max.fill" : "moon.fill",
                        label: theme.isNight ? "Day" : "Night"
                    ) {
                        theme.toggleDayNight()
                        scheduleChromeHide()
                    }
                    chromeButton(symbol: "gearshape.fill", label: "Settings") {
                        showSettings = true
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(Capsule().fill(palette.widgetBackground.color.opacity(0.55)))
                    .shadow(color: .black.opacity(0.3), radius: 18, y: 8)
            )
            .padding(.bottom, 18)
        }
    }

    private func chromeButton(
        symbol: String,
        label: String,
        prominent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        let palette = theme.palette
        return Button {
            Haptics.tap()
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(prominent ? palette.background.color : palette.primaryText.color)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle().fill(prominent ? palette.accent.color : palette.primaryText.color.opacity(0.08))
                    )
                Text(label)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(palette.secondaryText.color)
            }
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func toggleChrome() {
        showChrome.toggle()
        if showChrome {
            scheduleChromeHide()
        }
    }

    private func scheduleChromeHide() {
        chromeHideTask?.cancel()
        let task = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.4)) {
                showChrome = false
            }
        }
        chromeHideTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: task)
    }

    private func exitEditMode() {
        Haptics.success()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            editMode = false
        }
    }
}
