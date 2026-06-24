import SwiftUI
import Observation

/// Coordinates timing across multiple marquee views so they scroll in lockstep.
///
/// `MarqueeSyncController` is injected into the SwiftUI environment by
/// ``MarqueeGroup`` and consumed by each marquee engine inside the group.
/// Child engines call ``requestSynchronize()`` as soon as they detect overflow;
/// the controller debounces these calls so all engines that become ready in the
/// same layout pass receive one shared start date and begin scrolling from
/// position 0 at the same moment.
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
        engines.removeValue(forKey: ObjectIdentifier(engine))
    }

    // MARK: Group control

    /// Called by child engines when they first become overflowing.
    /// Debounced so all engines that overflow in the same layout pass share a
    /// single `synchronize()` call with a fresh start date.
    func requestSynchronize() {
        guard pendingSyncTask == nil else { return }
        pendingSyncTask = Task { @MainActor [weak self] in
            self?.pendingSyncTask = nil
            self?.synchronize()
        }
    }

    /// Resets the shared start date, causing all engines to begin at the same
    /// position simultaneously.
    public func synchronize() {
        sharedStartDate = .now
        for pair in engines.values {
            pair.engine?.syncGroupStartDate = sharedStartDate
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
