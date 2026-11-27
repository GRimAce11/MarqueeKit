import Foundation
#if os(iOS)
import UIKit
#endif

/// Wraps UIKit haptic generators so the rest of the SDK stays platform-agnostic.
///
/// Haptics exist only on iOS: tvOS has UIKit but no feedback generators, so `canImport(UIKit)`
/// is not enough. Elsewhere every call is a no-op.
@MainActor
final class HapticsEngine {
    static let shared = HapticsEngine()

    private init() {}

    #if os(iOS)
    private lazy var lightImpact = UIImpactFeedbackGenerator(style: .light)
    private lazy var softImpact  = UIImpactFeedbackGenerator(style: .soft)
    #endif

    func trigger(for haptics: MarqueeHaptics) {
        #if os(iOS)
        switch haptics {
        case .none:
            break
        case .loop:
            lightImpact.impactOccurred(intensity: 0.4)
        case .edge:
            softImpact.impactOccurred(intensity: 0.6)
        case .full:
            lightImpact.impactOccurred(intensity: 0.5)
        }
        #endif
    }

    func prepare() {
        #if os(iOS)
        lightImpact.prepare()
        softImpact.prepare()
        #endif
    }
}
