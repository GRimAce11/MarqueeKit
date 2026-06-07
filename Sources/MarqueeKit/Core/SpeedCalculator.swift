import CoreGraphics
import Foundation

/// Stateless helpers for computing scroll speed from content measurements.
public enum SpeedCalculator {

    // MARK: Character-aware speed

    /// Computes pixels-per-second tuned so the content takes approximately
    /// `targetReadSeconds` to travel across the screen.
    ///
    /// - Parameters:
    ///   - overflowDistance: How far the content extends beyond the container.
    ///   - characterCount: Character count of the text (0 for non-text content).
    ///   - targetReadSeconds: Ideal time for one complete scroll cycle.
    public static func pixelsPerSecond(
        overflowDistance: CGFloat,
        characterCount: Int,
        targetReadSeconds: Double = 0
    ) -> Double {
        let overflow = max(1, Double(overflowDistance))
        if targetReadSeconds > 0 {
            return overflow / targetReadSeconds
        }
        return AdaptiveSpeedCalculator.compute(
            context: MarqueeSpeedContext(
                contentWidth: overflow,
                containerWidth: 0,
                overflowDistance: overflow,
                characterCount: characterCount
            )
        )
    }

    /// Converts a desired scroll duration into pixels-per-second given a loop distance.
    public static func pixelsPerSecond(forDuration duration: Double, loopDistance: CGFloat) -> Double {
        guard duration > 0 else { return 60 }
        return Double(loopDistance) / duration
    }
}
