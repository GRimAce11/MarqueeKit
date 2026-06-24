import SwiftUI
import Observation

/// The central state machine that drives every marquee component.
///
/// Each marquee component creates and owns its own engine. The engine is
/// `@Observable` so SwiftUI automatically re-renders dependents when state
/// changes. All methods are `@MainActor` and safe to call from SwiftUI view
/// code or gesture handlers.
///
/// You can access the engine via ``MarqueeEngineKey`` if you need imperative
/// control, but the built-in modifiers cover most use cases.
@Observable
@MainActor
public final class MarqueeEngine {

    // MARK: Configuration

    /// Current active configuration. Mutating this value is reflected
    /// immediately in the next rendered frame.
    public var configuration: MarqueeConfiguration

    // MARK: Observed state (drives UI)

    /// `true` while the animation is running (not paused, not idle).
    public private(set) var isScrolling: Bool = false

    /// `true` when the user or the application has temporarily suspended
    /// the animation.
    public private(set) var isPaused: Bool = false

    /// `true` when the content has been measured and is wider than the
    /// container, meaning scrolling would be meaningful.
    public private(set) var isOverflowing: Bool = false

    // MARK: Internal timing

    /// Seconds of scroll-time accumulated before the most recent pause/resume.
    private var accumulatedPlayTime: Double = 0

    /// The wall-clock date when the current play session began (updated on resume).
    private var playSessionStart: Date = .now

    /// Tracks whether we fired the loop haptic for the current cycle already.
    private var lastHapticCycle: Int = -1

    // MARK: Synchronisation support

    /// When non-nil, overrides local timing with the group's shared start date.
    var syncGroupStartDate: Date?

    // MARK: Content metrics (set by the rendering view)

    var contentSize: CGSize = .zero
    var containerSize: CGSize = .zero

    /// Character count of the scrolling text, or 0 for non-text content.
    /// Used by reading modes that pace the pause to readability.
    var contentCharacterCount: Int = 0

    /// Word count of the scrolling text, or 0 for non-text content.
    var contentWordCount: Int = 0

    // MARK: Init

    public init(configuration: MarqueeConfiguration = .default) {
        self.configuration = configuration
    }

    // MARK: Control API

    /// Begin scrolling from the start position.
    public func start() {
        accumulatedPlayTime = 0
        playSessionStart = syncGroupStartDate ?? .now
        isScrolling = true
        isPaused = false
    }

    /// Temporarily suspend the animation, preserving position.
    public func pause() {
        guard isScrolling, !isPaused else { return }
        accumulatedPlayTime += Date.now.timeIntervalSince(playSessionStart)
        isPaused = true
        isScrolling = false
    }

    /// Resume from the position at which ``pause()`` was called.
    public func resume() {
        guard isPaused else { return }
        playSessionStart = .now
        isPaused = false
        isScrolling = true
    }

    /// Stop the animation and return content to the resting position.
    public func reset() {
        accumulatedPlayTime = 0
        playSessionStart = .now
        isScrolling = false
        isPaused = false
        lastHapticCycle = -1
    }

    // MARK: Overflow detection

    func updateSizes(content: CGSize, container: CGSize) {
        contentSize = content
        containerSize = container

        let horizontal = configuration.direction.isHorizontal
        let contentExtent = horizontal ? content.width : content.height
        let containerExtent = horizontal ? container.width : container.height

        // Overflow can only be evaluated once both axes are measured. Until
        // then, treat the marquee as non-overflowing so it stays static instead
        // of starting an animation against a zero-width container.
        guard contentExtent > 0, containerExtent > 0 else {
            if isOverflowing { isOverflowing = false }
            if isScrolling { reset() }
            return
        }

        let overflow = contentExtent > containerExtent
        let didChange = overflow != isOverflowing
        isOverflowing = overflow

        if didChange && overflow && configuration.trigger == .automatic && !isScrolling {
            // Inside a group the controller re-synchronizes all engines together
            // once every member has measured; don't start solo here.
            if syncGroupStartDate == nil { start() }
        } else if !overflow && isScrolling {
            reset()
        }
    }

    // MARK: Offset computation

    /// Returns the current scroll offset for use inside `TimelineView`.
    ///
    /// - Parameters:
    ///   - date: The `Date` value from `TimelineViewDefaultContext`.
    ///   - loopDistance: The total distance to scroll before looping (content size + spacing).
    /// - Returns: A point offset to apply to the scrolling content.
    func offset(at date: Date, loopDistance: CGFloat) -> CGFloat {
        guard isScrolling || isPaused else { return 0 }
        guard loopDistance > 0 else { return 0 }

        let elapsed = effectiveElapsed(at: date)
        let pps = configuration.speed.resolver(speedContext())
        guard pps > 0 else { return 0 }

        let loop = Double(loopDistance)
        let sign = CGFloat(configuration.direction.animationSign)

        // Seconds required to scroll content exactly one loop distance.
        let scrollDuration = loop / pps

        // Ask the reading mode how long to rest after completing a cycle.
        let pause = readingPauseDuration(scrollDuration: scrollDuration)

        guard pause > 0 else {
            // No pause requested: scroll continuously, wrapping seamlessly.
            let raw = elapsed * pps
            let wrapped = raw.truncatingRemainder(dividingBy: loop)
            fireCycleHapticIfNeeded(cycle: Int(raw / loop))
            return CGFloat(wrapped) * sign
        }

        // Scroll one loop, hold at the resting position for `pause` seconds,
        // then start the next loop. The content is rendered twice, so the end
        // of a scroll (offset == loopDistance) is visually identical to the
        // resting position (offset == 0), making the transition seamless.
        let cycleDuration = scrollDuration + pause
        let cycleIndex = Int(elapsed / cycleDuration)
        let timeInCycle = elapsed.truncatingRemainder(dividingBy: cycleDuration)

        fireCycleHapticIfNeeded(cycle: cycleIndex)

        guard timeInCycle < scrollDuration else {
            // Resting phase between loops.
            return 0
        }

        return CGFloat(timeInCycle * pps) * sign
    }

    // MARK: Private helpers

    private func effectiveElapsed(at date: Date) -> Double {
        if isPaused { return accumulatedPlayTime }
        return accumulatedPlayTime + date.timeIntervalSince(playSessionStart)
    }

    private func speedContext() -> MarqueeSpeedContext {
        let horizontal = configuration.direction.isHorizontal
        let cSize = horizontal ? contentSize.width : contentSize.height
        let kSize = horizontal ? containerSize.width : containerSize.height
        return MarqueeSpeedContext(
            contentWidth: cSize,
            containerWidth: kSize,
            overflowDistance: max(0, cSize - kSize),
            characterCount: contentCharacterCount
        )
    }

    /// Resolves the configured reading mode into a pause duration (seconds) to
    /// rest at the start position after each completed scroll cycle.
    private func readingPauseDuration(scrollDuration: Double) -> Double {
        let ctx = ReadingModeContext(
            characterCount: contentCharacterCount,
            wordCount: contentWordCount,
            locale: .current,
            scrollDuration: scrollDuration
        )
        guard let result = configuration.readingMode.resolver(ctx) else { return 0 }
        return max(0, result.pauseDuration)
    }

    private func fireCycleHapticIfNeeded(cycle: Int) {
        guard configuration.haptics != .none else { return }
        if cycle != lastHapticCycle {
            lastHapticCycle = cycle
            HapticsEngine.shared.trigger(for: configuration.haptics)
        }
    }
}

// MARK: - Environment key

/// Environment key that exposes the nearest ``MarqueeEngine`` to child views.
public struct MarqueeEngineKey: EnvironmentKey {
    public static let defaultValue: MarqueeEngine? = nil
}

public extension EnvironmentValues {
    /// The nearest ``MarqueeEngine`` in the hierarchy, if any.
    var marqueeEngine: MarqueeEngine? {
        get { self[MarqueeEngineKey.self] }
        set { self[MarqueeEngineKey.self] = newValue }
    }
}
