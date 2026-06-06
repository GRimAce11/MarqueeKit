import CoreGraphics

/// Context used when computing an adaptive or custom scroll speed.
public struct MarqueeSpeedContext: Sendable {
    /// Measured width of the content being scrolled.
    public let contentWidth: CGFloat
    /// Width of the clipping container.
    public let containerWidth: CGFloat
    /// Pixels the content overflows beyond the container.
    public let overflowDistance: CGFloat
    /// Number of characters in the text, or 0 for non-text content.
    public let characterCount: Int
}

/// Determines how fast the marquee scrolls.
///
/// Use the static presets for common scenarios or `.custom` for full control.
///
/// ```swift
/// MarqueeText("Hello")
///     .speed(.adaptive)
///
/// MarqueeText("Hello")
///     .speed(.fixed(80))
/// ```
public struct MarqueeSpeed: @unchecked Sendable {
    let resolver: @Sendable (MarqueeSpeedContext) -> Double

    // MARK: Presets

    /// Automatically computes an ideal speed from content length and overflow distance.
    public static let adaptive = MarqueeSpeed { ctx in
        AdaptiveSpeedCalculator.compute(context: ctx)
    }

    /// 30 pixels per second.
    public static let slow = MarqueeSpeed { _ in 30 }

    /// 60 pixels per second.
    public static let medium = MarqueeSpeed { _ in 60 }

    /// 120 pixels per second.
    public static let fast = MarqueeSpeed { _ in 120 }

    // MARK: Factories

    /// A constant scroll rate expressed in pixels per second.
    public static func fixed(_ pixelsPerSecond: Double) -> MarqueeSpeed {
        MarqueeSpeed { _ in max(1, pixelsPerSecond) }
    }

    /// Provide your own speed calculation given the current content context.
    public static func custom(
        _ resolver: @escaping @Sendable (MarqueeSpeedContext) -> Double
    ) -> MarqueeSpeed {
        MarqueeSpeed(resolver: resolver)
    }
}

// MARK: - Adaptive computation

enum AdaptiveSpeedCalculator {
    static func compute(context: MarqueeSpeedContext) -> Double {
        let overflow = max(1, context.overflowDistance)
        // Target ~4 seconds for a comfortable read of typical ticker content.
        let targetDuration = 4.0 + log(overflow / 100 + 1) * 1.5
        return overflow / targetDuration
    }
}
