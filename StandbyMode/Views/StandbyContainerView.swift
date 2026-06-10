import SwiftUI

struct StandbyContainerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var widgetManager: WidgetManager
    @EnvironmentObject var callManager: CallManager
    @EnvironmentObject var musicManager: MusicPlayerManager
    @EnvironmentObject var settingsManager: SettingsManager

    @State private var showSettings = false
    @State private var backgroundOpacity: Double = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundLayer

                widgetCanvas(in: geometry)

                callOverlay

                settingsButton

                if showSettings {
                    SettingsView(isPresented: $showSettings)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = settingsManager.keepScreenOn
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            themeManager.colors.background
                .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [
                    themeManager.colors.primary.opacity(0.08),
                    themeManager.colors.background
                ]),
                center: .topLeading,
                startRadius: 100,
                endRadius: 600
            )
            .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [
                    themeManager.colors.secondary.opacity(0.05),
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }

    private func widgetCanvas(in geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(widgetManager.widgets) { widget in
                WidgetContainerView(widget: widget, screenSize: geometry.size)
                    .zIndex(Double(widget.zIndex))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var callOverlay: some View {
        Group {
            if callManager.callState != .none {
                CallHUDView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .zIndex(100)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: callManager.callState != .none)
    }

    private var settingsButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        showSettings.toggle()
                    }
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.colors.textSecondary)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(themeManager.colors.surface.opacity(0.8))
                                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                        )
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
            }
            Spacer()
        }

        VStack {
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        widgetManager.isEditing.toggle()
                    }
                }) {
                    Image(systemName: widgetManager.isEditing ? "checkmark.circle.fill" : "square.grid.2x2.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(widgetManager.isEditing ? themeManager.colors.accent : themeManager.colors.textSecondary)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(themeManager.colors.surface.opacity(0.8))
                                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                        )
                }
                .padding(.top, 50)
                .padding(.leading, 20)
                Spacer()
            }
            Spacer()
        }
    }
}
