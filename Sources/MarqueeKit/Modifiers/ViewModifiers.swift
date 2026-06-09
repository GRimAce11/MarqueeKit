import SwiftUI

// MARK: - Universal marquee modifiers
//
// These modifiers work on ANY view and insert a MarqueeContent wrapper,
// allowing you to make any existing view scroll like a marquee.

public extension View {

    /// Wraps this view in a ``MarqueeContent`` with the given configuration.
    ///
    /// ```swift
    /// Text("Very long product name")
    ///     .asMarquee()
    ///     .speed(.adaptive)
    /// ```
    func asMarquee(configuration: MarqueeConfiguration = .default) -> MarqueeContent<Self> {
        MarqueeContent(configuration: configuration) { self }
    }
}

// MARK: - Configuration shorthand on any View

/// Adds `marqueeTheme` as a universal view modifier that looks up and modifies
/// the nearest engine in the environment if present.
public struct MarqueeThemeModifier: ViewModifier {
    let theme: MarqueeTheme
    @Environment(\.marqueeEngine) private var engine

    public func body(content: Content) -> some View {
        content
            .onAppear { engine?.configuration.theme = theme }
    }
}

public extension View {
    /// Applies a ``MarqueeTheme`` to the nearest marquee engine in the environment.
    func marqueeTheme(_ theme: MarqueeTheme) -> some View {
        modifier(MarqueeThemeModifier(theme: theme))
    }
}
