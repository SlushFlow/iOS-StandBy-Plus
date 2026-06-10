import SwiftUI
import MediaPlayer

/// Wraps MPVolumeView so the slider controls real system volume.
struct SystemVolumeSlider: UIViewRepresentable {
    var tint: UIColor

    func makeUIView(context: Context) -> MPVolumeView {
        let view = MPVolumeView(frame: .zero)
        view.tintColor = tint
        if let slider = view.subviews.compactMap({ $0 as? UISlider }).first {
            slider.minimumTrackTintColor = tint
            slider.maximumTrackTintColor = tint.withAlphaComponent(0.25)
        }
        return view
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        uiView.tintColor = tint
        if let slider = uiView.subviews.compactMap({ $0 as? UISlider }).first {
            slider.minimumTrackTintColor = tint
            slider.maximumTrackTintColor = tint.withAlphaComponent(0.25)
        }
    }
}

/// A clean capsule-track slider used for scrubbing through the song.
struct ScrubSlider: View {
    @Binding var value: TimeInterval
    let range: ClosedRange<TimeInterval>
    var tint: Color
    var track: Color
    var onEditingChanged: (Bool) -> Void

    @State private var dragging = false

    var body: some View {
        GeometryReader { geo in
            let fraction = range.upperBound > range.lowerBound
                ? CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
                : 0
            let clamped = min(max(fraction, 0), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(track)
                    .frame(height: dragging ? 12 : 7)
                Capsule()
                    .fill(tint)
                    .frame(width: max(geo.size.width * clamped, dragging ? 12 : 7), height: dragging ? 12 : 7)
            }
            .frame(height: geo.size.height)
            .contentShape(Rectangle())
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: dragging)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !dragging {
                            dragging = true
                            onEditingChanged(true)
                        }
                        let fraction = min(max(gesture.location.x / geo.size.width, 0), 1)
                        value = range.lowerBound + TimeInterval(fraction) * (range.upperBound - range.lowerBound)
                    }
                    .onEnded { _ in
                        dragging = false
                        onEditingChanged(false)
                    }
            )
        }
        .frame(height: 24)
    }
}
