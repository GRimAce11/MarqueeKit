import XCTest
import CoreGraphics
import Foundation
@testable import MarqueeKit

/// Edge-case coverage for the pure-logic surface of MarqueeKit.
///
/// Each section maps to a component and probes boundary / degenerate inputs:
/// zero, negative, NaN, infinity, empty, overflow, and locale extremes.
final class EdgeCaseTests: XCTestCase {

    private func ctx(content: CGFloat, container: CGFloat, chars: Int = 0) -> MarqueeSpeedContext {
        MarqueeSpeedContext(
            contentWidth: content, containerWidth: container,
            overflowDistance: max(0, content - container), characterCount: chars
        )
    }

    // MARK: - Adaptive speed: degenerate inputs

    func test_adaptive_zeroOverflow_stillReadable() {
        // Content exactly fits: overflow 0 must not yield 0 px/s.
        let pps = MarqueeSpeed.adaptive.resolver(ctx(content: 100, container: 100))
        XCTAssertGreaterThanOrEqual(pps, 30)
    }

    func test_adaptive_negativeOverflow_clampedToFloor() {
        let weird = MarqueeSpeedContext(
            contentWidth: 50, containerWidth: 100,
            overflowDistance: -50, characterCount: 5
        )
        let pps = MarqueeSpeed.adaptive.resolver(weird)
        XCTAssertGreaterThanOrEqual(pps, 30)
        XCTAssertLessThanOrEqual(pps, 120)
    }

    func test_adaptive_infiniteOverflow_isFiniteAndClamped() {
        let inf = MarqueeSpeedContext(
            contentWidth: .infinity, containerWidth: 100,
            overflowDistance: .infinity, characterCount: 10
        )
        let pps = MarqueeSpeed.adaptive.resolver(inf)
        XCTAssertTrue(pps.isFinite)
        XCTAssertLessThanOrEqual(pps, 120)
    }

    func test_adaptive_nanOverflow_isFinite() {
        let nan = MarqueeSpeedContext(
            contentWidth: .nan, containerWidth: 100,
            overflowDistance: .nan, characterCount: 10
        )
        let pps = MarqueeSpeed.adaptive.resolver(nan)
        XCTAssertTrue(pps.isFinite)
        XCTAssertGreaterThanOrEqual(pps, 30)
    }

    func test_adaptive_neverExceedsCeiling() {
        let huge = MarqueeSpeedContext(
            contentWidth: 100_000, containerWidth: 50,
            overflowDistance: 99_950, characterCount: 9_000
        )
        XCTAssertLessThanOrEqual(MarqueeSpeed.adaptive.resolver(huge), 120)
    }

    func test_adaptive_isMonotonicInOverflow() {
        var last = 0.0
        for overflow in stride(from: CGFloat(1), through: 5_000, by: 250) {
            let pps = MarqueeSpeed.adaptive.resolver(
                MarqueeSpeedContext(contentWidth: overflow, containerWidth: 0,
                                    overflowDistance: overflow, characterCount: 0)
            )
            XCTAssertGreaterThanOrEqual(pps, last - 0.0001, "speed dipped at overflow \(overflow)")
            last = min(pps, 120)
        }
    }

    // MARK: - Fixed / preset speeds

    func test_fixed_zero_clampedToOne() {
        XCTAssertEqual(MarqueeSpeed.fixed(0).resolver(ctx(content: 200, container: 100)), 1, accuracy: 0.001)
    }

    func test_fixed_nan_clampedToOne() {
        // max(1, nan) must not propagate NaN.
        let pps = MarqueeSpeed.fixed(.nan).resolver(ctx(content: 200, container: 100))
        XCTAssertTrue(pps.isFinite)
        XCTAssertGreaterThanOrEqual(pps, 1)
    }

    func test_presets_orderedSlowMediumFast() {
        let c = ctx(content: 500, container: 300)
        XCTAssertLessThan(MarqueeSpeed.slow.resolver(c), MarqueeSpeed.medium.resolver(c))
        XCTAssertLessThan(MarqueeSpeed.medium.resolver(c), MarqueeSpeed.fast.resolver(c))
    }

    // MARK: - SpeedCalculator helpers

    func test_pixelsPerSecond_negativeTargetUsesAdaptive() {
        // targetReadSeconds <= 0 must fall through to adaptive, never go negative.
        let pps = SpeedCalculator.pixelsPerSecond(overflowDistance: 200, characterCount: 5, targetReadSeconds: -3)
        XCTAssertGreaterThan(pps, 0)
    }

    func test_pixelsPerSecond_zeroOverflowExplicitDuration() {
        // overflow floored to 1 so an exact-fit never divides to 0.
        let pps = SpeedCalculator.pixelsPerSecond(overflowDistance: 0, characterCount: 0, targetReadSeconds: 5)
        XCTAssertGreaterThan(pps, 0)
    }

    func test_pixelsPerSecond_forDuration_negativeLoopDistance_safe() {
        // A negative loop distance must not yield a negative (backwards) speed.
        let pps = SpeedCalculator.pixelsPerSecond(forDuration: 4, loopDistance: -200)
        XCTAssertGreaterThan(pps, 0)
    }

    func test_pixelsPerSecond_forDuration_zeroDuration_default() {
        XCTAssertEqual(SpeedCalculator.pixelsPerSecond(forDuration: 0, loopDistance: 200), 60, accuracy: 0.001)
    }

    // MARK: - ReadingModeAnalyzer

    func test_reading_zeroWords_minimumPause() {
        let r = ReadingModeAnalyzer.analyze(context: .init(
            characterCount: 0, wordCount: 0, locale: .init(identifier: "en"), scrollDuration: 0))
        XCTAssertGreaterThanOrEqual(r.pauseDuration, 0.5)
    }

    func test_reading_scrollLongerThanRead_floorsToMinimum() {
        let r = ReadingModeAnalyzer.analyze(context: .init(
            characterCount: 5, wordCount: 1, locale: .init(identifier: "en"), scrollDuration: 999))
        XCTAssertEqual(r.pauseDuration, 0.5, accuracy: 0.001)
    }

    func test_reading_cjkLocale_pausesLongerThanEnglish() {
        let words = 30
        let en = ReadingModeAnalyzer.analyze(context: .init(
            characterCount: 120, wordCount: words, locale: .init(identifier: "en"), scrollDuration: 1))
        let ja = ReadingModeAnalyzer.analyze(context: .init(
            characterCount: 120, wordCount: words, locale: .init(identifier: "ja"), scrollDuration: 1))
        XCTAssertGreaterThan(ja.pauseDuration, en.pauseDuration)
    }

    func test_reading_rtlLocale_pausesLongerThanEnglish() {
        let words = 30
        let en = ReadingModeAnalyzer.analyze(context: .init(
            characterCount: 120, wordCount: words, locale: .init(identifier: "en"), scrollDuration: 1))
        let ar = ReadingModeAnalyzer.analyze(context: .init(
            characterCount: 120, wordCount: words, locale: .init(identifier: "ar"), scrollDuration: 1))
        XCTAssertGreaterThan(ar.pauseDuration, en.pauseDuration)
    }

    func test_reading_negativeScrollDuration_stillPositivePause() {
        let r = ReadingModeAnalyzer.analyze(context: .init(
            characterCount: 50, wordCount: 10, locale: .init(identifier: "en"), scrollDuration: -5))
        XCTAssertGreaterThan(r.pauseDuration, 0)
    }

    // MARK: - Reading mode factories

    func test_pauseAfterScroll_negative_clampedToZero() {
        let r = MarqueeReadingMode.pauseAfterScroll(-10).resolver(.init(
            characterCount: 10, wordCount: 2, locale: .init(identifier: "en"), scrollDuration: 2))
        XCTAssertEqual(r?.pauseDuration ?? -1, 0, accuracy: 0.001)
    }

    func test_wordsPerMinute_zero_doesNotCrashOrDivideByZero() {
        let r = MarqueeReadingMode.wordsPerMinute(0).resolver(.init(
            characterCount: 100, wordCount: 20, locale: .init(identifier: "en"), scrollDuration: 2))
        XCTAssertNotNil(r)
        XCTAssertTrue((r?.pauseDuration ?? 0).isFinite)
    }

    func test_wordsPerMinute_negative_treatedAsAtLeastOne() {
        let r = MarqueeReadingMode.wordsPerMinute(-100).resolver(.init(
            characterCount: 100, wordCount: 20, locale: .init(identifier: "en"), scrollDuration: 2))
        XCTAssertTrue((r?.pauseDuration ?? -1) >= 0)
    }

    func test_continuous_returnsNil() {
        XCTAssertNil(MarqueeReadingMode.continuous.resolver(.init(
            characterCount: 10, wordCount: 2, locale: .init(identifier: "en"), scrollDuration: 1)))
    }

    // MARK: - String.wordCount

    func test_wordCount_empty_isZero() { XCTAssertEqual("".wordCount, 0) }

    func test_wordCount_whitespaceOnly_isZero() {
        XCTAssertEqual("     \n\t  ".wordCount, 0)
    }

    func test_wordCount_singleWord_isOne() { XCTAssertEqual("Hello".wordCount, 1) }

    func test_wordCount_collapsesRepeatedSpaces() {
        XCTAssertEqual("a     b".wordCount, 2)
    }

    func test_wordCount_emojiOnly_doesNotCrash() {
        XCTAssertGreaterThanOrEqual("😀🎉🚀".wordCount, 0)
    }

    func test_wordCount_newlineSeparated() {
        XCTAssertGreaterThanOrEqual("line one\nline two".wordCount, 4)
    }

    // MARK: - MarqueeDirection

    func test_direction_horizontalAndSigns() {
        XCTAssertTrue(MarqueeDirection.left.isHorizontal)
        XCTAssertTrue(MarqueeDirection.right.isHorizontal)
        XCTAssertFalse(MarqueeDirection.up.isHorizontal)
        XCTAssertFalse(MarqueeDirection.down.isHorizontal)
        XCTAssertEqual(MarqueeDirection.left.animationSign, -1)
        XCTAssertEqual(MarqueeDirection.right.animationSign, 1)
        XCTAssertEqual(MarqueeDirection.up.animationSign, -1)
        XCTAssertEqual(MarqueeDirection.down.animationSign, 1)
    }

    // MARK: - MarqueeEngine state machine

    @MainActor
    func test_engine_pauseBeforeStart_isNoOp() {
        let e = MarqueeEngine()
        e.pause()
        XCTAssertFalse(e.isPaused)
        XCTAssertFalse(e.isScrolling)
    }

    @MainActor
    func test_engine_resumeWithoutPause_isNoOp() {
        let e = MarqueeEngine()
        e.start()
        e.resume()
        XCTAssertTrue(e.isScrolling)
        XCTAssertFalse(e.isPaused)
    }

    @MainActor
    func test_engine_startPauseResumeReset_transitions() {
        let e = MarqueeEngine()
        e.start();  XCTAssertTrue(e.isScrolling)
        e.pause();  XCTAssertTrue(e.isPaused); XCTAssertFalse(e.isScrolling)
        e.resume(); XCTAssertTrue(e.isScrolling); XCTAssertFalse(e.isPaused)
        e.reset();  XCTAssertFalse(e.isScrolling); XCTAssertFalse(e.isPaused)
    }

    @MainActor
    func test_engine_offset_zeroWhenIdle() {
        let e = MarqueeEngine()
        XCTAssertEqual(e.offset(at: .now, loopDistance: 200), 0)
    }

    @MainActor
    func test_engine_offset_zeroWhenLoopDistanceNonPositive() {
        let e = MarqueeEngine()
        e.start()
        XCTAssertEqual(e.offset(at: .now, loopDistance: 0), 0)
        XCTAssertEqual(e.offset(at: .now, loopDistance: -50), 0)
    }

    @MainActor
    func test_engine_zeroSizedContainer_doesNotOverflowOrScroll() {
        let e = MarqueeEngine()
        e.updateSizes(content: .zero, container: .zero)
        XCTAssertFalse(e.isOverflowing)
        XCTAssertFalse(e.isScrolling)
    }

    @MainActor
    func test_engine_contentFits_doesNotAutoStart() {
        let e = MarqueeEngine()
        e.updateSizes(content: CGSize(width: 80, height: 16), container: CGSize(width: 200, height: 16))
        XCTAssertFalse(e.isOverflowing)
        XCTAssertFalse(e.isScrolling)
    }

    @MainActor
    func test_engine_overflow_autoStartsOnAutomaticTrigger() {
        let e = MarqueeEngine()
        e.updateSizes(content: CGSize(width: 400, height: 16), container: CGSize(width: 100, height: 16))
        XCTAssertTrue(e.isOverflowing)
        XCTAssertTrue(e.isScrolling)
    }

    @MainActor
    func test_engine_overflow_doesNotAutoStartOnProgrammaticTrigger() {
        let e = MarqueeEngine(configuration: MarqueeConfiguration(trigger: .programmatic))
        e.updateSizes(content: CGSize(width: 400, height: 16), container: CGSize(width: 100, height: 16))
        XCTAssertTrue(e.isOverflowing)
        XCTAssertFalse(e.isScrolling)
    }

    @MainActor
    func test_engine_shrinkBelowContainer_resetsScrolling() {
        let e = MarqueeEngine()
        e.updateSizes(content: CGSize(width: 400, height: 16), container: CGSize(width: 100, height: 16))
        XCTAssertTrue(e.isScrolling)
        e.updateSizes(content: CGSize(width: 50, height: 16), container: CGSize(width: 100, height: 16))
        XCTAssertFalse(e.isOverflowing)
        XCTAssertFalse(e.isScrolling)
    }

    @MainActor
    func test_engine_offset_signFollowsDirection() {
        // Deterministic timing via the sync start-date hook.
        let fixed = Date(timeIntervalSince1970: 1_000_000)

        let leftEngine = MarqueeEngine(configuration: MarqueeConfiguration(direction: .left, trigger: .programmatic))
        leftEngine.updateSizes(content: CGSize(width: 500, height: 16), container: CGSize(width: 100, height: 16))
        leftEngine.syncGroupStartDate = fixed
        leftEngine.start()
        let leftOffset = leftEngine.offset(at: fixed.addingTimeInterval(0.5), loopDistance: 540)
        XCTAssertLessThan(leftOffset, 0, "left should scroll to negative offset")

        let rightEngine = MarqueeEngine(configuration: MarqueeConfiguration(direction: .right, trigger: .programmatic))
        rightEngine.updateSizes(content: CGSize(width: 500, height: 16), container: CGSize(width: 100, height: 16))
        rightEngine.syncGroupStartDate = fixed
        rightEngine.start()
        let rightOffset = rightEngine.offset(at: fixed.addingTimeInterval(0.5), loopDistance: 540)
        XCTAssertGreaterThan(rightOffset, 0, "right should scroll to positive offset")
    }

    @MainActor
    func test_engine_offset_wrapsWithinLoopDistance() {
        let fixed = Date(timeIntervalSince1970: 2_000_000)
        let e = MarqueeEngine(configuration: MarqueeConfiguration(speed: .fixed(100), trigger: .programmatic))
        e.updateSizes(content: CGSize(width: 500, height: 16), container: CGSize(width: 100, height: 16))
        e.syncGroupStartDate = fixed
        e.start()
        // 1000s * 100px/s = 100_000px; wrapped into 200 → magnitude must stay < 200.
        let offset = e.offset(at: fixed.addingTimeInterval(1000), loopDistance: 200)
        XCTAssertLessThan(abs(offset), 200)
    }
}
