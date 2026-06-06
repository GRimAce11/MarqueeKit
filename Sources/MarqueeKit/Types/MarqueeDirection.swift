import SwiftUI

/// The axis and direction in which content scrolls.
public enum MarqueeDirection: String, Sendable, CaseIterable {
    /// Scroll from right to left (default, most common).
    case left
    /// Scroll from left to right.
    case right
    /// Scroll from bottom to top.
    case up
    /// Scroll from top to bottom.
    case down

    // MARK: Helpers

    var isHorizontal: Bool {
        self == .left || self == .right
    }

    var isReversed: Bool {
        self == .right || self == .down
    }

    var animationSign: Double {
        isReversed ? 1 : -1
    }
}
