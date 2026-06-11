import XCTest
@testable import MarqueeKit

final class MarqueeConfigurationTests: XCTestCase {

    func test_default_hasAdaptiveSpeed() {
        let config = MarqueeConfiguration.default
        let ctx = MarqueeSpeedContext(
            contentWidth: 500, containerWidth: 200,
            overflowDistance: 300, characterCount: 60
        )
        // Adaptive should return a positive value
        XCTAssertGreaterThan(config.speed.resolver(ctx), 0)
    }

    func test_default_directionIsLeft() {
        XCTAssertEqual(MarqueeConfiguration.default.direction, .left)
    }

    func test_default_triggerIsAutomatic() {
        XCTAssertEqual(MarqueeConfiguration.default.trigger, .automatic)
    }

    func test_default_fadeEdgesDisabled() {
        XCTAssertFalse(MarqueeConfiguration.default.fadeEdges)
    }

    func test_default_pauseOnTouchDisabled() {
        XCTAssertFalse(MarqueeConfiguration.default.pauseOnTouch)
    }

    func test_default_hapticsNone() {
        XCTAssertEqual(MarqueeConfiguration.default.haptics, .none)
    }

    func test_default_effectIsNone() {
        XCTAssertEqual(MarqueeConfiguration.default.effect, .none)
    }

    func test_default_loopSpacingIsPositive() {
        XCTAssertGreaterThan(MarqueeConfiguration.default.loopSpacing, 0)
    }

    func test_custom_overridesSpeed() {
        var config = MarqueeConfiguration.default
        config.speed = .fixed(100)
        let ctx = MarqueeSpeedContext(
            contentWidth: 500, containerWidth: 200,
            overflowDistance: 300, characterCount: 0
        )
        XCTAssertEqual(config.speed.resolver(ctx), 100, accuracy: 0.001)
    }

    func test_direction_isHorizontal() {
        XCTAssertTrue(MarqueeDirection.left.isHorizontal)
        XCTAssertTrue(MarqueeDirection.right.isHorizontal)
        XCTAssertFalse(MarqueeDirection.up.isHorizontal)
        XCTAssertFalse(MarqueeDirection.down.isHorizontal)
    }

    func test_direction_animationSign() {
        XCTAssertEqual(MarqueeDirection.left.animationSign, -1)
        XCTAssertEqual(MarqueeDirection.right.animationSign, 1)
        XCTAssertEqual(MarqueeDirection.up.animationSign, -1)
        XCTAssertEqual(MarqueeDirection.down.animationSign, 1)
    }
}

// MARK: - Equatable conformances for test assertions

extension MarqueeDirection: Equatable {}
extension MarqueeEffect: Equatable {}
extension MarqueeHaptics: Equatable {}
extension MarqueeTrigger: Equatable {}
