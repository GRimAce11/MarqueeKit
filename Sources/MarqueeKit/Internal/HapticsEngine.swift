import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Wraps UIKit haptic generators so the rest of the SDK stays platform-agnostic.
@MainActor
final class HapticsEngine {
    static let shared = HapticsEngine()

    private init() {}

    #if canImport(UIKit)
    private lazy var lightImpact = UIImpactFeedbackGenerator(style: .light)
    private lazy var softImpact  = UIImpactFeedbackGenerator(style: .soft)
    #endif

    func trigger(for haptics: MarqueeHaptics) {
        #if canImport(UIKit)
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
        #if canImport(UIKit)
        lightImpact.prepare()
        softImpact.prepare()
        #endif
    }
}
