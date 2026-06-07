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
        let overflow = configuration.direction.isHorizontal
            ? content.width > container.width
            : content.height > container.height
        let didChange = overflow != isOverflowing
        isOverflowing = overflow

        if didChange && overflow && configuration.trigger == .automatic && !isScrolling {
            start()
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
        let ctx = speedContext()
        let pps = configuration.speed.resolver(ctx)

        let raw = elapsed * pps
        let wrapped = raw.truncatingRemainder(dividingBy: Double(loopDistance))

        fireHapticIfNeeded(raw: raw, loopDistance: Double(loopDistance))

        return CGFloat(wrapped) * CGFloat(configuration.direction.animationSign)
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
            characterCount: 0
        )
    }

    private func fireHapticIfNeeded(raw: Double, loopDistance: Double) {
        guard configuration.haptics != .none, loopDistance > 0 else { return }
        let cycle = Int(raw / loopDistance)
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
