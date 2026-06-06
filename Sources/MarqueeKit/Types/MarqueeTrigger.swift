import Foundation

/// Defines what causes the marquee to begin scrolling.
///
/// ```swift
/// MarqueeText("Tap to reveal")
///     .trigger(.tap)
/// ```
public enum MarqueeTrigger: Sendable {
    /// Scrolling starts automatically as soon as the view appears
    /// and content overflows. This is the default.
    case automatic

    /// Content is static until the user taps; it then performs one
    /// full scroll cycle and returns to the resting position.
    case tap

    /// Scrolling is controlled entirely by the application via
    /// ``MarqueeEngine/start()`` and ``MarqueeEngine/reset()``.
    case programmatic
}
