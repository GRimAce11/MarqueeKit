import SwiftUI

/// A visual style applied to the marquee container.
///
/// ```swift
/// MarqueeText("Now playing")
///     .marqueeTheme(.glass)
/// ```
public struct MarqueeTheme: Sendable {
    public var backgroundColor: Color?
    public var foregroundColor: Color?
    public var cornerRadius: CGFloat
    public var padding: EdgeInsets
    public var borderColor: Color?
    public var borderWidth: CGFloat
    public var backgroundMaterial: Material?

    public init(
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        cornerRadius: CGFloat = 0,
        padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        backgroundMaterial: Material? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.backgroundMaterial = backgroundMaterial
    }

    // MARK: Built-in themes

    /// No background, no padding. Content is displayed as-is.
    public static let minimal = MarqueeTheme()

    /// Frosted-glass material background with rounded corners.
    public static let glass = MarqueeTheme(
        cornerRadius: 12,
        padding: EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12),
        backgroundMaterial: .ultraThinMaterial
    )

    /// Classic stock-ticker style: dark background, monospaced bright text.
    public static let ticker = MarqueeTheme(
        backgroundColor: .black,
        foregroundColor: .green,
        cornerRadius: 4,
        padding: EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
    )

    /// Rounded card with a subtle border.
    public static let modern = MarqueeTheme(
        backgroundColor: Color.primary.opacity(0.04),
        cornerRadius: 16,
        padding: EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16),
        borderColor: Color.primary.opacity(0.12),
        borderWidth: 0.5
    )
}
