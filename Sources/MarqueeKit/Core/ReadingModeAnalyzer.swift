import Foundation

/// Analyzes text content and returns a reading-mode result that gives readers
/// enough time to absorb the information before the next scroll cycle.
public enum ReadingModeAnalyzer {

    // Average adult reading speed (words per minute).
    private static let averageWPM: Double = 200

    // Minimum pause after any scroll cycle (seconds).
    private static let minimumPause: Double = 0.5

    /// Produces a ``ReadingModeResult`` appropriate for the given context.
    public static func analyze(context: ReadingModeContext) -> ReadingModeResult {
        let wordsPerMinute = adjustedWPM(for: context.locale)
        let readSeconds = Double(context.wordCount) / wordsPerMinute * 60

        // If scrolling already takes longer than reading, no extra pause needed.
        let pause = max(minimumPause, readSeconds - context.scrollDuration)
        return ReadingModeResult(
            scrollDuration: context.scrollDuration,
            pauseDuration: pause
        )
    }

    // MARK: - Helpers

    private static func adjustedWPM(for locale: Locale) -> Double {
        // CJK languages have much fewer characters per word; reduce the divisor.
        let language = locale.language.languageCode?.identifier ?? "en"
        switch language {
        case "zh", "ja", "ko": return averageWPM * 0.4   // ~80 chars/min
        case "ar", "he": return averageWPM * 0.85
        default: return averageWPM
        }
    }
}

// MARK: - Word counting

extension String {
    /// A locale-aware word count using `NLTokenizer` when available.
    var wordCount: Int {
        let tokenizer = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tokenizer.string = self
        var count = 0
        let range = NSRange(self.startIndex..., in: self)
        tokenizer.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: .omitWhitespace) { _, _, _ in
            count += 1
        }
        return count > 0 ? count : components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
}
