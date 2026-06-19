import XCTest
import CoreGraphics
@testable import MarqueeKit

final class SpeedCalculatorTests: XCTestCase {

    private let ctx = MarqueeSpeedContext(
        contentWidth: 500, containerWidth: 300,
        overflowDistance: 200, characterCount: 40
    )

    func test_fixedSpeed_returnsSpecifiedValue() {
        let speed = MarqueeSpeed.fixed(90)
        XCTAssertEqual(speed.resolver(ctx), 90, accuracy: 0.001)
    }

    func test_fixedSpeed_minimumIsOne() {
        let speed = MarqueeSpeed.fixed(-10)
        XCTAssertGreaterThanOrEqual(speed.resolver(ctx), 1)
    }

    func test_slowPreset_isSlowerThanMedium() {
        XCTAssertLessThan(
            MarqueeSpeed.slow.resolver(ctx),
            MarqueeSpeed.medium.resolver(ctx)
        )
    }

    func test_mediumPreset_isSlowerThanFast() {
        XCTAssertLessThan(
            MarqueeSpeed.medium.resolver(ctx),
            MarqueeSpeed.fast.resolver(ctx)
        )
    }

    func test_adaptiveSpeed_increasesWithLargerOverflow() {
        let smallCtx = MarqueeSpeedContext(
            contentWidth: 400, containerWidth: 300,
            overflowDistance: 100, characterCount: 20
        )
        let largeCtx = MarqueeSpeedContext(
            contentWidth: 800, containerWidth: 300,
            overflowDistance: 500, characterCount: 100
        )
        XCTAssertGreaterThan(
            MarqueeSpeed.adaptive.resolver(largeCtx),
            MarqueeSpeed.adaptive.resolver(smallCtx)
        )
    }

    func test_adaptiveSpeed_smallOverflowDoesNotCrawl() {
        // An email that only spills ~35pt past its container must still scroll
        // at a readable velocity, not the ~8px/s crawl the old duration model gave.
        let tinyOverflow = MarqueeSpeedContext(
            contentWidth: 167, containerWidth: 132,
            overflowDistance: 35, characterCount: 27
        )
        XCTAssertGreaterThanOrEqual(MarqueeSpeed.adaptive.resolver(tinyOverflow), 30)
    }

    func test_adaptiveSpeed_largeOverflowIsClamped() {
        let hugeOverflow = MarqueeSpeedContext(
            contentWidth: 5000, containerWidth: 300,
            overflowDistance: 4700, characterCount: 800
        )
        XCTAssertLessThanOrEqual(MarqueeSpeed.adaptive.resolver(hugeOverflow), 120)
    }

    func test_customResolver_receivesCorrectContext() {
        var received: MarqueeSpeedContext?
        let speed = MarqueeSpeed.custom { c in received = c; return 77 }
        let result = speed.resolver(ctx)
        XCTAssertEqual(result, 77, accuracy: 0.001)
        XCTAssertEqual(received?.contentWidth, 500)
    }

    func test_pixelsPerSecond_withExplicitDuration() {
        let pps = SpeedCalculator.pixelsPerSecond(
            overflowDistance: 200,
            characterCount: 0,
            targetReadSeconds: 5
        )
        XCTAssertEqual(pps, 40, accuracy: 0.001)
    }

    func test_pixelsPerSecond_forLoopDistance() {
        let pps = SpeedCalculator.pixelsPerSecond(forDuration: 4, loopDistance: 200)
        XCTAssertEqual(pps, 50, accuracy: 0.001)
    }

    func test_pixelsPerSecond_zeroDurationUsesDefault() {
        let pps = SpeedCalculator.pixelsPerSecond(forDuration: 0, loopDistance: 200)
        XCTAssertGreaterThan(pps, 0)
    }
}
