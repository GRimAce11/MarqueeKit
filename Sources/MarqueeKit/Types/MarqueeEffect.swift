import SwiftUI

/// GPU-friendly visual effects applied during scrolling.
///
/// ```swift
/// MarqueeText("Live scores")
///     .effect(.wave)
/// ```
public enum MarqueeEffect: Sendable {
    /// No visual effect; plain scrolling.
    case none
    /// Characters oscillate vertically in a wave pattern.
    case wave
    /// Content layers scroll at slightly different rates creating depth.
    case parallax
    /// Subtle 3-D perspective tilt driven by scroll position.
    case depth
    /// Content bounces slightly when starting and looping.
    case elastic
}

// MARK: - Wave parameters

extension MarqueeEffect {
    /// Amplitude of oscillation for `.wave` effect (points).
    var waveAmplitude: CGFloat { 4 }

    /// Frequency multiplier for `.wave` effect.
    var waveFrequency: Double { 2.5 }

    /// Depth tilt angle for `.depth` effect (radians).
    var depthAngle: Double { 0.05 }

    /// Parallax displacement scale for `.parallax` effect.
    var parallaxScale: CGFloat { 0.08 }
}
