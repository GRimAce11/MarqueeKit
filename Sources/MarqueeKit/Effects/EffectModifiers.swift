import SwiftUI

// MARK: - Wave effect

/// Applies a sinusoidal vertical displacement to a view.
@MainActor
struct WaveTextModifier: ViewModifier {
    var phase: Double
    let amplitude: CGFloat
    let frequency: Double

    func body(content: Content) -> some View {
        content
            .geometryGroup()
            .offset(y: amplitude * CGFloat(sin(phase * frequency * .pi * 2)))
    }
}

// MARK: - Depth effect

/// Applies a perspective-rotated appearance to content.
@MainActor
struct DepthEffectModifier: ViewModifier {
    let scrollProgress: Double
    let angle: Double

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .radians(sin(scrollProgress * .pi * 2) * angle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.4
            )
    }
}

// MARK: - Parallax effect

/// Creates a depth illusion by offsetting content relative to scroll position.
@MainActor
struct ParallaxEffectModifier: ViewModifier {
    let scrollOffset: CGFloat
    let scale: CGFloat

    func body(content: Content) -> some View {
        content.offset(x: scrollOffset * scale)
    }
}

// MARK: - Elastic bounce

/// Applies a spring-like scale when content enters the scroll frame.
@MainActor
struct ElasticBounceModifier: ViewModifier {
    var scale: CGFloat

    func body(content: Content) -> some View {
        content.scaleEffect(scale)
    }
}

// MARK: - View helpers

extension View {
    @MainActor
    func waveEffect(phase: Double, amplitude: CGFloat = 4, frequency: Double = 2.5) -> some View {
        modifier(WaveTextModifier(phase: phase, amplitude: amplitude, frequency: frequency))
    }

    @MainActor
    func depthEffect(progress: Double, angle: Double = 0.05) -> some View {
        modifier(DepthEffectModifier(scrollProgress: progress, angle: angle))
    }

    @MainActor
    func parallaxEffect(offset: CGFloat, scale: CGFloat = 0.08) -> some View {
        modifier(ParallaxEffectModifier(scrollOffset: offset, scale: scale))
    }
}
