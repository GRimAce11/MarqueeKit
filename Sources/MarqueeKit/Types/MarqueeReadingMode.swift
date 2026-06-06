import Foundation

/// Input provided to a reading-mode resolver.
public struct ReadingModeContext: Sendable {
    public let characterCount: Int
    public let wordCount: Int
    public let locale: Locale
    public let scrollDuration: Double
}

/// Output from a reading-mode resolver.
public struct ReadingModeResult: Sendable {
    /// Total duration to display one pass of content (scroll + pause).
    public let scrollDuration: Double
    /// How long to pause after one scroll cycle before looping.
    public let pauseDuration: Double

    public init(scrollDuration: Double, pauseDuration: Double) {
        self.scrollDuration = scrollDuration
        self.pauseDuration = pauseDuration
    }

    static let none = ReadingModeResult(scrollDuration: 0, pauseDuration: 0)
}

/// Determines how long content is displayed relative to its readability.
///
/// ```swift
/// MarqueeText("Long article headline…")
///     .readingMode(.smart)
/// ```
public struct MarqueeReadingMode: @unchecked Sendable {
    let resolver: @Sendable (ReadingModeContext) -> ReadingModeResult?

    // MARK: Presets

    /// No reading-mode adjustment; content loops at a constant speed.
    public static let continuous = MarqueeReadingMode { _ in nil }

    /// Automatically estimates a comfortable reading pace and adds a pause
    /// after each scroll cycle so the reader can finish the content.
    public static let smart = MarqueeReadingMode { ctx in
        ReadingModeAnalyzer.analyze(context: ctx)
    }

    // MARK: Factories

    /// Pause for a fixed duration after each scroll cycle.
    public static func pauseAfterScroll(_ duration: TimeInterval) -> MarqueeReadingMode {
        MarqueeReadingMode { ctx in
            ReadingModeResult(scrollDuration: ctx.scrollDuration, pauseDuration: duration)
        }
    }

    /// Tune scrolling for the given words-per-minute reading speed.
    public static func wordsPerMinute(_ wpm: Int) -> MarqueeReadingMode {
        MarqueeReadingMode { ctx in
            let minutes = Double(ctx.wordCount) / Double(max(1, wpm))
            let pause = max(0, minutes * 60 - ctx.scrollDuration)
            return ReadingModeResult(scrollDuration: ctx.scrollDuration, pauseDuration: pause)
        }
    }
}
