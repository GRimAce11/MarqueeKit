import SwiftUI
import Observation

/// Coordinates timing across multiple marquee views so they scroll in lockstep.
///
/// `MarqueeSyncController` is injected into the SwiftUI environment by
/// ``MarqueeGroup`` and consumed by each marquee engine inside the group.
/// Child engines call ``requestSynchronize()`` when they first detect overflow.
/// Cancel-and-replace debouncing ensures the call that fires after the last
/// engine has measured wins, so ``synchronize()`` runs once with all sizes
/// available. If an engine is already scrolling when its size arrives,
/// ``updateGroupSpeed()`` corrects the shared velocity without disturbing the
/// shared start date.
@Observable
@MainActor
public final class MarqueeSyncController {

    /// The shared start date used by every engine in the group.
    public private(set) var sharedStartDate: Date = .now

    /// When `true`, all marquees in the group are paused simultaneously.
    public private(set) var isPaused: Bool = false

    private var engines: [ObjectIdentifier: WeakEngine] = [:]
    private var pendingSyncTask: Task<Void, Never>?

    public init() {}

    // MARK: Registration

    func register(_ engine: MarqueeEngine) {
        engines[ObjectIdentifier(engine)] = WeakEngine(engine)
    }

    func unregister(_ engine: MarqueeEngine) {
        engine.sharedGroupPPS = nil
        engines.removeValue(forKey: ObjectIdentifier(engine))
    }

    // MARK: Group control

    /// Called by a child engine when it first becomes overflowing and has not
    /// yet been started by the group.  Uses cancel-and-replace debouncing so
    /// the *last* engine to measure (often the one with the most content) wins
    /// the race and `synchronize()` fires once with all sizes available.
    func requestSynchronize() {
        pendingSyncTask?.cancel()
        pendingSyncTask = Task { @MainActor [weak self] in
            guard !Task.isCancelled else { return }
            self?.pendingSyncTask = nil
            self?.synchronize()
        }
    }

    /// Called by a child engine that is already scrolling (started by an
    /// earlier `synchronize()` call) but whose content size just became
    /// available.  Recomputes and redistributes the shared speed without
    /// resetting the shared start date, so timing stays locked while the
    /// velocity is corrected.
    func updateGroupSpeed() {
        let groupPPS = engines.values
            .compactMap { $0.engine }
            .map { $0.configuration.speed.resolver($0.speedContext()) }
            .max()
        for pair in engines.values {
            pair.engine?.sharedGroupPPS = groupPPS
        }
    }

    /// Resets the shared start date and shared speed, causing all engines to
    /// begin from position 0 at the same moment and travel at the same velocity.
    ///
    /// The shared speed is the maximum of every registered engine's resolved
    /// px/s value at the time of the call, so engines with different font sizes
    /// or content lengths stay visually in lockstep rather than drifting.
    public func synchronize() {
        sharedStartDate = .now

        let groupPPS = engines.values
            .compactMap { $0.engine }
            .map { $0.configuration.speed.resolver($0.speedContext()) }
            .max()

        for pair in engines.values {
            pair.engine?.syncGroupStartDate = sharedStartDate
            pair.engine?.sharedGroupPPS = groupPPS
            pair.engine?.start()
        }
    }

    /// Pauses all marquees in the group.
    public func pauseAll() {
        isPaused = true
        for pair in engines.values { pair.engine?.pause() }
    }

    /// Resumes all marquees in the group.
    public func resumeAll() {
        isPaused = false
        for pair in engines.values { pair.engine?.resume() }
    }
}

private struct WeakEngine {
    weak var engine: MarqueeEngine?
    init(_ engine: MarqueeEngine) { self.engine = engine }
}

// MARK: - Environment key

struct MarqueeGroupSyncKey: EnvironmentKey {
    static let defaultValue: MarqueeSyncController? = nil
}

public extension EnvironmentValues {
    var marqueeGroupSyncController: MarqueeSyncController? {
        get { self[MarqueeGroupSyncKey.self] }
        set { self[MarqueeGroupSyncKey.self] = newValue }
    }
}
