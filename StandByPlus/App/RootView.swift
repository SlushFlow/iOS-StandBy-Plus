import SwiftUI
import UIKit

/// The top-level StandBy surface. Hosts the swipeable widget / music pages, the
/// call HUD overlay, day/night theming, ambient motion, and the settings entry.
struct RootView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var nowPlaying: NowPlayingManager
    @EnvironmentObject private var calls: CallManager

    @State private var page: Int = 0   // 0 = widgets, 1 = music
    @State private var editing = false
    @State private var showSettings = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { ctx in
            let palette = settings.palette(at: ctx.date)
            let dim = settings.dimming(at: ctx.date)

            ZStack {
                AmbientBackground(animated: settings.ambientAnimation)
                    .environment(\.palette, palette)

                content
                    .environment(\.palette, palette)
                    .burnInDrift(enabled: settings.screenBurnProtection && !editing)

                // Night dimming veil.
                Color.black.opacity(dim)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                // Call HUD floats above everything.
                CallHUDView()
                    .environment(\.palette, palette)
                    .animation(.spring(response: 0.45, dampingFraction: 0.8), value: calls.call)
            }
            .environment(\.palette, palette)
            .animation(.easeInOut(duration: 0.6), value: settings.isNight(at: ctx.date))
        }
        .preferredColorScheme(.dark)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .sheet(isPresented: $showSettings) {
            SettingsView(editingWidgets: $editing)
        }
        .onChange(of: nowPlaying.hasContent) { _, hasContent in
            if hasContent && settings.autoShowMusic && !nowPlaying.isDemo {
                withAnimation(.spring) { page = 1 }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if editing {
            editingCanvas
        } else {
            pager
        }
    }

    // MARK: Pager (normal mode)

    private var pager: some View {
        ZStack(alignment: .top) {
            TabView(selection: $page) {
                WidgetCanvasView(editing: $editing)
                    .padding(24)
                    .tag(0)
                MusicView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(.container, edges: .bottom)

            topBar
        }
        .overlay(alignment: .bottom) { pageDots }
        // Long-press anywhere opens settings, like the stock StandBy.
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.6).onEnded { _ in
                showSettings = true
            }
        )
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                showSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .opacity(0.6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<2) { i in
                Circle()
                    .fill(.white.opacity(page == i ? 0.9 : 0.3))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.bottom, 14)
    }

    // MARK: Editing canvas

    private var editingCanvas: some View {
        ZStack(alignment: .top) {
            WidgetCanvasView(editing: $editing)
                .padding(24)

            HStack {
                Text("Arrange Widgets — drag to move, resize or remove")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                Button("Done") {
                    withAnimation { editing = false }
                }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)
        }
    }
}

// MARK: - Burn-in drift

private struct BurnInDrift: ViewModifier {
    var enabled: Bool
    func body(content: Content) -> some View {
        if enabled {
            TimelineView(.periodic(from: .now, by: 60)) { ctx in
                let minute = Calendar.current.component(.minute, from: ctx.date)
                let angle = Double(minute) / 60 * 2 * .pi
                content
                    .offset(x: CGFloat(cos(angle)) * 6, y: CGFloat(sin(angle)) * 6)
                    .animation(.easeInOut(duration: 2), value: minute)
            }
        } else {
            content
        }
    }
}

private extension View {
    func burnInDrift(enabled: Bool) -> some View {
        modifier(BurnInDrift(enabled: enabled))
    }
}
