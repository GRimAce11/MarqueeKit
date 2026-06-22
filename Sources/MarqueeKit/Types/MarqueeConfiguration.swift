import SwiftUI

/// The complete set of parameters that control a marquee's behavior and appearance.
///
/// You rarely construct this type directly. Instead, apply the SwiftUI view modifiers
/// on any marquee view and the SDK assembles the configuration for you.
///
/// ```swift
/// MarqueeText("Breaking news")
///     .speed(.adaptive)
///     .direction(.left)
///     .fadeEdges(true)
///     .pauseOnTouch(true)
///     .marqueeTheme(.glass)
/// ```
public struct MarqueeConfiguration: Sendable {
    // MARK: Motion

    /// How fast the content scrolls.
    public var speed: MarqueeSpeed

    /// The axis and direction of scrolling.
    public var direction: MarqueeDirection

    /// What triggers the animation to begin.
    public var trigger: MarqueeTrigger

    /// Reading-mode behaviour after each scroll cycle. By default the marquee
    /// scrolls one full loop, rests at the start for a couple of seconds, then
    /// loops again. Use ``MarqueeReadingMode/continuous`` for uninterrupted
    /// scrolling.
    public var readingMode: MarqueeReadingMode

    // MARK: Interaction

    /// When `true`, touching the marquee pauses the animation.
    public var pauseOnTouch: Bool

    // MARK: Appearance

    /// When `true`, a gradient fade is applied at the leading and trailing edges.
    public var fadeEdges: Bool

    /// Width in points of the edge fade gradient.
    public var fadeWidth: CGFloat

    /// Gap in points between the trailing edge of one copy and the leading
    /// edge of the next copy of the content (for looping).
    public var loopSpacing: CGFloat

    /// Optional visual effect applied during scrolling.
    public var effect: MarqueeEffect

    /// Visual theme applied to the container.
    public var theme: MarqueeTheme

    // MARK: Haptics

    /// Haptic feedback pattern.
    public var haptics: MarqueeHaptics

    // MARK: Multi-line

    /// Number of lines to display (horizontal marquee only).
    public var lineLimit: Int?

    // MARK: Performance

    /// Reduces animation overhead when running inside a widget or Live Activity.
    public var liveActivityOptimized: Bool

    // MARK: - Default

    public init(
        speed: MarqueeSpeed = .adaptive,
        direction: MarqueeDirection = .left,
        trigger: MarqueeTrigger = .automatic,
        readingMode: MarqueeReadingMode = .pauseAfterScroll(2),
        pauseOnTouch: Bool = false,
        fadeEdges: Bool = false,
        fadeWidth: CGFloat = 20,
        loopSpacing: CGFloat = 40,
        effect: MarqueeEffect = .none,
        theme: MarqueeTheme = .minimal,
        haptics: MarqueeHaptics = .none,
        lineLimit: Int? = nil,
        liveActivityOptimized: Bool = false
    ) {
        self.speed = speed
        self.direction = direction
        self.trigger = trigger
        self.readingMode = readingMode
        self.pauseOnTouch = pauseOnTouch
        self.fadeEdges = fadeEdges
        self.fadeWidth = fadeWidth
        self.loopSpacing = loopSpacing
        self.effect = effect
        self.theme = theme
        self.haptics = haptics
        self.lineLimit = lineLimit
        self.liveActivityOptimized = liveActivityOptimized
    }

    /// A configuration with sensible defaults.
    public static let `default` = MarqueeConfiguration()
}
