import SwiftUI

struct StandByDashboardView: View {
    @EnvironmentObject private var store: StandByStore
    private let playbackTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .topTrailing) {
            dashboardBackground

                    GeometryReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {
                        topBar

                        if proxy.size.width > proxy.size.height {
                            HStack(alignment: .top, spacing: 20) {
                                ClockPanel(mode: store.currentMode)
                                    .environmentObject(store)
                                    .frame(maxWidth: proxy.size.width * 0.33, alignment: .top)

                                VStack(spacing: 20) {
                                    MusicPanel(mode: store.currentMode)
                                        .environmentObject(store)
                                    WidgetGrid(mode: store.currentMode)
                                        .environmentObject(store)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        } else {
                            ClockPanel(mode: store.currentMode)
                                .environmentObject(store)
                            MusicPanel(mode: store.currentMode)
                                .environmentObject(store)
                            WidgetGrid(mode: store.currentMode)
                                .environmentObject(store)
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 36)
                }
            }

            if let call = store.primaryCall {
                CallHUDView(session: call, mode: store.currentMode)
                    .environmentObject(store)
                    .padding(24)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(store.currentMode == .night ? .dark : .light)
        .animation(.spring(response: 0.55, dampingFraction: 0.88), value: store.preferences)
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: store.calls)
        .sheet(isPresented: $store.showingCustomization) {
            CustomizationSheet()
                .environmentObject(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onReceive(playbackTimer) { _ in
            store.tick()
        }
    }

    private var dashboardBackground: some View {
        let background = store.preferences.backgroundColor(for: store.currentMode)
        let surface = store.preferences.surfaceColor(for: store.currentMode)
        let accent = store.preferences.accentColor(for: store.currentMode)

        return ZStack {
            LinearGradient(
                colors: [background, surface.opacity(0.95), background.opacity(0.96)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [accent.opacity(0.30), .clear],
                center: .topLeading,
                startRadius: 40,
                endRadius: 420
            )
            .offset(x: -110, y: -140)

            RadialGradient(
                colors: [accent.opacity(0.18), .clear],
                center: .bottomTrailing,
                startRadius: 60,
                endRadius: 460
            )
            .offset(x: 120, y: 160)
        }
    }

    private var topBar: some View {
        let text = store.preferences.textColor(for: store.currentMode)
        let accent = store.preferences.accentColor(for: store.currentMode)

        return HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("StandBy Plus")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(text)
                Text("A softer, deeply customizable standby dashboard")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(text.opacity(0.72))
            }

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                ForEach(StandByMode.allCases) { mode in
                    Button {
                        store.setMode(mode)
                    } label: {
                        Label(mode.title, systemImage: mode.symbol)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(mode == store.currentMode ? accent.opacity(0.22) : text.opacity(0.10))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(mode == store.currentMode ? accent.opacity(0.7) : .clear, lineWidth: 1)
                            )
                            .foregroundStyle(mode == store.currentMode ? accent : text)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                store.showingCustomization = true
            } label: {
                Label("Customize", systemImage: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(
                        Capsule()
                            .fill(accent.opacity(0.22))
                    )
                    .overlay(
                        Capsule()
                            .stroke(accent.opacity(0.5), lineWidth: 1)
                    )
                    .foregroundStyle(accent)
            }
            .buttonStyle(.plain)
        }
    }
}
