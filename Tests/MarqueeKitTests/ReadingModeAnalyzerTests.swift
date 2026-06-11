import XCTest
import Foundation
@testable import MarqueeKit

final class ReadingModeAnalyzerTests: XCTestCase {

    func test_longerText_requiresLongerPause() {
        let short = ReadingModeContext(
            characterCount: 20, wordCount: 4,
            locale: .init(identifier: "en"), scrollDuration: 2
        )
        let long = ReadingModeContext(
            characterCount: 200, wordCount: 40,
            locale: .init(identifier: "en"), scrollDuration: 2
        )
        let shortResult = ReadingModeAnalyzer.analyze(context: short)
        let longResult  = ReadingModeAnalyzer.analyze(context: long)
        XCTAssertGreaterThan(longResult.pauseDuration, shortResult.pauseDuration)
    }

    func test_pause_atLeastMinimumFloor() {
        let ctx = ReadingModeContext(
            characterCount: 5, wordCount: 1,
            locale: .init(identifier: "en"), scrollDuration: 60
        )
        let result = ReadingModeAnalyzer.analyze(context: ctx)
        XCTAssertGreaterThanOrEqual(result.pauseDuration, 0.5)
    }

    func test_smartMode_returnsResult() {
        let ctx = ReadingModeContext(
            characterCount: 50, wordCount: 10,
            locale: .init(identifier: "en"), scrollDuration: 3
        )
        XCTAssertNotNil(MarqueeReadingMode.smart.resolver(ctx))
    }

    func test_continuousMode_returnsNil() {
        let ctx = ReadingModeContext(
            characterCount: 50, wordCount: 10,
            locale: .init(identifier: "en"), scrollDuration: 3
        )
        XCTAssertNil(MarqueeReadingMode.continuous.resolver(ctx))
    }

    func test_pauseAfterScroll_usesExactDuration() {
        let ctx = ReadingModeContext(
            characterCount: 10, wordCount: 2,
            locale: .init(identifier: "en"), scrollDuration: 2
        )
        let result = MarqueeReadingMode.pauseAfterScroll(3.5).resolver(ctx)
        XCTAssertEqual(result?.pauseDuration ?? 0, 3.5, accuracy: 0.001)
    }

    func test_wordCount_multiWordString() {
        XCTAssertGreaterThanOrEqual("Hello world how are you".wordCount, 5)
    }

    func test_wordCount_emptyString() {
        XCTAssertEqual("".wordCount, 0)
    }

    func test_wordsPerMinute_mode() {
        let ctx = ReadingModeContext(
            characterCount: 100, wordCount: 20,
            locale: .init(identifier: "en"), scrollDuration: 2
        )
        let result = MarqueeReadingMode.wordsPerMinute(200).resolver(ctx)
        // 20 words at 200 wpm = 6 seconds; 2 s scroll → 4 s pause
        XCTAssertGreaterThan(result?.pauseDuration ?? 0, 0)
    }
}
