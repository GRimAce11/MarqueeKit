/// MarqueeKit — Modern scrolling text and content for SwiftUI and UIKit.
///
/// ## Getting Started
///
/// Add MarqueeKit to your project via Swift Package Manager:
///
/// ```swift
/// .package(url: "https://github.com/GRimAce11/MarqueeKit", from: "1.0.0")
/// ```
///
/// Import the module:
///
/// ```swift
/// import MarqueeKit
/// ```
///
/// ## Components
///
/// | Component | Use case |
/// |-----------|----------|
/// | ``MarqueeText`` | Scrolling plain text |
/// | ``MarqueeContent`` | Scrolling any SwiftUI view |
/// | ``MarqueeTicker`` | Multi-item news / stock ticker |
/// | ``MarqueeBanner`` | Single-message notification banner |
///
/// ## Quick Examples
///
/// ```swift
/// // Simple
/// MarqueeText("Apple releases iOS 18 — major AI features included")
///
/// // Customised
/// MarqueeText(headline)
///     .speed(.adaptive)
///     .fadeEdges(true)
///     .pauseOnTouch(true)
///     .marqueeTheme(.glass)
///
/// // Ticker
/// MarqueeTicker(stockItems) { item in
///     StockRow(item: item)
/// }
/// .marqueeTheme(.ticker)
///
/// // Group — synchronised scrolling
/// MarqueeGroup {
///     MarqueeText("Line one")
///     MarqueeText("Line two")
/// }
/// ```
@_exported import SwiftUI
